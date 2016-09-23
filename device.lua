require('consts')

JSON = cjson
local inited = false;
mqttClient = mqtt

brokerConfs = {addr="192.168.199.120" , port=1883 , userName="" , password=""}

IO_LED = 4
propUpdateInterval = 1000;
pbPath = nil;
protocol = 1;
deviceID = "device_200"
msgClient = msgClient or nil;
msgOpt = nil;
device = {test1=100 , test2=true}

watchDevices = nil

vDeviceList = {}

vDeviceStateList = {}
vDeviceStateWatchList = {}

allowCTUList = nil

about = {deviceID="device_100" , icon="http://localhost/deivce1/icon.png" , desc="ggff" , url="http://localhsot/deivce1/desc.html"}

backEnd = nil;
connected = false;

exitFlag = false;

function exitHandler() end

function connectedHandler() end

function readDeviceProps() end

function mqttHandler(client , topicName , payload) end

function subscribeTopics() end

function initDevice() end

function publishSimple(topic , payload , qos , retained)
    msgClient:publish(topic , payload , qos , retained or 0)
end

function subscribe(topicName , qos)
    msgClient:subscribe(topicName , 0)
end

function allCorrelativeDeviceReady()

    local isOk;

    for _,isOk in ipairs(vDeviceStateList) do

        if isOk == false then return false end
    end

    local tDevice

    for _,tDevice in ipairs(vDeviceList) do

        if #tDevice == 0 then return false end 
    end

    return true

end

function authenticationCTU(ctuAbout)

    if allowCTUList == nil then
        return true
    else

        local tCTUID
        for _,tCTUID in ipairs(allowCTUList) do
            if tCTUID == ctuAbout.deviceID then
                return true
            end
        end 
    end

    return false
end

function registerProp(propName, ...)
    device[propName] = nil;
    if backEnd then
        backEnd.registerProp(propName , ...)
        return true;
    end
    return false;
end 

function setProp(propName, value)
    local ok = backEnd.setProp(propName , value)
    if ok ~= -1 then
        device[propName] = value;
        return true
    end
    return false;
end 

function getProp(propName)
    local value = backEnd.getProp(propName)
    if value ~= nil then
        device[propName] = value;
        return true
    end
    return false;
end 

function hasProp(propName)

    if device[propName] ~= nil then
        return true
    else 
        return false
    end
end

function getPropByDeviceID(id , propName)
    if vDeviceList[topicName] then
        return vDeviceList[topicName].propName;
    end

    return nil
end

function exit()
    exitFlag = true
    --if backEnd.close then
        --backEnd.close();
    --end
    
    local deviceState = JSON.encode({deviceID=about.deviceID , online = false})
    publishSimple(about.deviceID.."/"..DEVICE_STATE , deviceState , 1 , 1)
    
    publishSimple(SYS_DEVICE_EXIT , about.deviceID , 1)

    msgClient:close();
    exitHandler()
    print(about.deviceID.." restart")
    node.restart()
end

function mqttMsgHandler(client , topicName , payload)

    print(topicName)

    if exitFlag then return end

    if topicName == (about.deviceID.."/"..SYS_LOAD_DEVICE_FUNCTION) then

        package.loaded[about.deviceID] = nil;
        require(about.deviceID);
        initDevice();
        print("update config deviceID:" , about.deviceID)
        return

    elseif topicName == (about.deviceID.."/"..SYS_EXIT) then

        exit();
        return

    elseif topicName == SYS_DEVICE_EXIT then

        local vDeviceID = payload

        print("device:"..vDeviceID.." exited")

        if vDeviceID ~= about.deviceID then
            vDeviceStateList[vDeviceID] = false;
        end

        return

    elseif (topicName == SYS_SERVICE_ONLINE) or (topicName == about.deviceID.."/"..SYS_SERVICE_ONLINE) then

        local payloadTable = JSON.decode(payload) 

        print("service online CTU: " , payloadTable.deviceID);

        if authenticationCTU(payloadTable) then
            publishSimple(payloadTable.deviceID.."/"..SYS_ABOUT , JSON.encode(about) , 2)
        else
            print("device: "..about.deviceID.."Refuse CTU: "..payloadTable.deviceID.." add")
        end
        return

    elseif topicName == about.deviceID.."/props/json" then

        local payloadTable = JSON.decode(payload) 

        if payloadTable then
            for key,value in pairs(payloadTable) do
                setProp(key , value);
            end
        end
        return

    elseif topicName == SYS_DEVICE_DATA_SOURCE_ONLINE then

        local vDeviceID = payload

        if vDeviceID == about.deviceID then return end

        print(vDeviceID.." data online")
        return

    elseif topicName == SYS_DEVICE_DATA_SOURCE_OFFLINE then

        local vDeviceID = payload

        if vDeviceID == about.deviceID then return end

        vDeviceList[vDeviceID] = {};

        --vDeviceStateList[vDeviceID] = false;
        print(vDeviceID.." data offline")
        return 

    elseif vDeviceList[topicName] then

        print(topicName)

        local payloadTable = JSON.decode(payload)

        vDeviceList[topicName] = payloadTable;
        --vDeviceStateList[topicName] = true;
        mqttHandler(topicName , payloadTable , qos , retained , dup , msgid , struct_id , struct_version)
        return;

    elseif vDeviceStateWatchList[topicName] then

        print(topicName)

        local deviceState = JSON.decode(payload) 

        print(deviceState.deviceID.." state changed  online:".. tostring(deviceState.online))

        vDeviceStateList[deviceState.deviceID] = deviceState.online;
        return
    end

    local payloadTable = JSON.decode(payload) 

    mqttHandler(client , topicName , payloadTable)
end

function subscribeSystemTopics()
    subscribe(about.deviceID.."/"..SYS_LOAD_DEVICE_FUNCTION , 0);
    subscribe(about.deviceID.."/"..SYS_EXIT , 2);
    subscribe(SYS_SERVICE_ONLINE, 2);
    subscribe(about.deviceID.."/"..SYS_SERVICE_ONLINE, 2);

    subscribe(about.deviceID.."/"..SYS_RELAOD_PROTO , 2);

    subscribe(about.deviceID.."/props" , 2);

    subscribe(about.deviceID.."/props/json" , 2);

    subscribe(about.deviceID.."/"..SYS_INNER.."/#" , 2); 
    
    subscribe(SYS_DEVICE_DATA_SOURCE_OFFLINE , 2);
    subscribe(SYS_DEVICE_DATA_SOURCE_ONLINE , 2);
    
    local tDevice

    if watchDevices ~= nil then
        for _,tDevice in ipairs(watchDevices) do

            vDeviceList[tDevice] = {}
            vDeviceStateList[tDevice] = false
            vDeviceStateWatchList[tDevice.."/"..DEVICE_STATE] = {deviceID=tDevice , state=false}
            
            subscribe(tDevice.."/"..DEVICE_STATE , 1)
            subscribe(tDevice , 1)
        end 
    end
end

function timerHandler()

    if exitFlag then 
        return 
    end

    local ok = 0;

    if ok ~= -1 then

        readDeviceProps()

        if msgClient then
        
            gpio.write(IO_LED, gpio.LOW)
            tmr.alarm(2,20,0,function()gpio.write(IO_LED, gpio.HIGH) end)
            
            publishSimple(about.deviceID , JSON.encode(device) , 1);
        end
    else
        if msgClient then
            publishSimple(SYS_DEVICE_DATA_SOURCE_OFFLINE , about.deviceID , 2)
        end
    end
end

function connectLostHandler(client)
    print("broker connect lost cause: "..tostring(client))
    connected = false

    connectBroker()
end

function mqttConnectedHandler(client)
    connected = true;
   
    print("connected device: " , about.deviceID)
    subscribeTopics();
    subscribeSystemTopics();
    
    publishSimple(SYS_ABOUT , JSON.encode(about) , 2)
    
    deviceState = JSON.encode({deviceID=about.deviceID , online = true})
    publishSimple(about.deviceID.."/"..DEVICE_STATE , deviceState , 2 , 1)

    connectedHandler()
end

function mqttFailHandler(client , reason)

    print("mqtt fail"..reason)

    tmr.alarm(1 , 3000 , 0 , function()
        connectBroker()
    end)
end


function connectBroker()

    print("start connect mqtt broker")
    connected = false
    local deviceState

    if msgClient ~= nil then
        msgClient:close()
    end

    if msgClient == nil then

       print("nodeMCU connet init "..about.deviceID)
        
        msgClient = mqttClient.Client(about.deviceID  , 10  , brokerConfs.userName , brokerConfs.password)

        msgClient:on("message" , mqttMsgHandler)
        msgClient:on("offline", connectLostHandler)

        deviceState = JSON.encode({deviceID=about.deviceID , online = false})

        msgClient:lwt(about.deviceID.."/"..DEVICE_STATE , deviceState ,  0 , 1)
    end  

    deviceState = JSON.encode({deviceID=about.deviceID , online = false})
    print("nodeMCU connet start")
    msgClient:connect(brokerConfs.addr , brokerConfs.port , 0 , 1 , mqttConnectedHandler , mqttFailHandler)
    print("nodeMCU conneting ..."..brokerConfs.addr..":"..brokerConfs.port)
end


function startDevice()

    if not inited then

        gpio.mode(IO_LED, gpio.OUTPUT)

        about.deviceID = deviceID

        inited = true;

        initDevice();

        connectBroker()

        if connected then
            timerHandler()
        end

        tmr.alarm(0 , propUpdateInterval , 1 , function()
            if connected then
                timerHandler()
            end
        end)
    end
end

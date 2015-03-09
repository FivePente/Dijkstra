package com.fivePente.dijkstra 
{
	import com.fivePente.dijkstra.Node;
	import flash.utils.Dictionary;
	
	/**
	 * @author Wang Jun
	 * @email  freelancer.as@gmail.com
	 * @date   2012/11/20 18:56
	 **/
	public class Graph
	{
		/** 
		 * @private
		 */
		public var input:Vector.<Node>;
		
		/** 
		 * @private
		 */
		public var costMap:Dictionary;
		
		/** 
		 * @private
		 */
		public var pathMap:Dictionary;
		
		public function Graph() 
		{
			input = new Vector.<Node>;
			
			pathMap = new Dictionary;
			costMap = new Dictionary;
		}
		
		/**
		 * 添加一个节点到图中
		 * 
		 * @param	node 节点对象
		 */
		public function addNode(node:Node):void
		{
			input.push(node);
		}
		
		
		/**
		 * 从图中移除一个节点
		 * 
		 * @param	node 要移除的节点
		 */
		public function removeNode(node:Node):void
		{
			input.splice(input.indexOf(node) , 1);
		}
		
		
		
		public function scanPath(start:Node , end:Node):void
		{
			Dijkstra.updatePath(this , start);
		}
		
		
		/**
		 * 获取图中某点到其他可通点的最短路径
		 * 如果设置end则只返回start点到end点的路径
		 * 
		 * @param	start 起点
		 * @param	end   终点
		 * @return  能连通则返回一个路径列表，不能连通返回一个空的列表
		 */
		public function getPath(start:Node , end:Node = null):Vector.<Vector.<Node>>
		{
			var tVec:Vector.<Vector.<Node>> = new Vector.<Vector.<Node>>;
			
			if (end == null)
			{
				for each(var tPath:Vector.<Node> in pathMap)
				{
					if (tPath)
					{
						tVec.push(tPath);
					}
				}
				
			}else {
				
				tVec.push(pathMap[start.toString() + "-" + end.toString()]);
			}
			
			return tVec;
		}
		
		
		/**
		 * 计算并缓存从起点到图中其他点间的路径及反向路径 如: [A,D,B,C]  [C,B,D,A];
		 * 如果不能连通保存null
		 * 
		 * @param start 起始点
		 */
		public function updateMap(start:Node):void
		{
			var tStart:Vector.<Node> = new Vector.<Node>;
			tStart.push(start);	
			
			for (var i:int = 0 ; i < input.length ; i++)
			{
				var tNode:Node = input[i] as Node;
				
				var tNodeArr:Vector.<Node> = new Vector.<Node>;
				
				tNodeArr.push(tNode);
				
				if (tNode.getID() != start.getID())
				{
					if (tNode.pathNodes.length > 1) {
						
						pathMap[start.toString() + "-" + tNode.toString()] = tNode.pathNodes.concat(tNodeArr);
						pathMap[tNode.toString() + "-" + start.toString()] = tNode.pathNodes.concat(tStart).reverse();
						
						//trace(start.toString() + "-" + tNode.toString() + "__" + pathMap[start.toString() + "-" + tNode.toString()])
						
					}else if (tNode.pathNodes.length == 1) {
						
						if (tNode.hasLink(start))
						{
							pathMap[start.toString() + "-" + tNode.toString()] = tNode.pathNodes.concat(tNodeArr);
							pathMap[tNode.toString() + "-" + start.toString()] = tNode.pathNodes.concat(tStart).reverse();
							
							//trace(start.toString() + "-" + tNode.toString() + "__" + pathMap[start.toString() + "-" + tNode.toString()])
							
						}else {
							
							pathMap[start.toString() + "-" + tNode.toString()] = null;
							pathMap[tNode.toString() + "-" + start.toString()] = null;
						}
						
					}else {
						
						pathMap[start.toString() + "-" + tNode.toString()] = null;
						pathMap[tNode.toString() + "-" + start.toString()] = null;
					}
				}
			}
		}
		
		
		/**
		 * 析构方法
		 */
		public function cleanup():void
		{
			input.length = 0;
			input = null;
			
			for each(var tKey:* in costMap)
			{
				delete costMap[tKey];
			}
			
			costMap = null;
		}
	}
}
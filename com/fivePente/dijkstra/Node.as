package com.fivePente.dijkstra 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author Wang Jun
	 * @email  freelancer.as@gmail.com
	 * @date   2012/11/20 18:17
	 **/
	public class Node
	{
		/** 
		 * @private
		 */
		public var id:uint = 0;
		
		/** 
		 * @private
		 */
		public var isOpen:Boolean;
		
		/** 
		 * @private
		 */
		public var scan:Boolean;
		
		/** 
		 * @private
		 */
		public var cost:Number = 0;
		
		/** 
		 * @private
		 */
		public var pathNodes:Vector.<Node>;
		
		public var mLinkNodes:Vector.<Node>;
		
		public var mLinkCost:Dictionary
		
		
		public function Node($id:uint)
		{
			id = $id;
			
			isOpen = true;
			
			pathNodes = new Vector.<Node>;
			mLinkCost = new Dictionary;
			mLinkNodes = new Vector.<Node>;
		}
		
		public function getID():uint
		{
			return id;
		}
		
		
		/**
		 * 同一个节点建立连接，这是单向连接
		 * 如果需要可以设置link为true实现双向连接
		 * 
		 * 
		 * @param	node 需要连接的节点
		 */
		public function addLink(node:Node):void
		{
			mLinkNodes.push(node);
			mLinkCost[node] = 1;
		}
		
		
		/**
		 * 断开一个连接
		 * 可选择单相断开连接还是双向断开连接
		 * 
		 * @param	node 需要断开连接的节点
		 */ 
		public function removeLink(node:Node):void
		{
			mLinkNodes.splice(mLinkNodes.indexOf(node) , 1);
			
			delete mLinkCost[node];
		}
		
		
		/**
		 * 是否已经同指定节点建立连接
		 * 
		 * @param  node 节点
		 * @return 已建立节点返回true 否则返回false
		 */
		public function hasLink(node:Node):Boolean
		{
			return mLinkNodes.indexOf(node) > -1;
		}
		
		
		/**
		 * 清理掉所有连接节点的双向连接
		 */
		public function clearAllLink():void
		{
			var tL:int = mLinkNodes.length;
			
			while(tL)
			removeLink(mLinkNodes[--tL]);
		}
		
		public function toString():String
		{
			return "Node_" + id;
		}
		
		/**
		 * 析构方法
		 */
		public function cleanup():void
		{
			clearAllLink();
			
			pathNodes.length = 0;
			pathNodes = null;
			
			mLinkNodes.length = 0;
			mLinkNodes = null;
			
			mLinkCost = null;
		}
	}
}
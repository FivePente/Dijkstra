package com.fivePente.dijkstra 
{
	import com.fivePente.dijkstra.Node;
	import flash.utils.Dictionary;
	
	/**
	 * @author Wang Jun
	 * @email  freelancer.as@gmail.com
	 * @date   2012/11/20 18:31
	 **/
	public class Dijkstra 
	{
		/** 
		 * @private 
		 */
		public function Dijkstra() {throw new Error("Dijkstra类不能实例化")};
		
		/**
		 * 更新路径
		 * 
		 * @param	map 图对象
		 * 
		 * @see com.fivePente.dijkstra.Map
		 * @see com.fivePente.dijkstra.Node
		 */
		public static function updatePath(map:Graph , startNode:Node):void
		{
			var tNodes:Vector.<Node> = map.input;
			
			var tL:int = tNodes.length;
			var tNode:Node;
			var i:int = tL;
			
			var tCost:Number = Number.MAX_VALUE;
			var tCostMap:Dictionary = map.costMap;
			var tMinCostNode:Node;
			
			while(i)
			{
				tNode = tNodes[--i];
				
				if (tNode.id != startNode.id)
				{
					tNode.pathNodes.length = 0;
					tNode.pathNodes.push(startNode);
				}
				
				tNode.scan = true;
				tNode.cost = Number.MAX_VALUE;
			}
			
			startNode.scan = false;
			startNode.pathNodes.length = 0
			startNode.cost = 0;
			updateLinksCost(startNode);
			
			while (--tL)
			{
				tCost = Number.MAX_VALUE;
				
				for each(tNode in tNodes)
				{
					if (tNode.isOpen && tNode.scan && tNode.cost < tCost)
					{
						tMinCostNode = tNode;
						tCost = tNode.cost;
					}
				}
				
				if (tMinCostNode)
				{
					tMinCostNode.scan = false;
					updateLinksCost(tMinCostNode);
					tMinCostNode = null;
				}
			}
			
			map.updateMap(startNode);
		}
		
		
		private static function updateLinksCost(node:Node):void
		{
			var tL:int = node.mLinkNodes.length;
			
			var tNode:Node;
			
			var tCost:Number = 0;
			
			while(tL--)
			{
				tNode = node.mLinkNodes[tL];
				
				tCost = node.mLinkCost[tNode] + node.cost;
				
				if (tNode.isOpen && tNode.scan && tCost < tNode.cost || tNode.cost == 0)
				{
					tNode.cost = tCost;
					
					updateNodePath(tNode , node);
				}
			}
		}
		
		
		private static function updateNodePath(currentNode:Node , targetNode:Node):void
		{
			currentNode.pathNodes.length = 0;
			
			currentNode.pathNodes = targetNode.pathNodes.concat();
			
			currentNode.pathNodes.push(targetNode);
		}
	}
}

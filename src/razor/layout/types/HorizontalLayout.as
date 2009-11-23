package razor.layout.types
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import razor.core.Metrics;
	
	public class HorizontalLayout implements ILayoutImpl
	{
		/** The total visible width after the content has been positioned. */
		public var visibleWidth:Number = 0;
		/** The total visible height after the content has been positioned. */
		public var visibleHeight:Number = 0;
		
		protected var _horizontalGap:Number = 2;
		
		public function HorizontalLayout()
		{
		}
		
		public function set horizontalGap(v:Number):void
		{
			_horizontalGap = v;
		}
		
		public function get horizontalGap():Number
		{
			return _horizontalGap;
		}
		
		public function doLayout(children:Array, layoutDatas:Dictionary, width:Number, height:Number, margins:Metrics=null):void
		{
			if (margins == null)
				margins = new Metrics();
				
			var xx:Number = margins.l;
			var yy:Number = margins.t;
			var d:DisplayObject;
			var gap:Number = horizontalGap;
			
			visibleHeight = yy + margins.b;
			for (var i:int = 0; i < children.length; i++)
			{
				d = children[i] as DisplayObject;
				d.x = xx;
				d.y = yy;
				visibleHeight = Math.max(visibleHeight, d.y + d.height + margins.r);
				xx += d.width + gap;
			}
			
			visibleWidth = xx + margins.r;
		}
		
		/**
		 * Get the visible size after a layout operation.
		 * These dimensions will ignore any invisible components
		 * @return A Metrics object containing the width and height.
		 */
		public function getVisibleMetrics():Metrics
		{
			return  new Metrics(visibleWidth, visibleHeight);
		}
	}
}
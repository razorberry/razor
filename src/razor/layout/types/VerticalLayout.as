package razor.layout.types
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import razor.core.Metrics;
	
	public class VerticalLayout implements ILayoutImpl
	{
		/** The total visible width after the content has been positioned. */
		public var visibleWidth:Number = 0;
		/** The total visible height after the content has been positioned. */
		public var visibleHeight:Number = 0;
		
		protected var _verticalGap:Number = 2;
		
		public function VerticalLayout()
		{
		}
		
		public function set verticalGap(v:Number):void
		{
			_verticalGap = v;
		}
		
		public function get verticalGap():Number
		{
			return _verticalGap;
		}

		public function doLayout(children:Array, layoutDatas:Dictionary, width:Number, height:Number, margins:Metrics=null):void
		{
			if (margins == null)
				margins = new Metrics();
				
			var xx:Number = margins.l;
			var yy:Number = margins.t;
			var d:DisplayObject;
			var gap:Number = verticalGap;
			visibleWidth = xx + margins.r;
			for (var i:int = 0; i < children.length; i++)
			{
				d = children[i] as DisplayObject;
				d.x = xx;
				d.y = yy;
				visibleWidth = Math.max(visibleWidth, d.x + d.width + margins.r);
				yy += d.height + gap;
			}
			
			visibleHeight = yy + margins.b;
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
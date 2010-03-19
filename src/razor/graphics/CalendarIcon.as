package razor.graphics
{
	import razor.core.StyledContainer;
	
	/**
	 * Draw a calendar icon
	 * @private
	 */
	public class CalendarIcon extends StyledContainer
	{
		override protected function layout():void
		{
			graphics.clear();
			
			if (__width > 0 && __height > 0)
			{
				var fill:uint = __style.border >= 0 ? __style.border : 0;
				graphics.lineStyle(1,fill,1,false)
				graphics.beginFill(0x66ffff);
				graphics.drawRect(__width*1/10, __height*2/10, __width*8/10, __height*7/10);
				graphics.endFill();
				graphics.beginFill(0xffffff);
				graphics.drawRect(__width*1/10, __height*4/10, __width*8/10, __height*5/10);
				graphics.endFill();
				graphics.beginFill(0xffffff);
				graphics.drawRect(__width*1/10, __height *13/20, __width*8/10, __height*5/20);
				graphics.endFill();
				
				graphics.drawRect(__width*7/20, __height*4/10, __width*3/10, __height*5/10);
				graphics.endFill();
			}
		}
	}
}
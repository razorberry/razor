package razor.graphics
{
	import razor.skins.RenderLayer;
	import flash.display.Graphics;

	/**
	 * Draw a checkbox check..
	 * @private
	 */
	public class Check extends RenderLayer
	{
		override protected function layout():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var fill:uint = __style.border >= 0 ? __style.border : 0;
			g.beginFill(fill);
			var h:Number = __height - 4; // - __style.bevel * 2;
			var w:Number = __width - 4; // - __style.bevel * 2;
			var he:Number = h/8;
			var we:Number = w/8;
			var xx:Number = 2; // __style.bevel;
			
			g.moveTo(xx+ we, xx+ h/2);
			g.lineTo(xx+ we*2, xx+ h/2);
			g.lineTo(xx+ w/2, xx+ he*5);
			g.lineTo(xx+ we*6, xx+ he);
			g.lineTo(xx+ we*7, xx+ he);
			// base line
			g.lineTo(xx+ w/2 + he/2, xx+ he*7);
			g.lineTo(xx+ w/2 - he/2, xx+ he*7);
			//
			g.lineTo(xx+ we, xx+ h/2);
			g.endFill();
		}
	}
}
package razor.graphics
{
	import razor.skins.RenderLayer;
	import flash.display.Graphics;

	/**
	 * Draw the blob in the middle of a radio button..
	 * @private
	 */
	public class Radio extends RenderLayer
	{
		override protected function layout():void
		{
			graphics.clear();
			var z:Number = __width/4;
			drawRect(z,z,__width-z*2,__height-z*2, __style.roundedness - z, __style.border >= 0 ? __style.border : 0, 100);
		}
	}
}
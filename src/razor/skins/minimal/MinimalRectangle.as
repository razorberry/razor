package razor.skins.minimal
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.StyledContainer;
	import razor.utils.ColorUtils;
	
	public class MinimalRectangle extends StyledContainer implements IBordered
	{
		override protected function layout():void
		{
			if (isNaN(__width) || isNaN(__height)) return;
			
			graphics.clear();
			
			if (__style.opacity <= 0) return;
			
			var colour:uint = __style.baseColor;
			// Colour modifiers:
			if (__style.modifyBrightness != 0)
				colour = ColorUtils.brighten(colour, __style.modifyBrightness);
			if (__style.fade != 0)
				colour = ColorUtils.fade(colour, __style.fade/100);
			
			var c:Array = [colour, ColorUtils.brighten(colour,(-0.05*__style.variance))];
			
			var r:Object;
			if (__style.roundedness is Array)
				r = { tl: __style.roundedness[0], tr: __style.roundedness[1], bl: __style.roundedness[2], br: __style.roundedness[3] };
			else
				r = { tl: __style.roundedness, tr: __style.roundedness, bl: __style.roundedness, br: __style.roundedness };
			
			graphics.lineStyle(__style.borderThickness, __style.border, __style.opacity);
			var m:Matrix = new Matrix();
			m.createGradientBox(__width,__height,Math.PI/2,0,0);
			graphics.beginGradientFill(GradientType.LINEAR, c, [1,1], [Math.max((__style.inset ? (10/__height) : 1-(10/__height))*0xff,0xe0),0xff], m);
			if (__style.roundedness == 0)
				graphics.drawRect(0,0,__width,__height);
			else
				graphics.drawRoundRectComplex(0,0,__width,__height,r.tl,r.tr,r.bl,r.bl);
			graphics.endFill();
		}
		/**
		 * Get the inner dimensions for this graphic
		 * @private
		 * @return	A Metrics instance
		 */
		public function getBorderMetrics():Metrics
		{
			return new Metrics();
		}
	}
}
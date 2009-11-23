/*****************************************************************************
* Razor Component Framework for ActionScript 3.
* Copyright 2009 Ashley Atkins (www.razorberry.com)
* 
* This file is part of the Razor Component Framework, which is made available
* under the MIT License.
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*******************************************************************************/

package razor.skins.plastic
{
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	
	import razor.core.Metrics;
	import razor.skins.RenderLayer;
	import razor.utils.ColorUtils;
	
	/**
	 * Draw a stylized background rectangle.
	 * @private
	 */
	public class Rectangle extends RenderLayer
	{
		public function Rectangle()
		{
			
		}
		
		override protected function layout():void
		{
			if (isNaN(__width) || isNaN(__height)) return;
			
			//trace("Rectangle.layout");
			graphics.clear();
			
			if (__style.opacity <= 0) return;
			
			var colour:uint = __style.baseColor;
			// Colour modifiers:
			if (__style.modifyBrightness != 0)
				colour = ColorUtils.brighten(colour, __style.modifyBrightness);
			if (__style.fade != 0)
				colour = ColorUtils.fade(colour, __style.fade/100);
			
			// Main fill:
			var c:Array = [colour, ColorUtils.brighten(colour,(0.1*__style.variance))];
			// Bevelled edge:
			var a:Boolean = __style.inset;
			var d:Array = [ColorUtils.brighten(colour, (a ? (-0.2*__style.variance) : (0.2*__style.variance))), ColorUtils.brighten(colour,(a ? (0.1*__style.variance) : (-0.1*__style.variance)))];
			
			var r:*;
			if (__style.roundedness is Array)
				r = { tl: __style.roundedness[0], tr: __style.roundedness[1], bl: __style.roundedness[2], br: __style.roundedness[3] };
			else
				r = __style.roundedness;
			
			
			if (__style.bevel > 0 || __style.bevel is Array)
			{
				//trace("** bevel");
				var bt:* = __style.borderThickness;
				drawRect(0,0,__width,__height,r,d,100,90,null, null,__style.border,bt);
				var bev:* = __style.bevel;
				var b:Array;
				if ((bev is Array))
					b = bev.concat();
				else
					b = [bev, bev, bev, bev];
				
				var r2:Object;
				if (r is Number || r is int || r is uint)
				{
					r2 = { tl: r-Math.max(b[0],b[2]), tr: r-Math.max(b[0],b[3]), bl: r-Math.max(b[1],b[2]), br: r-Math.max(b[1],b[3]) };
					//r2 = r-b;
				}
				else
				{
					r2 = { tl: r.tl-Math.max(b[0],b[2]), tr: r.tr-Math.max(b[0],b[3]), bl: r.bl-Math.max(b[1],b[2]), br: r.br-Math.max(b[1],b[3]) };
				}
				
				
				//trace("** fill");
				
				for each (var foo:Number in b)
					foo += bt;
				
				drawRect(b[2],b[0],__width-b[2]-b[3],__height-b[0]-b[1],r2,c,100,90,null,null,-1);
			}
			else
			{
				//trace("** fill");
				drawRect(0,0,__width,__height,r,c,100,90,null,null,__style.border,__style.borderThickness);
			}
			
			if (__style.shadow > 0)
			{
				var fa:Array = filters;
				var ds:DropShadowFilter;
				
				for each (var filter:BitmapFilter in filters)
				{
					if (filter is DropShadowFilter)
					{
						ds = filter as DropShadowFilter;
					}
				}
				
				if (ds == null)
				{
					ds = new DropShadowFilter(__style.shadow, 0-__style.azimuth, 0, 0.3);
					fa.push(ds);
				}
					
				ds.distance = __style.inset ? __style.shadow * 2 : __style.shadow;
				ds.angle = 0-__style.azimuth;
				ds.inner = __style.inset;
				ds.alpha = __style.inset ? 0.15 : 0.3;
				
				filters = fa;
			}
			else
			{
				filters = [];
			}
				
			if (__style.opacity < 1)
				alpha = __style.opacity;
			else
				alpha = 1;
		}
		
		override public function getBorderMetrics():Metrics
		{
			var r:Number = __style.roundedness is Array ? __style.roundedness[0] : __style.roundedness;
			var z:Number = __style.bevel + r/4;
			return new Metrics(0,0,z,z,z,z);
		}
	}
}
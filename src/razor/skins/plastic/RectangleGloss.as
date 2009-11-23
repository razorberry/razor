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
	import razor.skins.RenderLayer;

	/**
	 * Draw the gloss that will be overlayed on many styled containers
	 * @private
	 */
	public class RectangleGloss extends RenderLayer
	{
		override protected function layout():void
		{
			if (isNaN(__width) || isNaN(__height)) return;
			
			graphics.clear();
			
			if (__style.opacity <= 0) return;
			
			var r:*, tl:Number, tr:Number, h:Number;
			if (__style.roundedness is Array)
			{
				r = { tl: __style.roundedness[0], tr: __style.roundedness[1], bl: __style.roundedness[2], br: __style.roundedness[3] };
				tl = (r.tl - 2 < 0) ? 0 : (r.tl - 2);
				tr = (r.tr - 2 < 0) ? 0 : (r.tr - 2);
				var z:Number = Math.max(r.tl, r.tr);
				h = z < 2 ? Math.min(6, __height/2) : (z*3 > __height / 2 ? __height / 2 : z*3);
			}
			else
			{
				r = __style.roundedness;
				tl = tr = (r - 2 < 0) ? 0 : (r - 2);
				h = r < 2 ? Math.min(6, __height/2) : (r*3 > __height / 2 ? __height / 2 : r*3);
			}
			var g:Number = __style.glossiness * __style.opacity;
			//trace("** gloss "+g);
			drawRect(2,1,__width - 4, h, {tl: tl, tr: tr, bl: 0, br: 0}, [0xFFFFFF,0xFFFFFF,0xFFFFFF], [g,0.8*g,0.2*g], 90, "linear", [0x0,0x40,0xFF]);
		}
	}
}
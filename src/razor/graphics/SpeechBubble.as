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

package razor.graphics 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Utility class to draw a speech bubble.
	 */
	public final class SpeechBubble
	{
		/**
		 * Draw a speech bubble with the drawing API
		 * @param	target	The sprite in which to draw
		 * @param	rect	A Rectangle instance defining the position and size of the bubble
		 * @param	cornerRadius	The radius of the corners of the bubble (in px)
		 * @param	point	A Point instance defining the position of the point of the speech bubble.
		 */
		public static function drawSpeechBubble(target:Sprite, rect:Rectangle, cornerRadius:Number, point:Point):void
		{
			var g:Graphics = target.graphics;
			var r:Number = cornerRadius;
			
			var x:Number = rect.x;
			var y:Number = rect.y;
			var w:Number = rect.width;
			var h:Number = rect.height;
			var px:Number = point.x;
			var py:Number = point.y;
			var min_gap:Number = 20;
			var hgap:Number = Math.min(w - r - r, Math.max(min_gap, w / 5));
			var left:Number = px <= x + w / 2 ? 
				 (Math.max(x+r, px))
				:(Math.min(x + w - r - hgap, px - hgap));
			var right:Number = px <= x + w / 2?
				 (Math.max(x + r + hgap, px+hgap))
				:(Math.min(x + w - r, px));
			var vgap:Number = Math.min(h - r - r, Math.max(min_gap, h / 5));
			var top:Number = py < y + h / 2 ?
				 Math.max(y + r, py)
				:Math.min(y + h - r - vgap, py-vgap);
			var bottom:Number = py < y + h / 2 ?
				 Math.max(y + r + vgap, py+vgap)
				:Math.min(y + h - r, py);
					
			//bottom right corner
			var a:Number = r - (r*0.707106781186547);
			var s:Number = r - (r*0.414213562373095);
			
			g.moveTo ( x+w,y+h-r);
			if (r > 0)
			{
				if (px > x+w-r && py > y+h-r && Math.abs((px - x - w) - (py - y - h)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + w - r, y + h);
				}
				else
				{
					g.curveTo( x + w, y + h - s, x + w - a, y + h - a);
					g.curveTo( x + w - s, y + h, x + w - r, y + h);
				}
			}
	
			if (py > y + h && (px - x - w) < (py - y -h - r) && (py - y - h - r) > (x - px))
			{
				// bottom edge
				g.lineTo(right, y + h);
				g.lineTo(px, py);
				g.lineTo(left, y + h);
			}
			
			g.lineTo ( x+r,y+h );
			
			//bottom left corner
			if (r > 0)
			{
				if (px < x + r && py > y + h - r && Math.abs((px-x)+(py-y-h)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x, y + h - r);
				}
				else
				{
					g.curveTo( x+s,y+h,x+a,y+h-a);
					g.curveTo( x, y + h - s, x, y + h - r);
				}
			}
	
			if (px < x && (py - y - h + r) < (x - px) && (px - x) < (py - y - r) )
			{
				// left edge
				g.lineTo(x, bottom);
				g.lineTo(px, py);
				g.lineTo(x, top);
			}
			
			g.lineTo ( x,y+r );
			
			//top left corner
			if (r > 0)
			{
				if (px < x + r && py < y + r && Math.abs((px - x) - (py - y)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + r, y);
				}
				else
				{
					g.curveTo( x,y+s,x+a,y+a);
					g.curveTo( x + s, y, x + r, y);
				}
			}
			
			if (py < y && (px - x) > (py - y + r) && (py - y + r) < (x - px + w))
			{
				//top edge
				g.lineTo(left, y);
				g.lineTo(px, py);
				g.lineTo(right, y);
			}
			
			g.lineTo ( x + w - r, y );
			
			//top right corner
			if (r > 0)
			{
				if (px > x + w - r && py < y + r && Math.abs((px - x - w) + (py - y)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + w, y + r);
				}
				else
				{
					g.curveTo( x+w-s,y,x+w-a,y+a);
					g.curveTo( x + w, y + s, x + w, y + r);
				}
			}
			
			if (px > x + w && (py - y - r) > (x - px + w) && (px - x - w) > (py - y - h + r) )
			{
				// right edge
				g.lineTo(x + w, top);
				g.lineTo(px, py);
				g.lineTo(x + w, bottom);
			}
			g.lineTo ( x+w,y+h-r );
	
		}
	}
}

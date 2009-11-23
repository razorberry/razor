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

package razor.skins
{
	import razor.core.StyledContainer;
	import razor.core.InteractiveContainer;
	import razor.core.IBordered;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import razor.core.Metrics;
	import flash.display.Graphics;

	/**
	 * StyledContainer specifically intended for drawn graphics and no other functionality.
	 */
	public class RenderLayer extends StyledContainer
		implements IBordered
	{
		public function RenderLayer()
		{
			//super(true);
			//tabEnabled = false;
			mouseEnabled = false;
		}
		
		/**
		* Draw a stylized rounded rectangle.
		* @param	x	The X position of the top-left corner
		* @param	y	The Y position of the top-left corner
		* @param	w	The width of the rectangle
		* @param	h	The height of the rectangle
		* @param	r	The radius of the rounded corners, can be a number or object of the form {tl: X, tr: X, bl: X, br: X}
		* @param	c	The fill color, can be a number or an array of colors in order to draw a gradient
		* @param	alpha	The fill alpha, can be a number or an array of alphas corresponding to the array of colors.
		* @param	rot		The rotation of the gradient in degrees, or the gradient matrix object:flash.geom.Matrix;
		* @param	gradient	The type of gradient, "radial" or "linear".
		* @param	ratios		The ratio array of the gradient.
		* @param	border		The color of the border, (use -1 or undefined for no border)
		* @param	thickness	The thickness of the border
		*/
		protected function drawRect(x:Number, y:Number, w:Number, h:Number,
								  r:* = 0,c:* = -1,alpha:* = 1,rot:* = 0,
								  gradient:String = "linear",ratios:Array = null,border:Number = -1,thickness:Number = 1):void
		{
			if (!(w > 0 && h > 0))
				return;
				
			//trace("drawrect: "+w+","+h);
			if (border >= 0)
			{
				// TODO: increase r proportional to border thickness
				//trace("  (drawing border)");
				drawRect(x,y,w,h,r,border,1,null,null,null,-1);
			}
			
			var g:Graphics = graphics;
			
			var rbr:Number, rbl:Number, rtl:Number, rtr:Number;
			if (!(r is Number || r is int || r is uint)) {
				rbr = r.br; //bottom right corner
				rbl = r.bl; //bottom left corner
				rtl = r.tl; //top left corner
				rtr = r.tr; //top right corner
			}
			else
			{
				rbr = rbl = rtl = rtr = r;
			}
			
			// Restrict roundedness to positive numbers
			rtl = rtl < 0 ? 0 : rtl;
			rtr = rtr < 0 ? 0 : rtr;
			rbl = rbl < 0 ? 0 : rbl;
			rbr = rbr < 0 ? 0 : rbr;
			
			// Restrict roundedness to available space only
			var m:Number;
			if (rtl + rtr > w)
			{
				m = w/(rtl + rtr);
				rtl *= m;
				rtr *= m;
			}
			
			if (rbl + rbr > w)
			{
				m = w/(rbl + rbr);
				rbl *= m;
				rbr *= m;
			}
			
			if (rtl + rbl > h)
			{
				m = h/(rtl + rbl);
				rtl *= m;
				rbl *= m;
			}
			
			if (rtr + rbr > h)
			{
				m = h/(rtr + rbr);
				rtr *= m;
				rbr *= m;
			}
			
			// if color is an object then allow for complex fills
			if(!(c is Number || c is int || c is uint))
			{
				var alphas:Array;
				if (!(alpha is Array))
					alphas = [alpha,alpha];
				else
					alphas = alpha;
				
				if (ratios == null)
					ratios = [ 0, 0xff ];
	
				var sh:Number = h *.7
				var matrix:Matrix = new Matrix();
				if ((rot is Number || rot is int || rot is uint))
				{
					matrix.createGradientBox(w,h,(rot * Math.PI/180),0,0);
					//var matrix = {matrixType:"box", x:-sh, y:sh, w:w*2, h:h*4, r:rot * 0.0174532925199433 }
				}
				else if (rot is Matrix)
					matrix = rot;
			
				//debug(alphas+"\n"+ratios+"\n"+matrix);
				if (gradient == "radial")
					g.beginGradientFill( GradientType.RADIAL, c, alphas, ratios, matrix );
				else
					g.beginGradientFill( GradientType.LINEAR, c, alphas, ratios, matrix );
	
			}
			else if (c >= 0)
			{
				g.beginFill(c, alpha);
			}
	
			if (border >= 0)
			{
				x += thickness;
				y += thickness;
				w -= thickness*2;
				h -= thickness*2;
				// Modify roundness depending on border thickness
				rtl -= thickness;
				rtr -= thickness;
				rbl -= thickness;
				rbr -= thickness;
			}
	
			// No negative rounded corners
			rtl = rtl < 0 ? 0 : rtl;
			rtr = rtr < 0 ? 0 : rtr;
			rbl = rbl < 0 ? 0 : rbl;
			rbr = rbr < 0 ? 0 : rbr;
	
			g.drawRoundRectComplex(x,y,w,h,rtl,rtr,rbl,rbr);
			
			if (c >= 0)
				g.endFill();
		}
		
		/**
		* Draw a simple rectangle between two points
		* @param	x1	The X position of the top-left corner
		* @param	y1	The Y position of the top-left corner
		* @param	x2	The X position of the bottom-right corner
		* @param	y2	The Y position of the bottom-right corner
		*/
		protected final function drawSimpleRect(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			graphics.drawRect(x1,y1,x2-x1,y2-y1);
		}
		
		/**
		* Get the inner dimensions for this graphic
		* @private
		* @return	An object of the form {l: X, r:X, t:X, b:X}
		*/
		public function getBorderMetrics():Metrics
		{
			return new Metrics();
		}
	}
}
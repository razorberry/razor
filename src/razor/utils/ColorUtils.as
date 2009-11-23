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

package razor.utils 
{
	/**
	 * Class containing a variety of color utility methods.
	 */
	public class ColorUtils 
	{
		/**
		* Blend two colors with a scalar ratio.
		* @param	first	The first color
		* @param	second	The second color
		* @param	ratio	The ratio of the second color to blend, .5 = equal ratio, .9 = 1:9, .2 = 8:2
		* @return	The color value as a uint.
		*/
		public static function blend(first:uint, second:uint, ratio:Number):uint
		{
			var a:Number, b:Number, c:Number;
			a = ((first & 0xff)*(1-ratio) + (second & 0xff)*ratio);
			b = (((first & 0xff00)>>8)*(1-ratio) + ((second & 0xff00)>>8)*ratio);
			c = (((first & 0xff0000)>>16)*(1-ratio) + ((second & 0xff0000)>>16)*ratio);
			
			return uint((a) | (b <<8) | (c <<16));
		}
		
		/**
		* Brighten (or darken) a color by a scalar amount.
		* @param	color	The color to brighten/darken.
		* @param	modifier	The scalar to modify the brightness, 0 = no change, ie. 0.9, 1.1
		* @return	The modified color
		*/
		public static function brighten(color:uint, modifier:Number):Number
		{
			var z:Number = 0xff * modifier;
			var a:Number, b:Number, c:Number;
			a = (a=(color & 0xff) + z) > 0xFF ? 0xFF : ( a < 0 ? 0 : a);
			b = (b=((color & 0xff00)>>8) + z) > 0xFF ? 0xFF : ( b < 0 ? 0 : b);
			c = (c=((color & 0xff0000)>>16) + z) > 0xFF ? 0xFF : ( c < 0 ? 0 : c);
			
			return ((a) | (b <<8) | (c <<16));
		}
		
		/**
		* Desaturate a color by a scalar amount. (0-1)
		* This isn't a real desaturation, but blends the color with a neutral grey.
		* @param	color	The color to desaturate
		* @param	percent	The percentage of desaturation
		* @return	The desaturated color
		*/
		public static function desaturate(color:uint, modifier:Number):Number
		{
			return blend(color, 0x808080, modifier);
		}
		
		/**
		* Fades a color by a scalar amount. (0-1)
		* Basically just blends the color with white.
		* @param	color	The color to fade
		* @param	percent	The percentage of fade
		* @return	The faded color
		*/
		public static function fade(color:uint, modifier:Number):Number
		{
			return blend(color, 0xFFFFFF, modifier);
		}
	}
	
}
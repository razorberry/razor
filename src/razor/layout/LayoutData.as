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

package razor.layout
{
	/**
	 * Class to describe the layout of a container within a Layer.
	 * @see Layer
	 */
	public class LayoutData
	{
		///////////////////////////////////////////////
		// STATIC CONSTANTS
		
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_RIGHT:String = "right";
		public static const ALIGN_TOP:String = "top";
		public static const ALIGN_BOTTOM:String = "bottom";
		
		/** Position of this container is relative to the last */
		public static const POS_RELATIVE:String = "relative";
		/** Position of this container is below the last */
		public static const POS_BELOW:String = "below";
		/** Position of this container is to the right of the last */
		public static const POS_RIGHT:String = "right";
		/** Position of this container is absolute (relative to (0,0) in the Layer) */
		public static const POS_ABSOLUTE:String = "absolute";
		
		/** Defines a measurement to be a percentage of the whole */
		public static const TYPE_PERCENT:String = "percent";
		/** Defines a measurement to be in pixels */
		public static const TYPE_PIXELS:String = "pixels";
		
		///////////////////////////////////////////////
		// Layout settings
		
		/** The left padding of this container */
		public var padding_l:Number = 3; // 3
		/** The top padding of this container */
		public var padding_t:Number = 5; // 5
		/** The right padding of this container */
		public var padding_r:Number = 3; // 3
		/** The bottom padding of this container */
		public var padding_b:Number = 5; // 5
		
		/** The horizontal align of this container */
		public var hAlign:String = ALIGN_LEFT;
		/** The vertical align of this container */
		public var vAlign:String = ALIGN_TOP;
		
		/** Determines how the Layer will position this component 
		 * @see #POS_RELATIVE
		 * @see #POS_BELOW
		 * @see #POS_RIGHT
		 * @see #POS_ABSOLUTE
		 */
		public var position:String = POS_RELATIVE;
		
		/** x-position */
		public var x:Number = 0;
		/** y-position */
		public var y:Number = 0;
		
		/** width.. can be in pixels or percentage of the parent container.
		 * @see #widthType
		 */
		public var width:Number = 0;
		/** height.. can be in pixels or percentage of the parent container.
		 * @see #heightType
		 */
		public var height:Number = 0;
		
		/** Specifies whether the width measurement is in pixels or a percentage of the whole */
		public var widthType:String = TYPE_PIXELS;
		/** Specifies whether the height measurement is in pixels or a percentage of the whole */
		public var heightType:String = TYPE_PIXELS;
		
		//
		
		public function LayoutData(position:String = null, width:Number = 0, height:Number = 0, widthType:String = null, heightType:String = null, hAlign:String = null, vAlign:String = null)
		{
			if (position != null) this.position = position;
			if (width > 0) this.width = width;
			if (height > 0) this.height = height;
			if (widthType != null) this.widthType = widthType;
			if (heightType != null) this.heightType = heightType;
			if (hAlign != null) this.hAlign = hAlign;
			if (vAlign != null) this.vAlign = vAlign;
		}
		
		/**
		* Set padding on all four sides with one method call.
		* @param	n	The padding to set (in px).
		*/
		public function set padding(n:Number):void
		{
			padding_l = padding_r = padding_t = padding_b = n;
		}
	}
}
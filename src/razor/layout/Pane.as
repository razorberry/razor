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
	import flash.display.DisplayObject;
	
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.razor_internal;
	import razor.layout.types.RowBasedLayout;
	
	/**
	 * An extension of Layer to add a titled border.
	 * Content will be positioned inside the border.
	 * @example
	 * <listing version="3.0">
	 * var newPane:Pane = addChild(new Pane()) as Pane;
	 * newPane.label = "Stuff";
	 * newPane.setSize(300,200);
	 * </listing>
	 */
	public class Pane extends Layer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "Pane"; }
		
		/** @private */ protected var border:DisplayObject;
		
		public function Pane()
		{
			autoCollapse = false;
			
			implementation = new RowBasedLayout();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set the border label
		* @param	str		The label to set.
		*/
		public function set label(str:String):void
		{
			if ("label" in border)
				Object(border).label = str; 
		}
		
		/**
		* Get the border label
		* @return	The border label
		*/
		public function get label():String
		{
			if ("label" in border)
				return Object(border).label;
			else
				return "";
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			border = addBlueprint("Border");
		}
		
		/** @private */
		override protected function layout():void
		{
			// We need to lay stuff out inside the border, so set the margins.
			var m:Metrics = (border is IBordered) ? IBordered(border).getBorderMetrics() : new Metrics();
			
			margin_l = m.l;
			margin_r = m.r;
			margin_t = m.t;
			margin_b = m.b;
			
			super.layout();
			layingOut = true;
			sizeChild(border, __width - 10, __height - 5);
			border.x = 5;
			border.y = 0;
			layingOut = false;
		}
	}
}
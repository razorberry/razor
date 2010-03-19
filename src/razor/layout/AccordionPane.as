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
	
	import razor.controls.Button;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.layout.types.RowBasedLayout;
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * A pane with a header that collapses the content.
	 * Used for the Accordion control.
	 * @private
	 */
	public class AccordionPane extends HidablePane
	{
		use namespace razor_internal;
		
		public static const E_RESIZE:String = HidablePane.E_RESIZE;
	
		/** @private */ override protected function getClass():String { return "AccordionPane"; }
		
		/** @private */ protected var border:DisplayObject;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Get/Set the label for the collapsible pane header.
		* @param	str		The header label to set
		*/
		public function set label(str:String):void
		{
			if ("label" in border)
				Object(border).label = str; 
		}
		
		/** @private */
		public function get label():String
		{
			if ("label" in border)
			return Object(border).label;
			else
			return null;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function AccordionPane()
		{
			implementation = new RowBasedLayout();
		}
		
		/** @private */
		override protected function construct():void
		{
			border = addBlueprint("Header");
			if (border is StyledContainer)
			{
				var b:* = StyledContainer(border).style.bevel;
				var newbevel:Array;
				if (b is Array)
					newbevel = [ b[0], b[1], 0, 0 ];
				else
					newbevel = [ b, b, 0, 0 ];
					
				StyledContainer(border).mergeStyle({bevel: newbevel});
			}
			border.addEventListener(Button.E_CLICK, toggleContents);
		}
		
		/** @private */
		override protected function layout():void
		{
			margin_t = 25;
			margin_b = 5;
			margin_l = 5;
			margin_r = 5;
			super.layout();
			layingOut = true;
			sizeChild(border, __width, 20);
			
			if (!open)
			__height = border.height;
			layingOut = false;
		}
	}
}
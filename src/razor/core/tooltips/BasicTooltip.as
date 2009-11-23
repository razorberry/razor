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

package razor.core.tooltips
{
	import flash.display.DisplayObject;
	
	import razor.controls.Label;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	
	/**
	 * A basic tooltip renderer
	 * @private
	 */
	public class BasicTooltip extends StyledContainer
		implements ITooltip
	{
		use namespace razor_internal;
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var label:Label;
		/** @private */ protected var overlay:DisplayObject;
		 
		public function BasicTooltip()
		{
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			label = addBlueprint("Label") as Label;
			if (label)
			{
				label.autoSize = "left";
			}
			overlay = addBlueprint("Overlay");
		}
		
		/** @private */
		override protected function layout():void
		{
			if (background && label)
			{
				sizeChild(background, 
							label.width + __style.padding_l + __style.padding_r,
							label.height + __style.padding_t + __style.padding_b);
			}
			
			if (label)
			{
				label.move(__style.padding_l, __style.padding_t);
			}
			if (overlay && label)
			{
				sizeChild(overlay, 
							label.width + __style.padding_l + __style.padding_r,
							label.height + __style.padding_t + __style.padding_b);
			}
		}
		
		/**
		 * Set the value for this tooltip
		 * @data	A TooltipData instance
		 */
		public function setValue(data:TooltipData):void
		{
			if (data == null)
				return;
				
			if (label)
			{
				label.text = data.text;
			}
			
			doLayout();
		}
	}
}
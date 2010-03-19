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
	import flash.events.Event;
	
	import razor.core.razor_internal;
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * An extension of Layer that can hide its contents.
	 * @private
	 */
	public class HidablePane extends Layer
	{
		use namespace razor_internal;
		
		public static const E_RESIZE:String = Layer.E_RESIZE;
		
		/** @private */ override protected function getClass():String { return "HidablePane"; }
		
		/** @private */ protected var open:Boolean = true;
		/** @private */ protected var excludes:Array;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set the contents of this pane to be visible or invisible
		* @param	b	Boolean indicating whether the contents of this pane are visible.
		*/
		public function setVisible(b:Boolean):void
		{
			if (b != open)
				toggleContents();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		protected function toggleContents(e:Event = null):void
		{
			open = !open;
			
			if (!open)
			{
				excludes = new Array();
			}
			for each (var z:Object in children)
			{
				if (!open && !z.container.visible)
					excludes[z.container] = true;
				
				if (open && excludes[z.container])
					continue;
					
				z.container.visible = open;
			}
			
			if (open)
			doLayout();
			else
			dispatchEvent(new Event(E_RESIZE));
		}
	}
}
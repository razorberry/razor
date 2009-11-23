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

package razor.controls
{
	import flash.display.DisplayObject;
	
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.razor_internal;
	
	/**
	 * A simple input field.
	 * @example
	 * <listing version="3.0">
	 * var input:TextInput = addChild(new TextInput());
	 * input.setSize(200,26);
	 * input.text = "Enter name.";
	 * input.addEventListener(TextInput.E_ENTER, onEnter);
	 * </listing>
	 */
	public class TextInput extends Label
	{
		use namespace razor_internal;
		
		public static const E_CHANGE:String = Label.E_CHANGE;
		public static const E_ENTER:String = Label.E_ENTER;
		public static const E_SCROLL:String = Label.E_SCROLL;
		
		/** @private */ override protected function getClass():String { return "TextInput"; }
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var overlay:DisplayObject;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			textField = createTF();
			addChild(textField);
			textField.type = "input";
			textField.wordWrap = false;
	 		textField.multiline = false;
	 		overlay = addBlueprint("Overlay");
		}
		
		/** @private */
		override protected function layout():void
		{
			sizeChild(background, __width, __height);
			sizeChild(overlay, __width,__height);
			textField.defaultTextFormat = __style.textFormat;
			sizeTF();
		}
		
		private function sizeTF():void
		{
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			textField.width = __width - m.l - m.r;
			textField.height = __height - m.t - m.b + 2;
			textField.x = m.l;
			textField.y = m.t;
		}
		
		/** @private */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,__style.fontSize + __style.bevel*2 + 4);
		}
	}
}
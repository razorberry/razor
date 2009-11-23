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
	import flash.events.Event;
	
	import razor.core.razor_internal;
	
	/**
	 * Dispatched when this radio button is selected.
	 * @eventType razor.controls.RadioButton.E_SELECT
	 */
	[Event(name="select", type="flash.events.Event")]
	
	/**
	 * A basic radio button component
	 * @example
	 * <listing version="3.0">
	 * var rg:RadioGroup = new RadioGroup();
	 * var rb:RadioButton = addChild(new RadioButton());
	 * rb.setSize(200,20);
	 * rb.label = "One";
	 * rb.group = rg;  // Assign the same RadioGroup instance to multiple radio buttons to group them.
	 * </listing>
	 */
	public class RadioButton extends CheckBox
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = CheckBox.E_SELECT;
	
		// State identifiers.
		public static const S_CHECKED:String = "Checked";
		public static const S_UNCHECKED:String = "Unchecked";
		
		/** @private */ override protected function getClass():String { return "RadioButton"; }
		
		/** @private */ razor_internal var _group:RadioGroup;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Assign this RadioButton instance to a group.
		* @example
		* <listing version="3.0">
		* var group:RadioGroup = new RadioGroup();
		* var button:RadioButton = new RadioButton();
		* button.group = group;
		* </listing>
		* @param	radiogroup
		*/
		public function set group(radioGroup:RadioGroup):void
		{
			if (_group != null)
				_group.removeItem(this);
			radioGroup.addItem(this);
		}
		
		/** @private */
		public function get group():RadioGroup
		{
			return _group;
		}
		
		/**
		* @inheritDoc
		*/
		override public function set selected(b:Boolean):void
		{
			if (b && _group != null)
				_group.deselectGroup(this);
			var was:Boolean = _selected
			_selected = b;
			setState(b ? S_CHECKED : S_UNCHECKED);
			doLayout();
			
			if (_group && was != _selected)
				_group.dispatchChange(this);
		}
		
		/** @private */
		override public function get selected():Boolean
		{
			return _selected;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function RadioButton()
		{
		}
		
		/** @private */
		override protected function onClick(e:Event):void
		{
			// Radio buttons are unselectable by clicking.
			if (_selected) return;
			else
			{
				selected = !_selected;
				dispatchEvent(new Event(E_SELECT, {selected: _selected}));
			}
		}
	}
}
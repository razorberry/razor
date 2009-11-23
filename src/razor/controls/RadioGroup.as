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
	import flash.events.EventDispatcher;
	
	import razor.core.razor_internal;
	
	/**
	 * Dispatched when the current selected button in this group has changed.
	 * @eventType razor.controls.RadioGroup.E_CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	/**
	* A container for Radio controls.
	* Grouping radio controls ensures that all other controls are deselected when this one is selected.
	* @example
	* <listing version="3.0">
	* var group:RadioGroup = new RadioGroup();
	* var button:RadioButton = new RadioButton();
	* button.group = group;
	* </listing>
	*/
	public class RadioGroup extends EventDispatcher
	{
		use namespace razor_internal;
		
		public static const E_CHANGE:String = Event.CHANGE;
		
		/** @private */ protected var buttons:Array;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Add a RadioButton instance to this group.
		* @param	radio	The RadioButton instance to add.
		*/
		public function addItem(radio:RadioButton):void
		{
			removeItem(radio);
			buttons.push(radio);
			radio._group = this;
		}
		
		/**
		* Remove a RadioButton instance from this group.
		* @param	radio	The RadioButton instance to remove.
		*/
		public function removeItem(radio:RadioButton):void
		{
			Object(radio)._group = undefined;
			var l:uint = buttons.length;
			for (var i:uint = 0; i < l; i++)
			{
				if (buttons[i] == radio)
				{
					buttons.splice(i,1);
					return;
				}
			}
		}
		
		/**
		* Deselect all RadioButtons in this group.
		* @param	except	A RadioButton that will not be deselected.
		*/
		public function deselectGroup(except:RadioButton):void
		{
			for each (var z:RadioButton in buttons)
			{
				if (z != except)
					z.selected = false;
			}
		}
		
		
		/**
		* Set or retrieve the currently selected RadioButton in the group.
		* Setting this will deselect the other buttons in the group.
		* @param	radiobutton		The RadioButton instance to select.
		*/
		public function set selectedItem(radiobutton:RadioButton):void
		{
			deselectGroup(radiobutton);
			radiobutton.selected = true;
		}
		
		/** @private */
		public function get selectedItem():RadioButton
		{
			var l:uint = buttons.length;
			for (var i:uint = 0; i < l; i++)
				if (buttons[i].selected)
					return buttons[i];
			return null;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function RadioGroup()
		{
			buttons = new Array();
		}
		
		
		/** @private */
		razor_internal function dispatchChange(radio:RadioButton):void
		{
			dispatchEvent(new Event(E_CHANGE));
		}
	}
}
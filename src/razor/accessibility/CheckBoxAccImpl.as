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

package razor.accessibility
{
	import flash.display.DisplayObject;
	
	import razor.controls.Button;
	import razor.controls.CheckBox;

	public class CheckBoxAccImpl extends ButtonAccImpl
	{
		protected static const STATE_SYSTEM_CHECKED:uint = 0x00000010;
		
		public function CheckBoxAccImpl(owner:DisplayObject, name:String=null, role:uint = 0x2c)
		{
			super(owner, name, role);
			
			_owner.addEventListener(CheckBox.E_SELECT, dispatchStateChange);
		}
		
		override public function get_accState(childID:uint):uint
		{
			var state:uint = super.get_accState(childID);
			
			if (CheckBox(_owner).selected)
			{
				if (state & STATE_SYSTEM_PRESSED)
				state ^= STATE_SYSTEM_PRESSED;
				state |= STATE_SYSTEM_CHECKED;
			}
			
			return state;
		}
		
		override public function get_accDefaultAction(childID:uint):String
		{
			return Button(_owner).selected ? "UnCheck" : "Check";
		}
	}
}
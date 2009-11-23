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
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityImplementation;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import razor.core.Container;

	public class BasicAccImpl extends AccessibilityImplementation
	{
		protected static const STATE_SYSTEM_NORMAL:uint = 0x00000000;
		protected static const STATE_SYSTEM_FOCUSABLE:uint = 0x00100000;
		protected static const STATE_SYSTEM_FOCUSED:uint = 0x00000004;
		protected static const STATE_SYSTEM_UNAVAILABLE:uint = 0x00000001;
	
		protected var _name:String;
		protected var _role:uint;
		protected var _owner:DisplayObject;
		
		public function BasicAccImpl(owner:DisplayObject, name:String = null, role:uint = 0)
		{
			stub = false;
			
			_owner = owner;
			_name = name;
			_role = role;
		}
		
		public function set role(v:uint):void
		{
			_role = v;
		}
		
		public function get role():uint
		{
			return _role;
		}
		
		public function set name(str:String):void
		{
			_name = str;
			dispatchNameChange();
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function dispatchStateChange(e:Event = null):void
		{
			try
			{
				Accessibility.sendEvent(_owner, 0, 0x800A);  // 0x800A = state change
				Accessibility.updateProperties();
			}
			catch (err:Error)
			{
				// ignore
			}
		}
		
		public function dispatchNameChange(e:Event = null):void
		{
			try
			{
				Accessibility.sendEvent(_owner, 0, 0x800C);  // 0x800C = name change
				Accessibility.updateProperties();
			}
			catch (err:Error)
			{
				// ignore
			}
		}
		
		override public function get_accRole(childID:uint):uint
		{
			return _role;
		}
		
		override public function get_accName(childID:uint):String
		{
			var accName:String = "";
	
			if (_name && _name != "")
				accName = _name;
				
			if (childID == 0 && (_name == null || _name == "") && _owner.accessibilityProperties 
				&& _owner.accessibilityProperties.name 
					&& _owner.accessibilityProperties.name != "")
				accName += _owner.accessibilityProperties.name;
	
			if (accName == null || accName == "")
			{
				if (Object(_owner).hasOwnProperty("label") && Object(_owner)["label"] != "")
					accName = Object(_owner)["label"];
			}
			return (accName != null && accName != "") ? accName : null;
		}
		
		override public function get_accState(childID:uint):uint
		{
			var accState:uint = STATE_SYSTEM_NORMAL;
			
			if (_owner is Container && !Container(_owner).enabled)
				accState |= STATE_SYSTEM_UNAVAILABLE;
			else
			{
				accState |= STATE_SYSTEM_FOCUSABLE
			
				if (_owner.stage && _owner.stage.focus == _owner)
					accState |= STATE_SYSTEM_FOCUSED;
			}
	
			return accState;
		}
		
		override public function get_accDefaultAction(childID:uint):String
		{
			return "Press";
		}
	}
}
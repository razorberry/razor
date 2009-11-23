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
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import razor.accessibility.CheckBoxAccImpl;
	import razor.core.InteractiveContainer;
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.razor_internal;
	
	/**
	 * Dispatched when the checkbox is selected/changes state.
	 * @eventType razor.controls.CheckBox.E_SELECT
	 */
	[Event(name="select", type="razor.core.RazorEvent")]
	
	/**
	 * Component for a toggleable checkbox.
	 * @example
	 * <listing version="3.0">
	 * package
	 * {
	 *     import razor.core.ControlFactory;
	 *     import razor.controls.CheckBox;
	 *     import razor.core.RazorEvent;
	 * 
	 *     public class CheckBoxExample extends flash.display.Sprite
	 *     {
	 *         public function CheckBoxExample()
	 *         {
	 *             var checkBox:CheckBox = ControlFactory.create(CheckBox) as CheckBox;
	 *             checkBox.setSize(300,24);
	 *             checkBox.label = "Check me!";
	 *             checkBox.addEventListener(CheckBox.E_SELECT, onCheck);
	 *             addChild(checkBox);
	 *         }
	 * 
	 *         protected function onCheck(e:RazorEvent):void
	 *         {
	 *             trace(e.selected);
	 *         }
	 *     }
	 * }
	 * </listing>
	*/
	public class CheckBox extends InteractiveContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
	
		public static const S_CHECKED:String = "Checked";
		public static const S_UNCHECKED:String = "Unchecked";
		
		/** @private */ override protected function getClass():String { return "CheckBox"; }
		
		/** @private */ protected var _label:String;
		/** @private */ protected var _selected:Boolean = false;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set the label for this checkbox
		* @param	str		The label string
		*/
		public function set label(str:String):void
		{
			_label = str;
			
			if (getStateElement("Label") == null)
			{
				addStates("Label",2,[S_UNCHECKED, S_CHECKED]);
			}
			
			doLayout();
		}
		
		/** @private */
		public function get label():String
		{
			return _label;
		}
		
		/**
		* Get/Set whether this checkbox is selected or not
		* @param	b	A boolean representing whether the checkbox is selected.
		*/
		public function set selected(b:Boolean):void
		{
			_selected = b;
			setState(b ? S_CHECKED : S_UNCHECKED);
			layout();
		}
		
		/** @private */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function CheckBox()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			addStates("Background", 1, [S_UNCHECKED, S_CHECKED]);
			if (_label && _label.length > 0)
				addStates("Label", 2, [S_UNCHECKED, S_CHECKED]);
			addStates("Overlay", 3, [S_UNCHECKED, S_CHECKED]);
			
			addEventListener(InteractiveContainer.E_CLICK, onClick);
		}
		
		/** @private */
		override protected function layout():void
		{
			var box:DisplayObject = getStateElement("Background");
			sizeChild(box, __height, __height);
			var lbl:DisplayObject = getStateElement("Label");
			if (lbl != null)
			{
				if (lbl is Label)
				{
					Label(lbl).wordWrap = true;
					Label(lbl).autoSize = TextFieldAutoSize.CENTER;
					
					Label(lbl).text = _label ? _label : "";
				}
				
				lbl.width = __width - __height - 5;
				lbl.x = __height + 5;
				lbl.y = (__height - (lbl is Label ? Label(lbl).textHeight : lbl.height))/2 - 2;
			}
			var check:DisplayObject = getStateElement("Overlay");
			sizeChild(check, __height, __height);
		}
		
		override protected function createAccessibilityImplementation():void
		{
			accessibilityImplementation = new CheckBoxAccImpl(this);
		}
		
		/** @private */
		protected function onClick(e:Event):void
		{
			selected = !_selected;
			dispatchEvent(new RazorEvent(E_SELECT, {selected: _selected}));
		}
		
		/** @private */
		override public function set enabled(b:Boolean):void
		{
			var c:DisplayObject = getStateElement("Background"); 
			if ("enabled" in c) c["enabled"] = b;
			else if (c is InteractiveObject) InteractiveObject(c).mouseEnabled = false;
			
			super.enabled = b;
		}
		
		/** @private */
		override protected function setState(state:String):void
		{
			super.setState(state);
			enabled = enabled;
		}
		
		/** @private */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,16);
		}
	}
}
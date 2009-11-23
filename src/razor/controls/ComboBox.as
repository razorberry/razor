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
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	
	import razor.core.InteractiveContainer;
	import razor.core.ListContainer;
	import razor.core.RazorEvent;
	import razor.core.razor_internal;
	import razor.layout.ModalLayer;

	/**
	 * Dispatched when an item is selected from the drop down menu.
	 * @eventType razor.controls.ComboBox.E_SELECT
	 */
	[Event(name="select", type="razor.core.RazorEvent")]
	
	/**
	* Component for a drop down menu.
	* @example
	* <listing version="3.0">
	* var combo:ComboBox = addChild(new ComboBox());
	* combo.setSize(200,26);
	* combo.dataProvider = ["One", "Two"];
	* combo.addEventListener(ComboBox.E_SELECT, onComboChange);
	* combo.label = "<i>Select one...</i>";
	* </listing>
	*/
	public class ComboBox extends ListContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
	
		// TODO: formalize this:
		private var LIST_HEIGHT:Number = 125;
		
		/** @private */ override protected function getClass():String { return "ComboBox"; }
		
		/** @private */ protected var list:List;
		/** @private */ protected var box:InteractiveContainer;
		/** @private */ protected var label_mc:Label;
		/** @private */ protected var btn:Button;
		/** @private */ protected var _labelField:String = "label";
		/** @private */ protected var _label:String;
		/** @private */ protected var _selectedIndex:int = -1;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set the current data provider/enumeration for the drop down list.
		* @param	arr		A data provider array.
		*/
		override public function set dataProvider(arr:Array):void
		{
			dP = arr;
			if (list)
				list.dataProvider = dP;
		}
		
		/**
		* Set the initial label for the Combo box (before you select an item)
		* @param	str		The label string.
		*/
		public function set label(str:String):void
		{
			_label = str;
			label_mc.text = str;
			doLayout();
		}
		
		/** @private */ 
		public function get label():String
		{
			return label_mc.text;
		}
		
		
		
		/**
		* Get/set the index of the current selected item in the data provider.
		* @param	value	The index to select.
		*/
		public function set selectedIndex(value:int):void
		{
			if (value < 0)
				label = _label;
			
			_selectedIndex = value < 0 ? -1 : value;
			if (list != null)
				list.selectedIndex = _selectedIndex;
			
			if (_selectedIndex >= 0)
				updateLabel();
		}
		
		/** @private */ 
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		/**
		* Set the currently selected item in the data provider
		* @param	item	The item to select.
		*/
		public function set selectedItem(item:Object):void
		{
			var i:int = dP.length;
			
			while (--i >= 0)
				if (dP[i] == item)
				{
					selectedIndex = i;
					break;
				}
		}
		
		/** @private */ 
		public function get selectedItem():Object
		{
			return (selectedIndex >= 0) ? dP[selectedIndex] : null;
		}
		
		/**
		 * Get/Set the name of the property on each item in the dataProvider to use as the label.
		 */
		public function set labelField(str:String):void
		{
			_labelField = str;
			if (list)
				list.labelField = str;
		}
		
		/** @private */
		public function get labelField():String
		{
			return _labelField;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			box = addBlueprint("Background") as InteractiveContainer;
			label_mc = addBlueprint("Label") as Label;
			label_mc.selectable = false;
			label_mc.html = true;
			label_mc.wordWrap = true;
			label_mc.autoSize = TextFieldAutoSize.CENTER;
			btn = addBlueprint("ToggleButton") as Button;
			btn.addIcon("Arrow");
			box.addEventListener(Button.E_CLICK, onBoxClick);
			btn.addEventListener(Button.E_CLICK, onBoxClick);
		}
		
		/** @private */
		override protected function layout():void
		{
			btn.setSize(__height, __height);
			box.setSize(__width - __height, __height);
			label_mc.width = __width - __height - 10;
			label_mc.move(5,(__height - label_mc.textHeight)/2 - 2)
			btn.move(__width - __height, 0);
			btn.icon.rotation = 90;
			
			if (list && list.visible)
			{
				var lh:Number = list.contentHeight < LIST_HEIGHT ? list.contentHeight : LIST_HEIGHT;
				list.setSize(__width, lh);
				var np:Point = ModalLayer.getInstance().getNearestPopPoint(list, this);
				list.move(np.x, np.y);
			}
		}
		
		/**
		 * Called when either the main box or arrow button is clicked.
		 */
		private function onBoxClick(e:Event):void
		{
			toggleList(list == null || list.stage == null);
		}
		
		/**
		 * Called when the drop down list dispatches a click event.
		 */
		private function onListClick(e:RazorEvent):void
		{
			toggleList(false);
			_selectedIndex = e.index;
			updateLabel();
			dispatchEvent(new RazorEvent(E_SELECT, {item: e.item, label: e.label, data: e.data, index: e.index}));
		}
		
		/**
		 * Called when the stage is clicked while the drop down is open.
		 */
		private function onStageMouse(e:MouseEvent):void
		{
			var ml:ModalLayer = ModalLayer.getInstance();
			if ((mouseX < 0 || mouseX > __width || mouseY < 0 || mouseY > __height) && !list.hitTestPoint(ml.mouseX, ml.mouseY))
				toggleList(false);
		}
		
		/**
		 * Update the label with the current item.
		 */
		private function updateLabel():void
		{
			var si:uint = _selectedIndex;
			if (dP == null || dP[si] == null)
			{
				label_mc.text = "";
				return;
			}
			
			label_mc.text = (dP[si].hasOwnProperty(labelField)) ? dP[si][labelField] : (dP[si].toString() ? dP[si].toString() : "");
			label_mc.move(5,(__height - label_mc.textHeight)/2 - 2);
		}
		
		/**
		 * Hide or show the drop down list.
		 */
		private function toggleList(open:Boolean):void
		{
			if (open && list == null)
			{
				list = addBlueprint(List, { style: __style, listOwner: this } ) as List;
				if (contains(list))
					removeChild(list);
				ModalLayer.getInstance().addPopup(list);
				list.labelField = _labelField;
				list.dataProvider = dP;
				list.mode = List.MODE_SELECT_ONE;
				list.selectedIndex = _selectedIndex;
				list.addEventListener(List.E_SELECT, onListClick);
				
				if (stage)
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouse);
				doLayout();
			}
			else
			{
				var ml:ModalLayer = ModalLayer.getInstance();
				
				if (open)
				{
					if (!ml.contains(list))
						ml.addChild(list);
					
					if (stage)
						stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouse);
					doLayout();
				}
				else
				{
					if (ml.contains(list))
						ml.removeChild(list);
					if (stage)
						stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouse);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			toggleList(false);
			
			// list should be in our list of elements, so it will be destroyed on this next call:
			super.destroy();
		}
	}
}
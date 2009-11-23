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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import razor.controls.grid.Cell;
	import razor.controls.grid.ListBase;
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.ListContainer;
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.razor_internal;

	/**
	 * Dispatched when an item is selected in the list.
	 * @eventType razor.controls.List.E_SELECT
	 */
	[Event(name="select", type="razor.core.RazorEvent")]
	
	/**
	 * Class for a single column list.
	 * @example
	 * <listing version="3.0">
	 * var list:List = addChild(new List());
	 * list.setSize(200,300);
	 * list.dataProvider = ["One", "Two", "Three"];
	 * list.mode = List.MODE_SELECT_SHIFT;
	 * list.addEventListener(List.E_SELECT, onListSelect);
	 * </listing>
	 */
	public class List extends ListContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
	
		// List is "Select Only One Item" by default
		// Set mode to MODE_SELECT_SHIFT to allow multiple selection by holding down shift
		// Set mode to MODE_SELECT_MANY to allow multiple selection by default
		public static const MODE_SELECT_NONE:uint = 0;
		public static const MODE_SELECT_ONE:uint = 1;
		public static const MODE_SELECT_SHIFT:uint = 2;
		public static const MODE_SELECT_MANY:uint = 3;
		
		/** @private */ override protected function getClass():String { return "List"; }
		
		private var background:DisplayObject;
		private var overlay:DisplayObject;
		private var list:ListBase;
		
		private var shiftIsDown:Boolean = false;
		private var ctrlIsDown:Boolean = false;
		
		/** @private */
		protected var _mode:uint = MODE_SELECT_ONE;
		
		/** @private */
		protected var _labelField:String = "label";
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/Set the current selection mode.
		 * @example Use the constants shown below. <listing version="3.0">
		 * list.mode = List.MODE_SELECT_NONE; // No items are selectable
		 * list.mode = List.MODE_SELECT_ONE; // Only one item is selectable
		 * list.mode = List.MODE_SELECT_SHIFT; // Multiple items are selectable when shift or ctrl is held.
		 * list.mode = List.MODE_SELECT_MANY; // Multiple items are selectable.</listing>
		 */
		public function set mode(m:uint):void
		{
			_mode = m;
		}
		
		/** @private */
		public function get mode():uint
		{
			return _mode;
		}
		
		/**
		* Set the current data provider for the list. This will update the display.
		* @param	arr		A data provider array.
		*/
		override public function set dataProvider(arr:Array):void
		{
			list.dataProvider = arr;
		}
		
		/**
		* @private
		*/
		override public function get dataProvider():Array
		{
			return list.dataProvider;
		}
		
		/**
		* Get/set the currently selected item at a particular index.
		* @param	n	The index of the item to select.
		*/
		public function set selectedIndex(n:int):void
		{
			list.selectedIndex = n;
		}
		
		/** @private */
		public function get selectedIndex():int
		{
			return list.selectedIndex;
		}
		
		/**
		* Get/set the currently selected item.
		* @param	n	The item to select.
		*/
		public function set selectedItem(item:Object):void
		{
			list.selectedItem = item;
		}
		
		/** @private */
		public function get selectedItem():Object
		{
			return list.selectedItem;
		}
		
		
		/**
		* Get the current height of the content of this list, excluding scrollbars.
		* @return	The height of the content (in px).
		*/
		public function get contentHeight():Number
		{
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			return list.contentHeight + (list.hasHScroll ? list.scrollbarWidth : 0) + m.t + m.b;
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
		
		public function List()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			list = addBlueprint(ListBase, {listOwner: this}) as ListBase;
			list.labelField = _labelField;
			list.addEventListener(ListBase.E_SELECT, onItemClick);
			overlay = addBlueprint("Overlay");
			dataProvider = new Array();
			
			addEventListener(Event.ADDED_TO_STAGE, onStageAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onStageRemoved);
			
			// Add the listeners if we are already on the stage:
			onStageAdded();
		}
		
		/**
		 * Called when this list is added to the stage. Adds our key listeners.
		 */
		private function onStageAdded(e:Event = null):void
		{
			if (stage)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
			}
		}
		
		/**
		 * Called when this list is removed from the stage. Removes our key listeners.
		 */
		private function onStageRemoved(e:Event):void
		{
			if (stage)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
			}
		}
		
		/** @private */
		override protected function layout():void
		{
			sizeChild(background, __width, __height);
			sizeChild(overlay, __width, __height);
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			list.move(m.l, m.t);
			list.setSize(__width - m.l - m.r, __height - m.t - m.b);
			
		}
		
		/**
		* Called when the list fires a click event.
		* @param	e	The list event object.
		*/
		private function onItemClick(e:RazorEvent):void
		{
			if (mode == MODE_SELECT_NONE)
			{
				list.deselectAll();
				return;
			}
			
			// Select one item ONLY IF (mode is select ONE, or shift is not held)
			if ((!shiftIsDown && !ctrlIsDown && mode < MODE_SELECT_MANY) || mode < MODE_SELECT_SHIFT)
			{
				list.deselectAll();
				list.selectedItem = e.data;
			}
			
			var i:Number = selectedIndex;
			var item:Cell = e.item;
			var lbl:String = item.label;
			
			dispatchEvent(new RazorEvent(E_SELECT, {index: i, item: e.item, label: lbl, data: e.data}));
		}
		
		/**
		 * Called when a key is pressed and this list is on the stage.
		 */
		private function onKeyPress(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SHIFT)
			{
				shiftIsDown = true;
			}
			else if (e.keyCode == Keyboard.CONTROL)
			{
				ctrlIsDown = true;
			}
		}
		
		/**
		 * Called when a key is released and this list is on the stage.
		 */
		private function onKeyRelease(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SHIFT)
			{
				shiftIsDown = false;
			}
			else if (e.keyCode == Keyboard.CONTROL)
			{
				ctrlIsDown = false;
			}
		}
		
		/** @private */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,150);
		}
	}
}
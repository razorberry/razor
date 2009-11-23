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

package razor.controls.grid
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import razor.controls.Button;
	import razor.core.InteractiveContainer;
	import razor.core.razor_internal;
	
	/**
	 * Cell renderer for a selectable list item.
	 */
	public class SelectableCell extends Cell
	{
		use namespace razor_internal;
		
		public static const E_CLICK:String = InteractiveContainer.E_CLICK;
	
		private var base:Button;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Set the current state of this cell. In this case, whether the cell is selected.
		 */
		override public function set state(o:Object):void
		{
			selected = Boolean(o);
		}
		
		/** @private */
		override public function get state():Object
		{
			return selected;
		}
		
		/**
		 * Set whether this cell is currently selected.
		 */
		public function set selected(b:Boolean):void
		{
			base.selected = b;
		}
		
		/** @private */
		public function get selected():Boolean
		{
			return base.selected;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set enabled(b:Boolean):void
		{
			base.enabled = b;
		}
		
		/** @private */
		override public function get enabled():Boolean
		{
			return base.enabled;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function SelectableCell()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			base = addBlueprint(Button) as Button;
			base.toggle = true;
			base.addEventListener(Button.E_PRESS, onClick);
			base.addEventListener(Button.E_CLICK, onRealClick);
			
			super.construct();
		}
		
		/** @private */
		override protected function layout():void
		{
			base.setSize(__width,__height);
			super.layout();
		}
		
		private function onClick(e:Event):void
		{
			dispatchEvent(new Event(E_CLICK));
		}
		
		private function onRealClick(e:Event):void
		{
			e.stopPropagation();
		}
	}
}
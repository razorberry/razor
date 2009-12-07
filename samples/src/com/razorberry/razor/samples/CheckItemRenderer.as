package com.razorberry.razor.samples
{
	import flash.events.Event;
	
	import razor.controls.CheckBox;
	import razor.controls.grid.Cell;
	import razor.core.razor_internal;
	
	public class CheckItemRenderer extends Cell
	{
		use namespace razor_internal;
		
		protected var checkBox:CheckBox;
		
		public function CheckItemRenderer()
		{
		}
		
		override protected function construct():void
		{
			checkBox = addBlueprint(CheckBox) as CheckBox;
			checkBox.addEventListener(CheckBox.E_SELECT, onCheckBoxSelect);
		}
		
		override protected function layout():void
		{
			checkBox.setSize(__width-4, __height - 4);
			checkBox.move(2,2);
			checkBox.label = label;
		}
		
		override public function set state(o:Object):void
		{
			checkBox.selected = Boolean(o);
		}
		
		/** @private */
		override public function get state():Object
		{
			return checkBox.selected;
		}
		
		protected function onCheckBoxSelect(e:Event):void
		{
			// Dispatch an event that will bubble through the list
			dispatchEvent(new Event("stateChanged", true));
		}
	}
}
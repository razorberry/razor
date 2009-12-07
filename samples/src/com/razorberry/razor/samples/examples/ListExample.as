package com.razorberry.razor.samples.examples
{
	import flash.events.Event;
	
	import razor.controls.ComboBox;
	import razor.controls.List;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Regular;

	public class ListExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var list:List;
		protected var combo:ComboBox;
		
		protected var listProvider:Array = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"];
		
		public function ListExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Regular();
			
			super();
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			list = controlFactory.create(List) as List;
			list.dataProvider = listProvider;
			list.addEventListener(List.E_SELECT, onListSelect);
			addChild(list);
			
			combo = controlFactory.create(ComboBox) as ComboBox;
			combo.dataProvider = listProvider;
			combo.addEventListener(ComboBox.E_SELECT, onComboSelect);
			combo.label = "Select one...";
			addChild(combo);
		}
		
		override protected function layout():void
		{
			list.setSize(__width/2-20, __height - 20);
			list.move(10,10);
			
			combo.setSize(__width/2-20, 22);
			combo.move(__width/2+10,10);
		}
		
		protected function onListSelect(e:Event):void
		{
			combo.selectedIndex = list.selectedIndex;
		}
		
		protected function onComboSelect(e:Event):void
		{
			list.selectedIndex = combo.selectedIndex;
		}
	}
}
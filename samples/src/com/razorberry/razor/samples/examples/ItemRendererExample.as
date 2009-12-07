package com.razorberry.razor.samples.examples
{
	import com.razorberry.razor.samples.CheckItemRenderer;
	
	import flash.events.Event;
	
	import razor.controls.Label;
	import razor.controls.List;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Default;

	public class ItemRendererExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var list:List;
		protected var label:Label;
		
		public function ItemRendererExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Default();
			
			super();
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			list = controlFactory.create(List) as List;
			
			// Set the class to create for each list cell.
			list.cellClass = CheckItemRenderer;
			// An alternative to setting the class is list.cellStyle...
			// this would allow you to use a styleSheet style to define the cell renderer.
			
			// This event is dispatched by our CheckItemRenderer. It bubbles up through the list.
			list.addEventListener("stateChanged", onItemStateChanged);
			addChild(list);
			
			list.dataProvider = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven","Twelve","Thirteen","Fourteen","Fifteen","Sixteen","Seventeen","Eighteen","Nineteen","Twenty"];
			
			label = controlFactory.create(Label) as Label;
			
		}
		
		override protected function layout():void
		{
			list.setSize(__width/2, __height - 80);
			list.move(__width/4, 10);
			
			label.setSize(__width* 5/6, 60);
			label.move(__width/12, __height - 70); 
		}
		
		protected function onItemStateChanged(e:Event):void
		{
			// Stop the event from bubbling any further
			e.stopPropagation();
			
			// .. do something with the event ..
		}
	}
}
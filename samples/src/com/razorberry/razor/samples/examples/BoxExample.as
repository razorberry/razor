package com.razorberry.razor.samples.examples
{
	import razor.controls.Button;
	import razor.controls.HBox;
	import razor.controls.VBox;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.plastic.PlasticStyleSheet;

	public class BoxExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		
		public function BoxExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			
			super();
		}
		
		
		override protected function construct():void
		{
			var b:Button;
			var hBox:HBox;
			var vBox:VBox;
		
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			hBox = controlFactory.create(HBox) as HBox;
			addChild(hBox);
			
			vBox = hBox.addChild(controlFactory.create(VBox)) as VBox;
			
			b = vBox.addChild(controlFactory.create(Button)) as Button;
			b.label = "Button 1";
			b.setSize(100,22);
			
			b = vBox.addChild(controlFactory.create(Button)) as Button;
			b.label = "Button 2";
			b.setSize(100,22);
			
			b = hBox.addChild(controlFactory.create(Button)) as Button;
			b.label = "Button 3";
			b.setSize(100,46);
			
			vBox = hBox.addChild(controlFactory.create(VBox)) as VBox;
			
			b = vBox.addChild(controlFactory.create(Button)) as Button;
			b.label = "Button 4";
			b.setSize(100,22);
			
			b = vBox.addChild(controlFactory.create(Button)) as Button;
			b.label = "Button 5";
			b.setSize(100,22);
			
		}
		
		override protected function layout():void
		{
			// layout is handled by the vBox and hBox classes
		}
	}
}
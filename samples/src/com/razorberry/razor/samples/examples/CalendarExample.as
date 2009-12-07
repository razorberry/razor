package com.razorberry.razor.samples.examples
{
	import razor.controls.Calendar;
	import razor.controls.DateChooser;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Sharp;

	public class CalendarExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var calendar:Calendar;
		protected var dateChooser:DateChooser;
		
		public function CalendarExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Sharp();
			
			super();
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			calendar = controlFactory.create(Calendar) as Calendar;
			addChild(calendar);
			
			dateChooser = controlFactory.create(DateChooser) as DateChooser;
			addChild(dateChooser);
		}
		
		override protected function layout():void
		{
			calendar.setSize(__width/2-20, __height - 40);
			calendar.move(10,20);
			
			dateChooser.setSize(__width/2-20, 22);
			dateChooser.move(__width/2+10,20);
		}
		
		
	}
}
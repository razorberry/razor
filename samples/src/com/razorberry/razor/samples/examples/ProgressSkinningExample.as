package com.razorberry.razor.samples.examples
{
	import razor.controls.ProgressBar;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Glass;

	public class ProgressSkinningExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var bar1:ProgressBar;
		
		public function ProgressSkinningExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Glass();
			
			setStyles();
			super();
		}
		
		protected function setStyles():void
		{
			// NOTE: In our sample application we created a new ControlFactory
			// for each example. You can also get a reference to the global rootStyleSheet
			// from: Settings.rootStyleSheet  OR  ControlFactory.defaultFactory.rootStyleSheet
			var sheet:StyleSheet = controlFactory.rootStyleSheet;
			
			sheet.addRule("bar1", new StyleSheet({bevel: 6, align: "center", bold: true}));
			sheet.addRule("bar1 Bar", new StyleSheet(null, ProgressIndicator));
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			bar1 = controlFactory.create(ProgressBar, "bar1") as ProgressBar;
			bar1.label = "Please wait";
			bar1.progress = 1;
			addChild(bar1);
		}
		
		override protected function layout():void
		{
			bar1.setSize(__width*2/3, 28);
			bar1.move(__width/6, 10);
		}
		
		
	}
}
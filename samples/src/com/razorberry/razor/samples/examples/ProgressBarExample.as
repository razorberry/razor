package com.razorberry.razor.samples.examples
{
	import com.razorberry.razor.samples.SampleAssets;
	
	import flash.events.Event;
	
	import razor.controls.ProgressBar;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.SkinBitmap;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Winter;

	public class ProgressBarExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var bar1:ProgressBar;
		protected var bar2:ProgressBar;
		protected var bar3:ProgressBar;
		
		protected var count:Number = 0;
		
		public function ProgressBarExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Winter();
			
			setStyles();
			super();
		}
		
		protected function setStyles():void
		{
			// NOTE: In our sample application we created a new ControlFactory
			// for each example. You can also get a reference to the global rootStyleSheet
			// from: Settings.rootStyleSheet  OR  ControlFactory.defaultFactory.rootStyleSheet
			var sheet:StyleSheet = controlFactory.rootStyleSheet;
			
			sheet.addRule("bar1", new StyleSheet({align: "center"}));
			
			sheet.addRule("bar2", new StyleSheet({padding_l: 80}));
			sheet.addRule("bar2 Bar", new StyleSheet({skinClass: SampleAssets.button_down}, SkinBitmap));
			
			sheet.addRule("bar3", new StyleSheet({roundedness: 0, glossiness: 0, variance: 0, bevel: 2}));
			sheet.addRule("bar3 Bar", new StyleSheet({baseColor:0xff}));
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			bar1 = controlFactory.create(ProgressBar, "bar1") as ProgressBar;
			bar1.label = "%p% complete";
			addChild(bar1);
			
			bar2 = controlFactory.create(ProgressBar, "bar2") as ProgressBar;
			bar2.label = "%v out of %t";
			bar2.value = 0;
			bar2.total = 100;
			addChild(bar2);
			
			bar3 = controlFactory.create(ProgressBar, "bar3") as ProgressBar;
			bar3.label = "";
			bar3.value = 0;
			bar3.total = 100;
			addChild(bar3);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		override protected function layout():void
		{
			bar1.setSize(Math.floor(__width*2/3), 28);
			bar1.move(Math.floor(__width/6), 10);
			
			bar2.setSize(Math.floor(__width*2/3), 28);
			bar2.move(Math.floor(__width/6), 40);
			
			bar3.setSize(Math.floor(__width*2/3), 8);
			bar3.move(Math.floor(__width/6), 100);
		}
		
		protected function onEnterFrame(e:Event):void
		{
			count += 0.01;
			bar1.progress = Math.cos(count%(Math.PI*2))/2 + 0.5; 
			bar2.value = Math.round(count*25)%100;
			bar3.value = bar2.value;
		}
	}
}
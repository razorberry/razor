package com.razorberry.razor.samples.examples
{
	import com.razorberry.razor.samples.SampleAssets;
	
	import flash.events.Event;
	
	import razor.controls.Button;
	import razor.controls.RadioButton;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.core.tooltips.TooltipData;
	import razor.skins.StyleSheet;
	import razor.graphics.Arrow;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Glass;

	public class ButtonExampleOne extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var button1:Button;
		protected var button2:Button;
		protected var button3:Button;
		protected var radio:RadioButton;
		
		public function ButtonExampleOne()
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
			
			sheet.addRule("Button", new StyleSheet({align: "center"}));
			sheet.addRule("pinkButton", new StyleSheet({baseColor: 0xfff0f0, bold: true, roundedness: 0}));
			sheet.addRule("greenButton", new StyleSheet({baseColor: 0xf0fff0, border: 0x669933, fontColor: 0x336600, roundedness: 10}));
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			button1 = controlFactory.create(Button) as Button;
			button1.label = "I am a regular pushbutton";
			addChild(button1);
			
			button2 = controlFactory.create(Button, "pinkButton") as Button;
			button2.label = "I have a tooltip";
			button2.tooltip = new TooltipData("This button has a tooltip");
			addChild(button2);
			
			button3 = controlFactory.create(Button, "greenButton") as Button;
			button3.label = "I am toggleable";
			button3.addIcon(Arrow);
			button3.toggle = true;
			button3.addEventListener(Button.E_CLICK, checkButtonState);
			addChild(button3);
			
			radio = controlFactory.create(RadioButton) as RadioButton;
			radio.enabled = false;
			addChild(radio);
			checkButtonState();
		}
		
		override protected function layout():void
		{
			button1.setSize(__width/2, 24);
			button1.move((__width - button1.width)/2, 10);
			button2.setSize(__width/2, 24);
			button2.move((__width - button2.width)/2, 40);
			button3.setSize(__width/2, 24);
			button3.move((__width - button3.width)/2, 70);
			radio.setSize(__width/2, 20);
			radio.move((__width - radio.width)/2, 120);
		}
		
		protected function checkButtonState(e:Event = null):void
		{
			radio.selected = button3.selected;
			radio.label = "The third button is "+button3.phase.toLowerCase();
		}
	}
}
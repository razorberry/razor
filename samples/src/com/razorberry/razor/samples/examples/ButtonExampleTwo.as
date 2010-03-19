package com.razorberry.razor.samples.examples
{
	import com.razorberry.razor.samples.SampleAssets;
	
	import razor.controls.Button;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Glass;
	import razor.skins.stylesheets.ButtonStyles;

	public class ButtonExampleTwo extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var button1:Button;
		protected var button2:Button;
		protected var button3:Button;
		
		public function ButtonExampleTwo()
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
			
			// Create the stylesheet for the buttons.
			// The ButtonStyles class has constructor parameters for easily creating a button skin
			var buttonStyles:StyleSheet = new ButtonStyles(SampleAssets.button_up, SampleAssets.button_over, SampleAssets.button_down, SampleAssets.button_disabled);
			
			// Add some additional rules to the stylesheet we just created.
			// Passing a "*" for the rule name is the same as adding the styles to everything the stylesheet modifies
			// like a wildcard.
			buttonStyles.addRule("*", new StyleSheet({padding_l: 40, padding_t: -2, align: "left", bold: false, fontFace:"Maxine", fontSize:24, fontColor:0x666666, embedFonts: true, sharpText: true}));
			
			// Apply the stylesheet to every Button instance.
			sheet.addRule("Button", buttonStyles);
			
			sheet.addRule("myButton Label", new StyleSheet(null, null, {Over: new StyleSheet({fontColor:0xff})}));
			sheet.addRule("myButton", new StyleSheet(null, null, {Over: new StyleSheet({baseColor:0xff0000})}));
			
			
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			button1 = controlFactory.create(Button) as Button;
			button1.label = "This button has been skinned";
			addChild(button1);
			
			button2 = controlFactory.create(Button) as Button;
			button2.label = "This button is disabled";
			addChild(button2);
			
			button2.enabled = false;
			
			button3 = controlFactory.create(Button, "myButton") as Button;
			button3.label = "This button has a skinned over state";
			addChild(button3);
		}
		
		override protected function layout():void
		{
			button1.setSize(__width*2/3, 28);
			button1.move(__width/6, 10);
			
			button2.setSize(__width*2/3, 28);
			button2.move(__width/6, 40);
			
			button3.setSize(__width*2/3, 28);
			button3.move(__width/6, 70);
		}
		
		
	}
}
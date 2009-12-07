package com.razorberry.razor.samples.examples
{
	import razor.controls.TextArea;
	import razor.controls.TextInput;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Default;

	public class TextAreaExampleOne extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var textInput:TextInput;
		protected var textArea:TextArea;
		
		public function TextAreaExampleOne()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			controlFactory.defaultStyle = new Default();
			
			setStyles();
			super();
		}
		
		protected function setStyles():void
		{
			// NOTE: In our sample application we created a new ControlFactory
			// for each example. You can also get a reference to the global rootStyleSheet
			// from: Settings.rootStyleSheet  OR  ControlFactory.defaultFactory.rootStyleSheet
			var sheet:StyleSheet = controlFactory.rootStyleSheet;
			
			// Make a new rule to make our text area pink.
			sheet.addRule("ta", new StyleSheet({baseColor:0xffcccc}));
		}
		
		override protected function construct():void
		{
			// Here we use our custom controlFactory instance.
			// You could also use the static ControlFactory.create(...) method
			textInput = controlFactory.create(TextInput) as TextInput;
			addChild(textInput);
			
			textInput.text = "This is a TextInput control";
			
			textArea = controlFactory.create(TextArea, "ta") as TextArea;
			addChild(textArea);
			textArea.wordWrap = true;
			textArea.editable = true;
			textArea.multiline = true;
			textArea.text = "This is an editable TextArea control.\n\nIt comes with automatic scrollbars.\n\nIt is pink.";
		}
		
		override protected function layout():void
		{
			textInput.setSize(__width/2, 24);
			textInput.move(__width/4, 10);
			
			textArea.setSize(__width/2,  __height - 45);
			textArea.move(__width/4, 40);
		}
		
		
	}
}
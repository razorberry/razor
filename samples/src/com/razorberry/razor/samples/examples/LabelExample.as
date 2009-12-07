package com.razorberry.razor.samples.examples
{
	import razor.controls.Label;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.Settings;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;

	public class LabelExample extends Container
	{
		public var controlFactory:ControlFactory;
		protected var label1:Label;
		protected var label2:Label;
		protected var label3:Label;
		
		public function LabelExample()
		{
			// NOTE: In our sample application we create a new ControlFactory
			// for each example. You normally wouldn't need to do this.
			controlFactory = new ControlFactory();
			controlFactory.rootStyleSheet = new PlasticStyleSheet();
			
			setStyles();
			super();
		}
		
		protected function setStyles():void
		{
			// NOTE: In our sample application we created a new ControlFactory
			// for each example. You can also get a reference to the global rootStyleSheet
			// from: Settings.rootStyleSheet  OR  ControlFactory.defaultFactory.rootStyleSheet
			var sheet:StyleSheet = controlFactory.rootStyleSheet;
			
			sheet.addRule("Label", new StyleSheet({fontFace: "Arial"}));
			sheet.addRule("title", new StyleSheet({fontSize: 16, bold: true, underline: true}));
			sheet.addRule("subtitle", new StyleSheet({fontSize: 14}));
		}
		
		override protected function construct():void
		{
			label1 = controlFactory.create(Label, "title") as Label;
			label1.autoSize = "left";
			label1.text = "Label example";
			addChild(label1);
			
			label2 = controlFactory.create(Label, "subtitle") as Label;
			label2.autoSize = "center";
			label2.wordWrap = true;
			label2.selectable = true;
			label2.text = "\"Example isn't another way to teach, it is the only way to teach.\"";
			addChild(label2);
			
			label3 = controlFactory.create(Label, "subtitle") as Label;
			label3.autoSize = "center";
			label3.wordWrap = true;
			label3.text = "-Albert Einstein";
			label3.mergeStyle({italic: true, fontSize: 12, align: "right"});
			addChild(label3);
		}
		
		override protected function layout():void
		{
			label1.move(10,10);
			label2.width = __width - 20;
			label2.move(10, 10 + label1.height);
			label3.width = __width - 20;
			label3.move(10, label2.y + label2.height);
			
		}
	}
}
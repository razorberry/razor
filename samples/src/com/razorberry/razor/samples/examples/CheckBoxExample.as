package com.razorberry.razor.samples.examples
{
	import razor.controls.CheckBox;
	import razor.controls.RadioButton;
	import razor.controls.RadioGroup;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Regular;

	public class CheckBoxExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var checkBox1:CheckBox;
		protected var checkBox2:CheckBox;
		protected var checkBox3:CheckBox;
		protected var radio1:RadioButton;
		protected var radio2:RadioButton;
		protected var radio3:RadioButton;
		
		public function CheckBoxExample()
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
			checkBox1 = controlFactory.create(CheckBox) as CheckBox;
			checkBox1.label = "One";
			addChild(checkBox1);
			
			checkBox2 = controlFactory.create(CheckBox) as CheckBox;
			checkBox2.label = "Two";
			addChild(checkBox2);
			
			checkBox3 = controlFactory.create(CheckBox) as CheckBox;
			checkBox3.label = "Three";
			addChild(checkBox3);
			
			var group:RadioGroup = new RadioGroup();
			radio1 = controlFactory.create(RadioButton) as RadioButton;
			radio1.label = "Choice A";
			radio1.group = group;  // Assign the radio button to a RadioGroup
			addChild(radio1);
			
			radio2 = controlFactory.create(RadioButton) as RadioButton;
			radio2.label = "Choice B";
			radio2.group = group;  // Assign the radio button to a RadioGroup
			addChild(radio2);
			
			radio3 = controlFactory.create(RadioButton) as RadioButton;
			radio3.label = "Choice C";
			radio3.group = group;  // Assign the radio button to a RadioGroup
			addChild(radio3);
		}
		
		override protected function layout():void
		{
			checkBox1.setSize(__width/2 - 20, 20);
			checkBox1.move(10, 10);
			checkBox2.setSize(__width/2 - 20, 20);
			checkBox2.move(10, 40);
			checkBox3.setSize(__width/2 - 20, 20);
			checkBox3.move(10, 70);
			
			radio1.setSize(__width/2 - 20, 20);
			radio1.move(__width/2 + 10, 10);
			radio2.setSize(__width/2 - 20, 20);
			radio2.move(__width/2 + 10, 40);
			radio3.setSize(__width/2 - 20, 20);
			radio3.move(__width/2 + 10, 70);
		}
		
		
	}
}
package com.razorberry.razor.samples.examples
{
	import flash.events.Event;
	
	import razor.controls.ColorPicker;
	import razor.controls.ColorSwatch;
	import razor.controls.TextInput;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Sharp;

	public class ColorPickerExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var swatch:ColorSwatch;
		protected var colorPicker:ColorPicker;
		protected var textInput1:TextInput;
		protected var textInput2:TextInput;
		
		public function ColorPickerExample()
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
			colorPicker = controlFactory.create(ColorPicker) as ColorPicker;
			colorPicker.addEventListener(ColorPicker.E_CHANGE, onColorPickerChange);
			addChild(colorPicker);
			
			swatch = controlFactory.create(ColorSwatch) as ColorSwatch;
			swatch.color = 0x64cce9;
			swatch.addEventListener(ColorSwatch.E_CHANGE, onSwatchChange);
			addChild(swatch);
			
			textInput1 = controlFactory.create(TextInput) as TextInput;
			textInput1.editable = false;
			addChild(textInput1);
			
			textInput2 = controlFactory.create(TextInput) as TextInput;
			textInput2.editable = false;
			addChild(textInput2);
			
			onColorPickerChange(null);
			onSwatchChange(null);
		}
		
		override protected function layout():void
		{
			colorPicker.setSize(__width/2 - 20, __height - 60);
			colorPicker.move(10,10);
			
			swatch.setSize(22,20);
			swatch.move(__width/2 + 10, 10);
			
			textInput1.setSize(__width/2-20, 22);
			textInput1.move(10,__height - 40);
			
			textInput2.setSize(__width/2-20, 22);
			textInput2.move(__width/2+10,__height - 40);
		}
		
		protected function onColorPickerChange(e:Event):void
		{
			textInput1.text = "#"+colorPicker.hex.toUpperCase();
		}
		
		protected function onSwatchChange(e:Event):void
		{
			textInput2.text = "#"+swatch.hex.toUpperCase();
		}
	}
}
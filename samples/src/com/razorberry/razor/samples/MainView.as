package com.razorberry.razor.samples
{
	import com.razorberry.razor.samples.examples.*;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import razor.controls.List;
	import razor.controls.TextArea;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.layout.LayoutData;
	import razor.layout.Pane;

	public class MainView extends Container
	{
		protected var list:List;
		protected var sourceField:TextArea;
		protected var stagingArea:Pane;
		protected var currentSample:Container;
		protected var loader:URLLoader;
		
		protected var dp:Array =
		[
			{klass: LabelExample, label: "Label Example"},
			{klass: ButtonExampleOne, label: "Button Example 1"},
			{klass: ButtonExampleTwo, label: "Button Example 2"},
			{klass: TextAreaExampleOne, label: "Text Input / Text Area"},
			{klass: CheckBoxExample, label: "CheckBox / Radio Button"},
			{klass: ProgressBarExample, label: "ProgressBar"},
			{klass: ScrollBarExample, label: "ScrollBar"},
			{klass: ListExample, label: "List / ComboBox"},
			{klass: CalendarExample, label: "Calendar / DateChooser"},
			{klass: ColorPickerExample, label: "ColorPicker / ColorSwatch"},
			{klass: ProgressSkinningExample, label: "Replacing a skin element"},
			{klass: ItemRendererExample, label: "List Item Renderer"},
			{klass: BoxExample, label: "Box Example"}
		];
		
		public function MainView()
		{
			
		}
		
		override protected function construct():void
		{
			list = new List();
			list.addEventListener(List.E_SELECT, onListSelect);
			addChild(list);
			
			list.dataProvider = dp;
			
			sourceField = new TextArea();
			addChild(sourceField);
			
			var css:ByteArray = new SampleAssets.sourceCSS();
			var cssStr:String = css.readUTFBytes(css.length).replace(/[\n\r\t]*/g,"");
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS(cssStr);
			sourceField.styleSheet = ss;
			
			stagingArea = new Pane();
			
			stagingArea.label = "Example";
			addChild(stagingArea);
		}
		
		override protected function layout():void
		{
			list.setSize(Math.max(__width/4, 140), __height); 
			sourceField.setSize(__width*3/4 - 10, __height/2 - 5);
			sourceField.move(__width/4 + 10, 0);
			stagingArea.move(__width/4 + 10, __height/2+5);
			stagingArea.setSize(__width *3/4 - 10, __height/2 - 5);
		}
		
		protected function onListSelect(e:Event):void
		{
			if (currentSample)
			{
				stagingArea.destroyChild(currentSample);
				currentSample = null;
			}
			var o:Object = dp[list.selectedIndex];
			
			currentSample = ControlFactory.create(o.klass) as Container;
			stagingArea.addChildWithLayout(currentSample, new LayoutData(null, 100, __height/2-40, LayoutData.TYPE_PERCENT, LayoutData.TYPE_PIXELS));
			loadSource(currentSample);
		}
		
		protected function loadSource(sample:Object):void
		{
			sourceField.html = true;
			sourceField.text = "";
			
			if (loader)
			{
				try
				{
					loader.close();
				}
				catch (e:Error)
				{
					
				}
			}
			
			loader = new URLLoader();
			var className:String = flash.utils.getQualifiedClassName(sample).split("::")[1];
			var req:URLRequest = new URLRequest("samplesrc/source/com/razorberry/razor/samples/examples/"+className+".as.html");
			loader.addEventListener(Event.COMPLETE, onSourceLoad, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			loader.load(req);
		}
		
		protected function onSourceLoad(e:Event):void
		{
			var str:String = loader.data as String;
			sourceField.text = str.replace(/[\r]*/g, "");
		}
		
		protected function onIOError(e:IOErrorEvent):void
		{
			// Do nothing.
		}
		
		protected function onSecurityError(e:SecurityErrorEvent):void
		{
			// Do nothing.
		}
	}
}
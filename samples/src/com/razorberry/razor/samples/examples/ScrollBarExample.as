package com.razorberry.razor.samples.examples
{
	import com.razorberry.razor.samples.SampleAssets;
	
	import flash.events.Event;
	
	import razor.controls.Image;
	import razor.controls.ScrollBar;
	import razor.core.Container;
	import razor.core.ControlFactory;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Regular;

	public class ScrollBarExample extends Container
	{
		public var controlFactory:ControlFactory;
		
		protected var scrollbar:ScrollBar;
		protected var scrollbar2:ScrollBar;
		protected var image:Image;
		
		public function ScrollBarExample()
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
			scrollbar = controlFactory.create(ScrollBar) as ScrollBar;
			scrollbar.setScrollProperties(10,50,300);  // pageSize, minimum value, maximum value
			scrollbar.horizontal = true;
			scrollbar.roundPosition = true;  // round the scrollbar position to the nearest whole number
			scrollbar.addEventListener(ScrollBar.E_SCROLL, onScrollBarScroll);
			addChild(scrollbar);
			
			scrollbar2 = controlFactory.create(ScrollBar) as ScrollBar;
			scrollbar2.setScrollProperties(10,50,180);  // pageSize, minimum value, maximum value
			scrollbar2.roundPosition = true;   // round the scrollbar position to the nearest whole number
			scrollbar2.addEventListener(ScrollBar.E_SCROLL, onScrollBarScroll);
			addChild(scrollbar2);
			
			// We will have the scrollbars adjust the size of a stretchy
			// image just to demonstrate the listeners.
			image = controlFactory.create(Image) as Image;
			image.sourceClass = SampleAssets.background;
			image.scaleContent = true;
			image.keepAspectRatio = false;
			image.centerContent = false;
			addChild(image);
		}
		
		override protected function layout():void
		{
			scrollbar.move(__width/6, 10);
			scrollbar.setSize(__width*2/3, 18);
			
			scrollbar2.move(__width*5/6, 34);
			scrollbar2.setSize(18, __height - 44);
			
			image.move(Math.floor(__width/6), 30);
			image.setSize(50,50);
		}
		
		protected function onScrollBarScroll(e:Event):void
		{
			image.setSize(scrollbar.scrollPosition, scrollbar2.scrollPosition);
		}
	}
}
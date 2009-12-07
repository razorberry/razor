package {
	import com.adobe.viewsource.ViewSource;
	import com.razorberry.razor.samples.MainView;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import razor.skins.Settings;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Regular;

	[SWF(width="700", height="550", frameRate="31")]
	public class RazorSamples extends Sprite
	{
		protected var mainView:MainView;
		
		public function RazorSamples()
		{
			initialize();
		}
		
		protected function initialize():void
		{
			ViewSource.addMenuItem(this, "http://www.razorberry.com/components/samplesrc/");
			
			Settings.setSkin(new PlasticStyleSheet(), new Regular());
			//Settings.setSkin(new MinimalStyleSheet());
			stage.addEventListener(Event.RESIZE, onStageResize);
			mainView = addChild(new MainView()) as MainView;
			
			stage.scaleMode = "noScale";
			stage.align = "TL";
			onStageResize();
		}
		
		protected function onStageResize(e:Event = null):void
		{
			mainView.setSize(stage.stageWidth - 40, stage.stageHeight - 40);
			mainView.move(20,20);
		}
	}
}

package razor.controls
{
	import razor.core.razor_internal;
	import razor.layout.Layer;
	import razor.layout.ModalLayer;
	import razor.skins.Settings;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.presets.Regular;
	
	public class Application extends Layer
	{
		use namespace razor_internal;
		
		
		private var _applicationPreInitialize:Function;
		
		public function Application()
		{
			ModalLayer.setApplication(this);
			//trace("setting skin");
			Settings.setSkin(new PlasticStyleSheet(), new Regular());
			
			
			super();
		}
		
		public function get applicationPreInitialize():Function
		{
			return _applicationPreInitialize;
		}

		public function set applicationPreInitialize(v:Function):void
		{
			//trace("setting preinit");
			_applicationPreInitialize = v;
			if (_applicationPreInitialize != null)
			_applicationPreInitialize();
			
		}

	}
}
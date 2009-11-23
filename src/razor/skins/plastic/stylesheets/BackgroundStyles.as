package razor.skins.plastic.stylesheets 
{
	import razor.skins.plastic.Rectangle;
	import razor.skins.StyleSheet;
	
	public class BackgroundStyles extends StyleSheet
	{
		public static var baseClass:Class = Rectangle;
		public static var style:Object;
		public static var states:Object = { Over: new BackgroundOverStyles(),
											Down: new BackgroundDownStyles(),
											Disabled: new BackgroundDisabledStyles() };
	}
	
}
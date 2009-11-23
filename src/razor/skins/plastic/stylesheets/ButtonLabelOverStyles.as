package razor.skins.plastic.stylesheets 
{
	import razor.controls.Label;
	import razor.skins.StyleSheet;
	
	public class ButtonLabelOverStyles extends StyleSheet
	{
		public static var baseClass:Class = Label;
		public static var style:Object = { modifyBrightness: 0.05 };
	}
}
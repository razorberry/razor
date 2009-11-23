package razor.skins.plastic.stylesheets 
{
	import razor.skins.NullContainer;
	import razor.skins.plastic.Radio;
	import razor.skins.StyleSheet;

	public class RadioButtonOverlayStyles extends StyleSheet
	{
		public static var baseClass:Class = NullContainer;
		public static var style:Object;
		public static var states:Object = { Checked: new StyleSheet({ roundedness: 10000 }, Radio) };
	}
}
package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class CheckBoxStyles extends StyleSheet
	{
		public var Background:StyleSheet = new InsetBackgroundStyles();
		public var Label:StyleSheet;
		public var Overlay:StyleSheet = new CheckBoxOverlayStyles();
	}
}
package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class RadioButtonStyles extends StyleSheet
	{
		public var Background:StyleSheet = new RadioButtonBackgroundStyles();
		public var Label:StyleSheet;
		public var Overlay:StyleSheet = new RadioButtonOverlayStyles();
	}
}
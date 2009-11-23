package razor.skins.plastic.stylesheets 
{
	import razor.controls.Button;
	import razor.skins.StyleSheet;

	public class ComboBoxStyles extends StyleSheet
	{
		public var Arrow:StyleSheet; // inherited
		public var Background:StyleSheet = new InsetBackgroundStyles();
		public var Label:StyleSheet; // inherited
		public var List:StyleSheet; // inherited
		public var ToggleButton:StyleSheet = new StyleSheet(null, Button);
		public var Overlay:StyleSheet; // inherited
	}
}
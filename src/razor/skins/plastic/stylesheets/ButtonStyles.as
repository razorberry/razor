package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class ButtonStyles extends StyleSheet
	{
		public var Background:StyleSheet; // inherited
		public var Label:StyleSheet = new ButtonLabelStyles();
		public var Overlay:StyleSheet; // inherited
	}
}
package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class ProgressBarStyles extends StyleSheet
	{
		public var Background:StyleSheet = new ProgressBarBackgroundStyles();
		public var Bar:StyleSheet = new ProgressBarBarStyles();
		public var Label:StyleSheet; // inherited
		public var Overlay:StyleSheet; // inherited
	}
}
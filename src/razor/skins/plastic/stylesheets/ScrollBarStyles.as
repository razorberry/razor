package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class ScrollBarStyles extends StyleSheet
	{
		public var Arrow:StyleSheet; // inherited
		public var Background:StyleSheet = new ScrollBarBackgroundStyles(); 
		public var UpButton:StyleSheet = new ScrollBarButtonStyles();
		public var DownButton:StyleSheet = new ScrollBarButtonStyles();
		public var Thumb:StyleSheet = new ScrollBarButtonStyles();
	}
}
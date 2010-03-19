package razor.skins.plastic.stylesheets 
{
	import razor.skins.NullContainer;
	import razor.graphics.Check;
	import razor.skins.StyleSheet;

	public class CheckBoxOverlayStyles extends StyleSheet
	{
		public static var baseClass:Class = NullContainer;
		public static var style:Object;
		public static var states:Object = { Checked: new StyleSheet(null, Check) };
	}
}
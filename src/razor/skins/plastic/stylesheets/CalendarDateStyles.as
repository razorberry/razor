package razor.skins.plastic.stylesheets 
{
	import razor.controls.calendar.CalendarDateRenderer;
	import razor.skins.NullContainer;
	import razor.skins.StyleSheet;

	public class CalendarDateStyles extends StyleSheet
	{
		public static var baseClass:Class = CalendarDateRenderer;
		public static var style:Object = { roundedness: 0, bevel: 0, variance: 0 };
		
		public var Background:StyleSheet = new StyleSheet( null, NullContainer );
		public var Label:StyleSheet;
	}
}
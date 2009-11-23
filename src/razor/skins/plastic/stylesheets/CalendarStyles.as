package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;

	public class CalendarStyles extends StyleSheet
	{
		public var Background:StyleSheet;
		public var Overlay:StyleSheet;
		public var DateRenderer:StyleSheet = new CalendarDateStyles();
		public var DayHeaderRenderer:StyleSheet = new CalendarDayHeaderStyles();
		public var HeaderRenderer:StyleSheet = new CalendarHeaderStyles();
	}
}
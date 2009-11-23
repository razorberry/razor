package razor.skins.plastic.stylesheets
{
	import razor.controls.Button;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.CalendarIcon;

	public class DateChooserStyles extends StyleSheet
	{
		public var Icon:StyleSheet = new StyleSheet(null, CalendarIcon);
		public var TextInput:StyleSheet;
		public var Calendar:StyleSheet;
		public var ToggleButton:StyleSheet = new StyleSheet(null, Button);
	}
}
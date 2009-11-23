package razor.skins.plastic.stylesheets 
{
	import razor.controls.grid.SelectableCell;
	import razor.skins.StyleSheet;
	
	public class ListCellStyles extends StyleSheet
	{
		public static var baseClass:Class = SelectableCell;
		public static var style:Object = { shadow: 0, bevel: 0, glossiness: 0, borderThickness: 0, variance: 0, roundedness: 0 };
		
		public var Button:StyleSheet = new ListCellButtonStyles();
	}
}
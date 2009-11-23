package razor.skins.plastic.stylesheets 
{
	import razor.skins.plastic.Rectangle;
	import razor.skins.StyleSheet;

	public class ListCellButtonStyles extends StyleSheet
	{
		public var Background:StyleSheet = new StyleSheet(null, null,
			{
				Up: new StyleSheet( { opacity: 0.01 }, Rectangle),
				Over: new StyleSheet( { baseColor:0xffffff, opacity: 0.2 }, Rectangle),
				Down: new StyleSheet( { baseColor:0, opacity: 0.2 }, Rectangle)
			} );
		public var Label:StyleSheet; //inherited
		public var Overlay:StyleSheet; // inherited
	}
}
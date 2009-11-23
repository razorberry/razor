package razor.skins.plastic.stylesheets
{
	import razor.core.tooltips.BasicTooltip;
	import razor.skins.StyleSheet;

	public class TooltipStyles extends StyleSheet
	{
		public static var baseClass:Class = BasicTooltip;
		public static var style:Object = {roundedness: 0, variance: 0, bevel:0, baseColor: 0xfafbc5, borderThickness: 1,
			border:0xf5f792, padding_l:3, padding_r: 3};
		public var Background:StyleSheet; // inherited
		public var Label:StyleSheet = new ButtonLabelStyles();
		public var Overlay:StyleSheet; // inherited
	}
}
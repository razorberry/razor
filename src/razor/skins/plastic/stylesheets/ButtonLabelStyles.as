package razor.skins.plastic.stylesheets 
{
	import razor.skins.StyleSheet;
	import razor.controls.Label;

	public class ButtonLabelStyles extends StyleSheet
	{
		public static var baseClass:Class = Label;
		public static var style:Object = {fontColor: 0x000000, align: "center"};
		public static var states:Object = { Over: new ButtonLabelOverStyles(),
											Down: new ButtonLabelDownStyles() };
											
		
	}
}
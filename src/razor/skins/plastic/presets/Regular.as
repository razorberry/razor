package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Regular extends Style
	{
		override protected function setOverrides():void
		{
			bevel = 2;
			roundedness = 2;
			glossiness = 0.8;
			variance = 0.5;
			border = 0x666699;
			borderThickness = 0.5;
			baseColor = 0xF5F5FC;
			shadow = 2;
		}
	}
}
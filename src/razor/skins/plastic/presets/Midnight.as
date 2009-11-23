package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Midnight extends Style
	{
		override protected function setOverrides():void
		{
			bevel = 4;
			variance = 0.5;
			roundedness = 1;
			glossiness = 0.5;
			baseColor = 0x99;
			fontColor = 0xDDE0FF;
			border = 0xDDE0FF;
		}
	}
}
package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Glass extends Style
	{
		override protected function setOverrides():void
		{
			bevel = 0;
			variance = -1.2;
			azimuth = -75;
			roundedness = 5;
			glossiness = 1.3;
			border = 0x556699;
			baseColor = 0xE7E9FC;
			fontColor = 0x332266;
		}
	}
}
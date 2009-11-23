package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Sharp extends Style
	{
		override protected function setOverrides():void
		{
			bevel = 3;
			roundedness = 0;
			glossiness = 1.2;
			variance = 0.5;
			border = 0x666666;
			borderThickness = 1;
			baseColor = 0xF5F5F5;
			shadow = 2;
		}
	}
}
package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Plain extends Style
	{
		override protected function setOverrides():void
		{
			bevel = 0;
			roundedness = 0;
			glossiness = 0;
			variance = -0.4;
			border = 0x777777;
			borderThickness = 1;
			baseColor = 0xF0F0F0;
		}
		
	}
}
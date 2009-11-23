package razor.skins.plastic.presets
{
	import razor.skins.Style;

	public class Default extends Style
	{
		override protected function setOverrides():void
		{
			//baseColor=0x336600;
			bevel = 2;
			roundedness = 4;
			glossiness = 0.8;
			border = 0x999999;
			borderThickness = 0.5;
			shadow = 2;
		}
		
	}
}
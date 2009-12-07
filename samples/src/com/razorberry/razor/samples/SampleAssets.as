package com.razorberry.razor.samples
{
	public class SampleAssets
	{
		[Embed(source="/../assets/button_up.png", scaleGridTop="8", scaleGridLeft="38", scaleGridRight="173", scaleGridBottom="21")]
		public static var button_up:Class;
		[Embed(source="/../assets/button_over.png", scaleGridTop="8", scaleGridLeft="38", scaleGridRight="173", scaleGridBottom="21")]
		public static var button_over:Class;
		[Embed(source="/../assets/button_down.png", scaleGridTop="8", scaleGridLeft="38", scaleGridRight="173", scaleGridBottom="21")]
		public static var button_down:Class;
		[Embed(source="/../assets/button_disabled.png", scaleGridTop="8", scaleGridLeft="38", scaleGridRight="173", scaleGridBottom="21")]
		public static var button_disabled:Class;
		
		[Embed(source="/../assets/background.png", scaleGridTop="10", scaleGridLeft="95", scaleGridRight="272", scaleGridBottom="172")]
		public static var background:Class;
		
		
		[Embed(source="/../assets/maxine.ttf", fontName="Maxine", mimeType="application/x-font-truetype")]
		public static var maxine:Class;
		
		[Embed(source="/../assets/SourceStyles.css", mimeType="application/octet-stream")]
		public static var sourceCSS:Class;
	}
}
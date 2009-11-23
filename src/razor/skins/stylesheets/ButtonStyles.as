
package razor.skins.stylesheets
{
	import razor.skins.SkinBitmap;
	import razor.skins.StyleSheet;

	public class ButtonStyles extends StyleSheet
	{
		public var Background:StyleSheet;
		public var Label:StyleSheet;
		public var Overlay:StyleSheet;
		
		/**
		 * Constructor.
		 * Provides shortcut functionality for skinning a button with bitmaps.
		 */
		public function ButtonStyles(upSkin:* = null, overSkin:* = null, downSkin:* = null, disabledSkin:* = null, scaleNine:Array = null)
		{
			if (upSkin != null || overSkin != null || downSkin != null || disabledSkin != null)
			{
				Overlay = new NullStyles();
				if (downSkin == null)
					downSkin = overSkin ? overSkin : upSkin;
				if (overSkin == null)
					overSkin = upSkin;
				if (disabledSkin == null)
					disabledSkin = upSkin;
					
				Background = new StyleSheet(null, null, { Up: new StyleSheet({ skinClass: upSkin as Class, linkage: upSkin as String, scaleNine: scaleNine }, SkinBitmap),
														  Over: new StyleSheet({ skinClass: overSkin as Class, linkage: overSkin as String, scaleNine: scaleNine }, SkinBitmap),
														  Down: new StyleSheet({ skinClass: downSkin as Class, linkage: downSkin as String, scaleNine: scaleNine }, SkinBitmap),
														  Disabled: new StyleSheet({ skinClass: disabledSkin as Class, linkage: disabledSkin as String, scaleNine: scaleNine }, SkinBitmap)} );
			}
		}
	}
	
}

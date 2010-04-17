/*****************************************************************************
* Razor Component Framework for ActionScript 3.
* Copyright 2009 Ashley Atkins (www.razorberry.com)
* 
* This file is part of the Razor Component Framework, which is made available
* under the MIT License.
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*******************************************************************************/

package razor.skins 
{
	import razor.core.AssetCache;
	import razor.core.ControlFactory;
	import razor.skins.stylesheets.RootStyleSheet;
	
	/**
	 * Static class to hold all component skin settings.
	 * Before you create a razor component, you should at least attach a skin StyleSheet to the rootStyleSheet instance.
	 * @example <listing version="3.0">Settings.setSkin(new PlasticStyleSheet())</listing>
	 */
	public final class Settings 
	{
		private static var _controlFactory:ControlFactory;
		private static var _assets:AssetCache;
		
		public function Settings() {}
		
		private static var __instance:Settings = new Settings();
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Helper method to set the default global skin. 
		 * @param styleSheet	A StyleSheet to use.
		 * @param defaultStyle	A Style instance to use.
		 * 
		 */		
		public static function setSkin(styleSheet:StyleSheet, defaultStyle:Style = null):void
		{
			var ss:StyleSheet = new RootStyleSheet();
			ss.appendStyleSheet(styleSheet);
			
			rootStyleSheet = ss;
			
			style = defaultStyle ? defaultStyle : new Style();
		}
		
		/**
		 * Get/set the root StyleSheet instance.
		 */
		public static function set rootStyleSheet(styleSheet:StyleSheet):void
		{
			if (styleSheet != null)
				defaultFactory.rootStyleSheet = styleSheet;
		}
		
		/** @private */
		public static function get rootStyleSheet():StyleSheet
		{
			return defaultFactory.rootStyleSheet;
		}
		
		/**
		* Set/Get the default ControlFactory instance.
		* @param factory A ControlFactory instance to use.
		*/
		public function set defaultFactory(factory:ControlFactory):void
		{
			ControlFactory.defaultFactory = factory;
		}
		
		/** @private */
		public static function get defaultFactory():ControlFactory
		{
			return ControlFactory.defaultFactory;
		}
		
		/**
		* Get/Set the default style for all components.
		* @param	s	The style to use as default for all components.
		*/
		public static function set style(s:Style):void
		{
			defaultFactory.defaultStyle = style;
		}
		
		/** @private */
		public static function get style():razor.skins.Style
		{
			return defaultFactory.defaultStyle;
		}
		
		/**
		 * Check if the current skin has a particular tag defined
		 * @param styleChain	An array of selectors
		 */
		public static function hasBlueprint(styleChain:Array):Boolean
		{
			return (rootStyleSheet.findStyle(styleChain) != null);
		}
		
		/**
		 * Retrieve the global asset cache instance.
		 * @see AssetCache
		 */
		public static function get assets():AssetCache
		{
			if (_assets == null)
				_assets = new AssetCache();
				
			return _assets;
		}
	}
	
}

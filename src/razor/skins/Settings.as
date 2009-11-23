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
		private static var _rootStyleSheet:StyleSheet = new RootStyleSheet();
		private static var _style:Style;
		private static var _constructor:Class = Style;
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
			rootStyleSheet = new RootStyleSheet();
			rootStyleSheet.appendStyleSheet(styleSheet);
			style = defaultStyle ? defaultStyle : new Style();
		}
		
		/**
		 * Get/set the root StyleSheet instance.
		 */
		public static function set rootStyleSheet(styleSheet:StyleSheet):void
		{
			if (styleSheet != null)
				_rootStyleSheet = styleSheet;
		}
		
		/** @private */
		public static function get rootStyleSheet():StyleSheet
		{
			return _rootStyleSheet;
		}
		
		/**
		* Set/Get the default ControlFactory instance.
		* @param factory A ControlFactory instance to use.
		*/
		public function set defaultFactory(factory:ControlFactory):void
		{
			_controlFactory = factory;
		}
		
		/** @private */
		public static function get defaultFactory():ControlFactory
		{
			if (_controlFactory == null)
			{
				_controlFactory = new ControlFactory();
			}
			
			return _controlFactory;
		}
		
		/**
		* Get/Set the default style for all components.
		* @param	s	The style to use as default for all components.
		*/
		public static function set style(s:razor.skins.Style):void
		{
			_style = s;
			_constructor = Object(_style).constructor;
		}
		
		/** @private */
		public static function get style():razor.skins.Style
		{
			// TODO: discrepancy between this and as2 version, which just returns a new _style()
			var newStyle:Style = (new _constructor() as Style);
			newStyle.integrate(_style);
			return newStyle;
		}
		
		/**
		 * Check if the current skin has a particular tag defined
		 * @param styleChain	An array of selectors
		 */
		public static function hasBlueprint(styleChain:Array):Boolean
		{
			return (_rootStyleSheet.findStyle(styleChain) != null);
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

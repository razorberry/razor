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

package razor.utils
{
	import razor.skins.StyleSheet;
	
	/**
	 * Experimental and incomplete css parser. DO NOT USE
	 */
	public class CSSParser
	{
		
		public static function parseCSS(str:String):StyleSheet
		{
			// First create a stylesheet to attach all of our rules to
			var ss:StyleSheet = new StyleSheet();
			
			//var css:String = "  Blah     { \r\n whee : 15 px; \r\n  /* another comment */    yay: #ffbb00 \r\n } /* Comment\r\n  */ \r\n   Bike  Pedal // Bike pedal! \r\n{ woo: 23 }";
			var css:String = str;
			// Remove comments..
			css = css.replace(/\/\*.*?\*\//gms, "");
			css = css.replace(/\/\/.*$/gm, "");
			//trace(css);
			// Grab the rules by matching the brackets
			var arr:Array = css.match(/(.*?{.*?})/gms);
			
			var finalRules:Array = new Array();
			
			for (var i:int = 0; i < arr.length; i++)
			{
				var oo:Object = new Object();
				var parts:Array = arr[i].split("{");
				// Grab the selector, and the rules.
				var sel:String = parts[0];
				// Trim surrounding whitespace
				sel = sel.replace(/^\s+|\s+$/g, "");
				// Condense internal whitespace
				sel = sel.replace(/(\S\s)\s+/, "$1");
				
				var styles:String = String(parts[1]);
				// Match name:value pairs
				var b:Array = styles.match(/[\w-]+\s*?:\s*?.*?[\r\n;}]$/gms);
				
				for (var j:int = 0; j < b.length; j++)
				{
					// Trim spaces, closing brackets, and semi colons, then split at the colon:
					var styleArr:Array = (b[j].replace(/^\s+|\s+$|[};]/gms,"")).split(":");
					// Trim out all spaces from the name.
					var styleName:String = String(styleArr[0]).replace(/\s/,"");
					// Trim spaces from the value.
					var styleValue:String = String(styleArr[1]).replace(/^\s+|\s+$/g, "");
					// TODO: split multiple values into an array
					
					oo[styleName] = convertType(styleValue);
				}
				finalRules.push({name: sel, styles: oo});
			}
			
			for (var k:int = 0; k < finalRules.length; k++)
			{
				ss.addRule(finalRules[k].name, new StyleSheet(finalRules[k].styles));
			}
			trace("asdf");
			
			return ss;
		}
		
		private static function convertType(str:String):*
		{
			// Remove px/pt/em from any numbers:
			str = str.replace(/(\d+?)\s*?(px|pt|em)/,"$1");
			// Convert #color values to a hex number
			str = str.replace(/#([\dabcdef]+?)/g, "0x$1");
			if (!isNaN(Number(str)))
				return Number(str);
			else
			{
				if (str == "true") return true;
				else if (str == "false") return false;
				else return str.replace(/^"+|"+$/gms, "");  // remove start and end quotes from strings
			}
		}
	}
}
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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	
	import razor.core.RazorEvent;
	import razor.core.razor_internal;
	import razor.utils.ColorUtils;

	[Event(name="change", type="flash.events.Event")]
	
	/**
	* Class to represent a single style.
	* You can integrate a style into other styles in order to combine them.
	* Calling styleA.integrate(styleB), will copy all non-default parameters from
	* styleB into styleA.
	* Styles will cascade into controls when you call component.mergeStyle(style).
	* This means you can set the style on a TextArea, and it will also set the style
	* on the scrollbars contained within.
	*/
	public class Style extends EventDispatcher
	{
		public static const E_CHANGE:String = Event.CHANGE;
		
		// Text format
		public var fontFace:String = "_sans";
		public var fontSize:uint = 12;
		public var fontColor:uint = 0;
		public var align:String = "left";
		public var bold:Boolean = false;
		public var italic:Boolean = false;
		public var underline:Boolean = false;
		public var leading:Number = 0;
		public var embedFonts:Boolean = false;
		public var sharpText:Boolean = false;
		
		public var baseColor:uint = 0xe0e0e0;
		public var border:uint = 0x666666;
		// borderThickness can be an Array [ t, b, l, r ];
		public var borderThickness:* = 0.5;
		// bevel can be an array [ t, b, l, r ];
		public var bevel:* = 0;
		// Roundedness can be a Number or an Array: [tl, tr, bl, br]
		public var roundedness:* = 0;
		public var variance:Number = 1;
		public var glossiness:Number = 0;  //0-1
		public var azimuth:Number = -45;
		public var shadow:Number = 3;
		
		public var inset:Boolean = false;
		public var opacity:Number = 1;    // 0-1
		public var modifyBrightness:Number = 0;
		public var fade:Number = 0;
		
		public var margin_l:Number = 0;
		public var margin_r:Number = 0;
		public var margin_t:Number = 0;
		public var margin_b:Number = 0;
		public var padding_l:Number = 0;
		public var padding_r:Number = 0;
		public var padding_t:Number = 0;
		public var padding_b:Number = 0;
		
		// Settings for SkinBitmap:
		public var url:String;
		public var linkage:String;
		public var skinClass:Class;
		public var scaleNine:Array; // [l,t,r,b]
		
		/**
		* Constructor.
		* @param	initObj		(Optional) An object or style to merge into this style.
		*/
		public function Style(initObj:Object = null)
		{
			setOverrides();
			
			// Gather a list of properties on this style.
			// This should only happen once per Style subclass, since we store the list
			// in the prototype. See get propertyList method.
			if (!(propertyList is Object))
				gatherProperties();
			
			if (initObj != null)
				integrate(initObj);
		}
		
		/**
		 * Set your style defaults in this method.
		 * @example
		 * <listing version="3.0">
		 * override protected function setOverrides():void
		 * {
		 * 		bevel = 4;
		 * 		roundedness = 8;
		 * }
		 * </listing>
		 */
		protected function setOverrides():void
		{
			// Override me!
		}
		
		/** @private */
		protected function gatherProperties():void
		{
			var properties:Object = new Object();
			var o:Object = this as Object;
			var p:Class = o.constructor;
			var type:XML = flash.utils.describeType(p);
			var l:XMLList = (type.factory..variable.@name);
			for each (var s:String in l)
				properties[s] = o[s];
			p["__razor_defaults__"] = properties;
		}
		
		/**
		* Merge a style into this style. Dispatches a change event.
		* @param	style	The style to merge into this.
		*/
		public function combine(style:Style):void
		{
			//trace("Style.combine("+mx.data.binding.ObjectDumper.toString(s)+")");
			var c:Boolean = integrate(style);
			if (c) dispatchEvent(new RazorEvent(E_CHANGE));
		}
		
		/**
		* Notify listeners of this style of an update. Usually triggers a redraw.
		*/
		public function update():void
		{
			dispatchEvent(new RazorEvent(E_CHANGE));
		}
		
		/**
		* Gets a default copy of this style.
		* @return
		*/
		public static function get defaults():Style
		{
			return new Style();
		}
		
		/**
		* Merges an object or style into this style.
		* Any non-default parameters in the argument will overwrite parameters in this style.
		* Unlike #combine, this method does not dispatch a change event.
		* @param	o	The object or style to integrate.
		* @return	A boolean indicating whether anything has changed in the original style.
		*/
		public function integrate(o:Object, noPrecedence:Boolean = false, userStyles:Boolean = false):Boolean
		{
			use namespace razor_internal;
			
			if (!o || o == this) return false;
			
			var c:Boolean = false;
			var t:Style = this;
			var tob:Object = this as Object;
			var p:Class = tob.constructor;
			var tcl:Object = changedList;
			var tp:Object = propertyList;
			var op:Object = o.propertyList;
			var todo:Object = o is Style ? tp : o;
			// FOR EACH var in integrating proto
			for (var z:String in todo)
			{
				// Only check properties that Style has (because skins can include sub-definitions):
				if (!t.hasOwnProperty(z))
					continue;
					
				var tChanged:Boolean = (t[z] != tp[z]) || tcl[z];
				var oChanged:Boolean = (op == null || o[z] != op[z]) && !noPrecedence ;
				// IF this proto var IS NOT integrating var
				// AND this var IS this proto var (dont change runtime values on this)
				// then copy integrating var to this.
				if (tChanged && !oChanged)
					continue;
				
				c = true;
				
				if (o[z] is Array)
					t[z] = o[z].concat();
				else
					t[z] = o[z];
					
				if (userStyles)
					tcl[z] = true;
			}
			
			if (o is Style)
			{
				var cl:Object = o.changedList;
				
				for (var zz:String in cl)
					tcl[zz] = cl[zz];
			}
			
			return c;
		}
		
		/**
		* Get a TextFormat object representing the settings in this style.
		* @return	This style's TextFormat.
		*/
		public function get textFormat():TextFormat
		{
			return new TextFormat(fontFace, fontSize, modifyBrightness != 0 ? ColorUtils.brighten(fontColor, modifyBrightness) : fontColor,
									 bold, italic, underline, null, null,
									 align, null, null, null, leading);
		}
		
		/**
		* Make a direct copy of this style, including all changed parameters.
		* @return	A clone of this style.
		*/
		public function clone():Style
		{
			return new Style(this);
		}
		
		public function get propertyList():Object
		{
			return (this as Object).constructor["__razor_defaults__"];
		}
		
		private var __razor_changed__:Object;
		
		/** @private */ razor_internal function get changedList():Object
		{
			if (__razor_changed__ == null)
				__razor_changed__ = new Object();
			return __razor_changed__;
		}
		
		override public function toString():String
		{
			var p:Object = propertyList;
			var str:String = "Style {\n";
			for (var z:* in p)
			{
				str += "\t"+z+": "+this[z]+"\n";
			}
			return str+"}";
		}
	}
	
}

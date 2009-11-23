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
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import razor.core.razor_internal;
	
	/**
	 * Base class for a StyleSheet definition. Each StyleSheet represents a rule for a component element.
	 * You can nest StyleSheets to create a chain of selectors ([Button -> Label] for example).
	 * You can extend this class with your own style rules, or create rules dynamically by passing
	 * properties into the constructor.
	 * StyleSheet subclasses can have 3 special static properties:
	 * <p>baseClass:Class = the class that will be instantiated when a control is created from this particular rule</p>
	 * <p>style:Object = Styles that will be applied from this particular rule.</p>
	 * <p>states:Object = An object containing StyleSheets for different states (Up, Over, Down, etc.),
	 * referenced by name.</p>
	 * @see razor.skins.RootStyleSheet
	 * @see razor.skins.plastic.PlasticStyleSheet
	 */
	public class StyleSheet
	{
		use namespace razor_internal;
		
		/** @private */ protected var attachments:Array;
		public static var style:Object = { };
		
		/** @private */ protected var dynamicStyles:Object;
		/** @private */ protected var dynamicBaseClass:Class;
		/** @private */ protected var dynamicStates:Object;
		/** @private */ protected var dynamicSubStyles:Object;
		/** @private */ protected var alsoInheritsFrom:Dictionary;
		
		public var takesPriority:Boolean = false;
		
		/**
		 * Constructor.
		 */
		public function StyleSheet(customStyles:Object = null, customBaseClass:Class = null, customStates:Object = null)
		{
			dynamicStyles = customStyles;
			dynamicBaseClass = customBaseClass;
			dynamicStates = customStates;
			
			if (dynamicStyles || dynamicBaseClass || dynamicStates)
				takesPriority = true;
		}
		
		/**
		 * Append a StyleSheet on to this StyleSheet.
		 * Rules in the appended StyleSheet will override rules in this. 
		 * @param styleSheet	A StyleSheet instance (or subclass) to append.
		 */		
		public function appendStyleSheet(styleSheet:StyleSheet):void
		{
			if (attachments == null)
				attachments = new Array();
			
			attachments.push(styleSheet);
		}
		
		/**
		 * Dynamically add a rule to this StyleSheet
		 */
		public function addRule(name:String, styleSheet:StyleSheet):void
		{
			if (dynamicSubStyles == null)
				dynamicSubStyles = new Object;
				
			var i:int = name.indexOf(" ");
			
			if (i >= 0)
			{
				var more:String = name.substr(i+1);
				name = name.substring(0,i);
				
				if (dynamicSubStyles[name] != null)
				{
					StyleSheet(dynamicSubStyles[name]).addRule(more, styleSheet);
					return;
				}
				else
				{
					var newss:StyleSheet = new StyleSheet();
					dynamicSubStyles[name] = newss;
					newss.addRule(more, styleSheet);
					return;
				}
			}
			
			if (name == "" || name == "*")
			{
				if (dynamicStyles != null)
				{
					var sstyles:Object = styleSheet.getStyle();
					for (var z:String in sstyles)
						dynamicStyles[z] = sstyles[z];
				}
				else
					dynamicStyles = styleSheet.getStyle();
					
				var bc:Class = styleSheet.getBaseClass();
				if (bc != null)
					dynamicBaseClass = bc;
				takesPriority = true;
			}
			else
			if (dynamicSubStyles[name] != null)
			{
				dynamicSubStyles[name].addRule("", styleSheet);
			}
			else
				dynamicSubStyles[name] = styleSheet;
		}
		
		/**
		 * Get the Styles associated with this StyleSheet.
		 * @return An Object containing style parameters, or null.
		 */
		public function getStyle():Object
		{
			var s:Object;
			var o:Object = this as Object;
			var c:Class = o.constructor;
			
			if (dynamicStyles != null)
				s = dynamicStyles;
			else 
				s = o.constructor.style;
			
			if (s != null)
			{
				var zz:* = null;
				if (alsoInheritsFrom != null)
				{
					for (var inherits:* in alsoInheritsFrom)
					{
						zz = inherits;
					}
				}
				
				if (zz != null)
				{
					//trace("Re-finding base: "+zz);
					var composite:Object = new Object();
					var last:Object = s;
					
					if (zz is Class)
						o = StyleSheet(new zz()).getStyle();
					else if (zz is StyleSheet)
						o = StyleSheet(zz).getStyle();
					else
						o = new Object();
					
					if (o != null)
						for (var z:String in o)
							composite[z] = o[z];
					for (var y:String in last)
						composite[y] = last[y];
					s = composite;
				}
				
				
			}
			
			return s;
		}
		
		/**
		 * Get the base class associated with this StyleSheet.
		 * @return A Class prototype.
		 */
		public function getBaseClass():Class
		{
			var c:Class;
			var o:* = this as Object;
			if (dynamicBaseClass != null)
				c = dynamicBaseClass;
			else 
				c = Class(o.constructor).baseClass
			
			return c;
		}
		
		/**
		 * Get the StyleSheet associated with a particular state name
		 * @param stateName	The name of the state, (ie. Over)
		 * @return A StyleSheet instance.
		 */
		public function getState(stateName:String):StyleSheet
		{
			var s:Object;
			var o:Object = this as Object;
			if (dynamicStates != null)
				s = dynamicStates;
			else
				s = Class(o.constructor).states;
			
			return s != null ? s[stateName] : null;
		}
		
		/** @private */
		protected function getStyleSheet(name:String, customSheets:Array = null, single:Boolean = false):Array
		{
			// Get style from this stylesheet.
			// But first run backwards through attachments since they will override this one.
			
			if ((name == null || name.length == 0) && customSheets == null)
				return [this];
				
			var picked:StyleSheet;
			var a:Array = new Array();
			
			if (customSheets != null)
			{
				var j:int = customSheets.length;
				while (--j >= 0 && !picked)
				{
					var csa:Array = customSheets[j].getStyleSheet(name, null, true);
					if (csa != null)
						if (single)
							picked = csa[0];
						else 
							a.push(csa[0]);
				}
			}
			
			if (attachments != null && picked == null)
			{
				var i:int = attachments.length;
				while (--i >= 0 && !picked)
				{
					var sa:Array = attachments[i].getStyleSheet(name, null, true);
					if (sa != null)
						if (single)
							picked = sa[0];
						else
							a.push(sa[0]);
				}
			}
			
			if (picked != null)
				return [picked];
			
			if (dynamicSubStyles && dynamicSubStyles[name] != null)
				if (single)
					return [dynamicSubStyles[name]];
				else
					a.push(dynamicSubStyles[name]);
			
			var o:Object = Object(this);
			
			if (o.hasOwnProperty(name))
				if (single)
				return [o[name]];
				else
				a.push(o[name]);
				
			if (a.length > 0) return a;
			
			return null;
		}
		
		/**
		 * Find a style corresponding to a chain of elements.
		 * This allows us to define 'All buttons inside a Scrollbar should be skinned like..',
		 * for example.
		 */
		private function findStyleSheetForChain(chain:Array, sheet:StyleSheet, customSheets:Array = null):StyleSheet
		{
			var c:Array = chain.concat();
			var s:String = (c && c.length > 0) ? String(c.shift()) : null;
			//var sh:StyleSheet = sheet.getStyleSheet(s, customSheets);
			var sa:Array = sheet.getStyleSheet(s, customSheets);
			// getStyleSheet returns array of matching sheets, reverse order
			// go through each sheet and return the first one that contains
			// the whole chain.
			if (sa)
			for (var m:int = 0; m < sa.length; m++)
			{
				var sh:StyleSheet = sa[m];
				if (sh)
				{
					if (c.length == 0)
					{
						if (this != sh)
							sh.addInheritedStyleSheet(this);
						
						return sh;
					}
						
					var o:StyleSheet = findStyleSheetForChain(c,sh);
					// match here:
					if (o) return o;
				}
			}
			
			// If we're looking for a state and havent found it at this stage,
			// trim off the state and look for the non-state version
			// ie. Background$Up becomes Background
			var la:int = s ? s.lastIndexOf("$") : -1;
			if (la >= 0)
			{
				var stateName:String = s.substr(la + 1);
				var st:StyleSheet = sheet.getState(stateName);
				
				if (st)
				{
					st.addInheritedStyleSheet(sheet);
					return st;
				}
				
				s = s.substring(0, la);
				
				var ss:StyleSheet = findStyleSheetForChain(c.concat(s), sheet, customSheets);
				if (ss)
					st = ss.getState(stateName);
				if (st)
				{
					st.addInheritedStyleSheet(ss);
					return st;
				}
				
				return ss;
			}
			
			return null;
		}
		
		/**
		 * @deprecated
		 * @private
		 */
		public function findStyle(chain:Array, customSheets:Array = null):StyleSheet
		{
			//trace("Finding style for: " + chain.toString());
			
			// Start with a chain of components [ScrollBar,Button,Arrow]
			// This represents the nested component we're looking for (Arrow in a Button in a ScrollBar)
			var c:Array = chain.concat();
			
			// Start with ScrollBar and look for a matching chain..
			// if we dont find one, shift the array down and start with Button
			var o:StyleSheet = findStyleSheetForChain(c, this, customSheets);
			
			while (c.length > 1 && o == null)
			{
				c.shift();
				o = findStyleSheetForChain(c, this, customSheets);
			}
			
			//trace("findstyle got: " + o);
			
			if (o == null)
			{
				// StyleSheet didnt contain the definition
				return null;
			}
			
			return o;
		}
		
		/**
		 * Find and combine all Styles for a chain of selectors.
		 * This method also queries all appended StyleSheets. 
		 * @param chain	An array of selectors
		 * @param customSheets	Any custom StyleSheets that should also be included
		 * @param classSelector	A style class selector to use if applicable.
		 * @return An object consisting of the properties "style" and "baseClass".
		 */		
		public function findCombinedStyle(chain:Array, customSheets:Array = null, classSelector:String = null, oneWay:Boolean = false):Object
		{
			//trace("Finding combined style for: " + chain.toString());
			
			// Start with a chain of components [ScrollBar,Button,Arrow]
			// This represents the nested component we're looking for (Arrow in a Button in a ScrollBar)
			var c:Array = chain.concat();
			var c2:Array;
			if (classSelector && classSelector.length > 0)
			{
				//c2 = c.concat();
				//c2.pop();
				//c2.push(classSelector);
				
				if (c.length > 1)
				{
					c2 = c.concat();
					var lastItem:* = c2.pop();
					c2.pop();
					c2.push(classSelector);
					c2.push(lastItem);
				}
				else
				{
					c2 = [classSelector];
				}
				
			}
			
			var o:StyleSheet;
			var base:Class;
			var combined:Object = new Object();
			var found:Boolean = false;
			var done:Boolean = false;
			var s:Object;
			var b:Class;
			var p:Boolean;
			
			/*
			if (c[c.length-1].indexOf("$") >= 0)
			{
				var c3:Array = c.concat();
				var lastItem:String = c3.pop();
				c3.push(lastItem.substr(0, lastItem.indexOf("$")));
				var o3:Object = findCombinedStyle(c3, customSheets, classSelector, oneWay);
				if (o3.style != null)
					combined = o3.style;
				if (o3.baseClass != null)
					base = o3.baseClass;
			}
			*/
			
			while (!done)
			{
				//trace("..."+c);
				o = findStyleSheetForChain(c, this, customSheets);
				
				if (o != null)
				{
					
					found = true;
					
					s = o.getStyle();
					b = o.getBaseClass();
					//trace("\tcombining: " + o + "   "+o.takesPriority+"  base: "+b);
					p = o.takesPriority;
					if ((base == null || p) && b != null)
						base = b;
						
					if (s)
					{
						for (var i:String in s)
						{
							if (combined[i] == null || p)
							{
								//trace("\t\t"+i+" "+s[i]);
								combined[i] = s[i];
							}
						}
					}
				}
				
				if (c.length == 0)
					done = true;
				else
					c.shift();
				
			}
			
			// testing:
			done = oneWay;
			c = chain.concat();
			c.pop();
			if (c.length == 0) done = true;
			while (!done)
			{
				//trace("..."+c);
				o = findStyleSheetForChain(c, this, customSheets);
				
				if (o != null)
				{
					
					found = true;
					
					s = o.getStyle();
					b = o.getBaseClass();
					//trace("\tcombining: " + o);
					p = o.takesPriority;
					if ((base == null || p) && b != null)
						base = b;
						
					if (s)
					{
						for (var j:String in s)
						{
							if (combined[j] == null || p)
							{
								//trace("\t\t"+j +"   "+s[j]);
								combined[j] = s[j];
							}
						}
					}
				}
				
				if (c.length <= 1)
					done = true;
				else
					c.pop();
			}
			// end testing..
			
			if (c2)
			{
				var ob:Object = findCombinedStyle(c2, null, null, true);
				if (ob && ob.baseClass)
					base = ob.baseClass;
				if (ob && ob.style)
				{
					s = ob.style;
					for (var k:String in s)
					{
						//trace("\t\t\t"+k +"   "+s[k]);
						combined[k] = s[k];
					}
				}
			}
			
			if (!found)
				return null;
			
			//trace(base);
			return {style: combined, baseClass: base};
		}
		
		/** @private */
		razor_internal function addInheritedStyleSheet(ss:StyleSheet):void
		{
			if (alsoInheritsFrom == null)
				alsoInheritsFrom = new Dictionary(true);
				
			alsoInheritsFrom[ss] = true;
		}
		
		public function toString():String
		{
			return "["+getQualifiedClassName(this)+"]";
		}
	}
}
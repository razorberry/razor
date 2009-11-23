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

package razor.core 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import razor.skins.Settings;
	import razor.skins.Style;
	import razor.skins.StyleSheet;
	
	/**
	 * Dispatched when the state of this container changes.
	 * @eventType razor.core.StyledContainer.E_STATE_CHANGE
	 */
	[Event(name="stateChange", type="flash.events.Event")]
	
	//
	// Style metadata
	//
	
	[Style(name="fontFace", type="String", inherit="yes")]
	[Style(name="fontSize", type="uint", format="Points", inherit="yes")]
	[Style(name="fontColor", type="uint", format="Color", inherit="yes")]
	[Style(name="align", type="String", enumeration="left,center,right,justify", inherit="yes")]
	[Style(name="bold", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="italic", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="underline", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="leading", type="Number", format="Points", inherit="yes")]
	[Style(name="embedFonts", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="sharpText", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="baseColor", type="uint", format="Color", inherit="yes")]
	[Style(name="border", type="uint", format="Color", inherit="yes")]
	// borderThickness can be an Array [ t, b, l, r ];
	[Style(name="borderThickness", type="*", inherit="no")]
	// bevel can be an array [ t, b, l, r ];
	[Style(name="bevel", type="*", inherit="yes")]
	// Roundedness can be a Number or an Array: [tl, tr, bl, br]
	[Style(name="roundedness", type="*", inherit="yes")]
	[Style(name="variance", type="Number", inherit="yes")]
	[Style(name="glossiness", type="Number", inherit="yes")]
	[Style(name="azimuth", type="Number", format="Degrees", inherit="yes")]
	[Style(name="shadow", type="Number", format="Points", inherit="yes")]
	[Style(name="inset", type="Boolean", enumeration="true,false", inherit="yes")]
	[Style(name="opacity", type="Number", inherit="yes")]
	[Style(name="modifyBrightness", type="Number", inherit="yes")]
	[Style(name="fade", type="Number", inherit="yes")]
	[Style(name="margin_l", type="Number", inherit="yes")]
	[Style(name="margin_r", type="Number", inherit="yes")]
	[Style(name="margin_t", type="Number", inherit="yes")]
	[Style(name="margin_b", type="Number", inherit="yes")]
	[Style(name="padding_l", type="Number", inherit="yes")]
	[Style(name="padding_r", type="Number", inherit="yes")]
	[Style(name="padding_t", type="Number", inherit="yes")]
	[Style(name="padding_b", type="Number", inherit="yes")]
	
	//
	//
	//
	
	/**
	* Base container with Styles support. Use this class for any components you want skinned, or if you want to
	* cascade styles down to subcomponents.
	* If you don't need skinning support, then use Container.
	* @see razor.core.Container
	*/
	public class StyledContainer extends Container
	{
		use namespace razor_internal;
		
		public static const E_STATE_CHANGE:String = "stateChange";
		
		/** @private */ protected function getClass():String { return "StyledContainer"; }
		
		/** @private */ protected var __style:Style;
		/** @private */ razor_internal var __skinElement:String;
		/** @private */ razor_internal var __modifiers:Array;
		/** @private */ razor_internal var __controlFactory:ControlFactory;
		/** @private */ private var __elements:Array;
		/** @private */ razor_internal var __styleChain:Array;
		/** @private */ private var __states:Object;
		/** @private */ private var __depths:Array;
		/** @private */ protected var __currentState:String;
		/** @private */ private var __customSheets:Array;
		/** @private */ razor_internal var __initialParent:DisplayObjectContainer;
		/** @private */ razor_internal static var preInitialize:Object;
		/** @private */ razor_internal var __styleClass:String;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/Set the style class for this component.
		 * The component will pick up the appropriate rule from the stylesheets.
		 */
		public function set styleClass(str:String):void
		{
			__styleClass = str;
			__style = Settings.style;
			cleanUp();
			constructObject();
		}
		
		public function get styleClass():String
		{
			return __styleClass;
		}
		
		/**
		* Overwrite the current style on this component instance with a new one.
		* @param	s	The style to use.
		*/
		public function set style(s:Style):void
		{
			// Stop listening to any previous style, and listen to the new one instead
			if (__style)
				__style.removeEventListener(Event.CHANGE, onStyleChange, false);
			__style = s;
			if (__style)
				__style.addEventListener(Event.CHANGE, onStyleChange, false, 0, true);
			onStyleChange();
		}
		
		/** @private */
		public function get style():Style
		{
			return __style;
		}
		
		/**
		* Merge a Style or object containing style parameters into this instance of the component.
		* 
		* @example
		* <listing version="3.0">
		* var myStyle:Style = new Style();
		* myStyle.baseColor = 0xFF3300;
		* var myButton:Button = addChild(new Button());
		* myButton.mergeStyle(myStyle);
		* 
		* // Or simply:
		* 
		* myButton.mergeStyle({baseColor: 0xFF3300});
		* }
		* </listing>
		* @param	s	The Style or Object to merge.
		* @return	The resulting style.
		*/
		public function mergeStyle(s:*):Style
		{
			return internalAddStyle(s);
		}
		
		public function setStyle(styleName:String, style:*):void
		{
			var o:Object = new Object();
			o[styleName] = style;
			internalAddStyle(o);
			onStyleChange(new RazorEvent(Style.E_CHANGE));
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/**
		* Constructor.
		* Gets and applies the default Style for this component.
		*/
		public function StyledContainer()
		{
			super(true);
			
			// Get our ControlFactory.
			__controlFactory = (preInitialize && preInitialize.controlFactory) ? preInitialize.controlFactory : Settings.defaultFactory;
			
			var s:Style = __controlFactory.defaultStyle;
			
			var superStyle:Style;
			var delayThis:Boolean = false;
			var forceConstruct:Boolean = false;
			
			//
			// Generate the stylechain from the chain of parent displayobjects.
			if (preInitialize && preInitialize.parent)
				__initialParent = preInitialize.parent;
			
			if (__styleChain == null)
			__styleChain = new Array();
			var p:DisplayObjectContainer = parent ? parent : __initialParent;
			
			while (p is StyledContainer)
			{
				var pp:StyledContainer = p as StyledContainer;
				__styleChain.unshift(pp.__skinElement ? pp.__skinElement : (pp.getClass != null ? pp.getClass() : getQualifiedClassName(pp).split("::")[1]));
				p = pp.parent ? pp.parent : pp.__initialParent;
			}
			__styleChain.push(__skinElement ? __skinElement : (getClass != null ? getClass() : getQualifiedClassName(this).split("::")[1]));
			//
			//
			
			// If this control was created directly instead of with the ControlFactory
			// then get the styles from the root stylesheet and apply them now.
			if (preInitialize == null)
			{
				style = s;
				__controlFactory.styleControl(this);
				forceConstruct = true;
			}
			
			// If this control was created by a ControlFactory, it has already prepared
			// styles from the stylesheet.
			if (preInitialize)
			{
				if (preInitialize.parent)
					__initialParent = preInitialize.parent;
					
				delayThis = preInitialize.constructionPending;
				
				if (preInitialize.style)
				{
					delayThis = true;
					superStyle = preInitialize.style;
				}
			}
			
			preInitialize = null;
			
			// Integrate any initial style
			if (s != null)
			{
				if (superStyle)
					s.integrate(superStyle);
				if (style == null)
					style = s;
			}
			else if (style == null)
				style = new Style(superStyle != null ? superStyle : null);
			
			__states = new Object();
			
			// If this control was created by a ControlFactory.. it needs to do additional
			// work before we build our children.
			if (!delayThis || forceConstruct)
				constructObject();
		}
		
		/**
		* Add a child component to this container.
		* <p>Internal method for adding a razor component to this container.
		* If the new component is a StyledContainer, this method ensures that the component
		* is initialized in the correct order.</p>
		* @example In order to use this method, you need to import and use the razor_internal namespace.
		* <listing version="3.0">
		* import razor.core.razor_internal;  // Import the namespace
		* ...
		* use namespace razor_internal;  // Use the namespace.. this can be placed on the class level or inside your method.
		* myLabel = addBlueprint(Label) as Label;  // Create the label and cast the result.
		* </listing>
		* @param	tagOrClass	The skin ID or class of the component to add.
		* @param	initObj	(optional)	Any initial parameters can be pushed in to the component here.
		* @param	depth	(optional) The depth at which to add the component
		* @return	The new component.
		*/
		razor_internal function addBlueprint(tagOrClass:*, initializers:Object = null, depth:Number = NaN):DisplayObject
		{
			var c:Container;
			var u:DisplayObject;
			
			if (tagOrClass is Class)
			{
				u = __controlFactory.create(tagOrClass, null, this, initializers, __customSheets);
			}
			else
			{
				u = __controlFactory.createFromRule(__styleChain.concat(tagOrClass), this, initializers, __customSheets);
			}
			
			c = u as Container;
			
			if (c)
			{
				registerChild(c);
			
				// Check if component initialized immediately.. if not, we need to wait for it.
				if (c.__initialized == false)
				{
					waitForInit(c);
				}
				
				
			}
			
			if (u)
				super.addChild(u);
			
			return u;
		}
		
		/**
		 * Add a child at a particular depth index. 
		 * @param c	The DisplayObject to add
		 * @param depth	The depth index to place the child
		 * @private
		 */
		razor_internal function addAtDepth(c:DisplayObject, depth:int):void
		{
			if (c)
			{
				addChild(c);
				
				if (!__depths)
					__depths = new Array();
				__depths.push({c: c, d: depth});
				sortDepths();
			}
		}
		
		/**
		* Internal method to register a reference to a child.
		* @private
		* @param	c	The child container
		*/
		protected function registerChild(c:Container):void
		{
			if (c == null) return;
			if (__elements == null) __elements = new Array();
			__elements.push(c);
		}
		
		/**
		* Internal method to unregister a child from this container.
		* @private
		* @param	c
		*/
		protected function unregisterChild(c:Container):void
		{
			for (var z:int = __elements.length; z >= 0; z--)
			{
				if (__elements[z] == c)
					__elements.splice(z,1);
			}
		}
		
		/**
		 * Sort all children with depths in the display list 
		 * @private
		 */
		razor_internal function sortDepths():void
		{
			__depths.sortOn("d", Array.NUMERIC);
			var l:int = __elements.length - __depths.length;
			for (var j:int = 0; j < __depths.length; j++)
					if (contains(__depths[j].c))
						setChildIndex(__depths[j].c, l+j);
		}
		
		/**
		 * Remove all children of this container. 
		 * @private
		 */
		private function cleanUp():void
		{
			var e:Array = __elements.concat();
			for (var i:int = 0; i < e.length; i++)
			{
				var z:Container = e[i];
				
				unregisterChild(z);
				if (z is Container)
					Container(z).destroy();
				else
				{
					if (contains(z)) removeChild(z);
				}
			}
			__states = new Object();
			__depths = new Array();
			__elements = new Array();
		}
		
		/**
		 * Attach a StyleSheet to this component instance.
		 * The StyleSheet will override any styles attached to the root StyleSheet.
		 * This method is potentially expensive, since it recreates the control.
		 * @param sheet	A StyleSheet instance
		 * 
		 */
		public function attachStyleSheet(sheet:StyleSheet):void
		{
			if (__customSheets == null)
				__customSheets = new Array();
			
			var i:int = __customSheets.length;
			while (--i >= 0)
				if (__customSheets[i] == sheet)
					return;
			
			sheet.takesPriority = true;
			__customSheets.push(sheet);
			cleanUp();
			constructObject();
		}
		
		/**
		* Add states for a particular child component of this container. <p>This allows you to
		* automatically switch between states (for example, up/over/down states in a button)
		* For an example, see the Button component.</p>
		* <p>You normally define states in the StyleSheets, and the corresponding component is
		* created when the state is set (with setState())</p>
		* @example
		* <listing version="3.0">
		* myIcon = addStates("MyStatefulIcon", 1, ["Selected", "Unselected"]); // Define the states
		* setState("Unselected");  // This will create MyStatefulIcon$Unselected in the Skin definition
		* var myIcon:Container = getStateElement("MyStatefulIcon"); // Gets the current icon
		* myIcon.move(2,2);
		* </listing>
		* @see #getStateElement
		* @see #setState
		* @param	tag		The skin ID of the container
		* @param	depth	The depth at which to create the container
		* @param	states	An array of state identifiers (strings).
		* @return	The current element for the state that was passed.
		*/
		protected function addStates(tag:String, depth:int, states:Array):DisplayObject
		{
			var a:Object = __states[tag];
			if (a == null)
				a = __states[tag] = new Object();
			
			a.depth = depth;
			var setstate:Boolean = false;
			if (a.states == null)
			{
				a.states = new Array();
				setstate = true;
			}
			a.states = a.states.concat(states);
			a.elements = new Object();
			if (setstate) setState(__currentState);
			return __states[tag].current;
		}
		
		/**
		* Get the component for a skin ID in its current state.
		* <p>You would only use this if you have added components using addStates.
		* For example, if you have added a button in three states, and the current state is
		* the first state. Then this method would return the button in the first state. See the
		* Button control for a more detailed example.</p>
		* @param	tag		The skin ID of the component to retrieve
		* @return	The current component for the state.
		*/
		protected function getStateElement(tag:String):DisplayObject
		{
			if (__states != null && __states[tag] != null)
				return __states[tag].current;
			else
				return null;
		}
		
		/**
		* Set the current state.
		* <p>If you have added components with states, the desired component will be created
		* for the state in question</p>
		* @param	state	The state to switch to.
		*/
		protected function setState(state:String):void
		{
			var oldState:String = __currentState;
			__currentState = state;
			for (var z:String in __states)
			{
				var a:Object = __states[z];
				
				if (a.current)
					if (contains(a.current))
					{
						removeChild(a.current);
					}
						
				
				var clip:DisplayObject = a.elements[state];
				
				if (clip == null)
				{
					clip = addBlueprint(z+"$"+state);
					a.elements[state] = clip;
				}
				else
				{
					super.addChild(clip);
				}
				
				a.current = clip;
				
			}
			// organize current states by depth
			var arr:Array = new Array();
			for each (var i:Object in __states)
				if (i.current)
					arr.push({clip: i.current, depth: i.depth});
			for each (var k:Object in __depths)
				arr.push({clip: k.c, depth: k.d});
			arr.sortOn("depth",Array.NUMERIC);
			for (var j:int = 0; j < arr.length; j++)
				if (contains(arr[j].clip))
					setChildIndex(arr[j].clip, j);
					
			if (oldState != __currentState)
				dispatchEvent(new Event(E_STATE_CHANGE));
		}
		
		/**
		* Internal method to merge a style or object containing style parameters into this component
		* and all children.
		* @private
		* @param	s	The Style or Object to merge
		* @return	The resulting style.
		*/
		razor_internal function internalAddStyle(s:*):Style
		{
			for each (var z:* in __elements)
				if (z is StyledContainer)
					z.internalAddStyle(s);
			
			var changed:Boolean = __style ? __style.integrate(s, false, true) : false;
			/*
			var modifiers:Array = remodify();
			
			// Modify the children too
			for each (var zz:* in __elements)
				if (zz is StyledContainer && zz.style != __style)
				{
					for (var i:int = 0; i < modifiers.length; i++)
						if (!(modifiers[i] is Function))
							zz.internalAddStyle(modifiers[i]);
				}
					*/
			if (changed) 
			doLayout();
				
			return __style;
		}
		
		/**
		* Re-apply any style modifiers to a component.
		* @param	container	The component to remodify
		* @return	The list of modifiers that were applied.
		* @private
		*/
		protected function remodify():Array
		{
			var modifiers:Array = __modifiers;
			
			if (modifiers == null)
				return new Array();
				
			var s:Style = __style;
			for (var i:int = 0; i < modifiers.length; i++)
			{
				if (modifiers[i] is Function)
					modifiers[i].call(this,s);
				else
				{
					s.integrate(modifiers[i], true);
				}
			}
			
			return modifiers;
		}
		
		/**
		* Called whenever a Style notifies us of a change.
		* @private
		* @param	evOb	The style event
		*/
		protected function onStyleChange(evOb:RazorEvent = null):void
		{
			if (__initialized)
			{
				// Do stuff
			}
		}
	}
	
}

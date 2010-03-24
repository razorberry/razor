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
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	import razor.skins.NullContainer;
	import razor.skins.Settings;
	import razor.skins.Style;
	import razor.skins.StyleSheet;
	import razor.skins.plastic.presets.Default;
	
	
	/**
	 * Class to create Razor components using a particular StyleSheet.
	 * You can use either the defaultFactory, or create multiple factories with multiple root StyleSheet instances.
	 * @example
	 * <listing version="3.0">
	 * import razor.controls.Button;
	 * import razor.core.ControlFactory;
	 * 
	 * var myButton:Button = ControlFactory.create(Button) as Button;
	 * 
	 * // Assign a style class:
	 * var myStyledButton:Button = ControlFactory.create(Button, "myButtonStyle") as Button;
	 * 
	 * // (Advanced) Create and use a new factory:
	 * var myFactory:ControlFactory = new ControlFactory();
	 * myFactory.rootStyleSheet = myRootStyleSheet;
	 * var button:Button = myFactory.create(Button) as Button;
	 * </listing>
	 */
	public class ControlFactory
	{
		use namespace razor_internal;
		
		/** @private */ protected var _rootStyleSheet:StyleSheet;
		/** @private */ protected var _defaultStyle:Style = new Default();
		/** @private */ protected var _defaultStyleConstructor:Class = Default;
		
		/**
		 * Constructor. 
		 * 
		 */
		public function ControlFactory()
		{
		}
		
		/**
		 * Create a new instance of a control. 
		 * @param control	The control class.
		 * @param styleClass	(Optional) The style class of the new control
		 * @param styleParent	(Optional) The parent that the new control will inherit styles from
		 * @param initializers	(Optional) An object of initial parameters that will be set on the control
		 * @param supplementalSheets	(Optional) Also attach this array of StyleSheets to the new control
		 * @return The newly created control, typed as a Container.
		 * 
		 */		
		public static function create(control:Class, styleClass:String = null, styleParent:StyledContainer = null, initializers:Object = null, supplementalSheets:Array = null):DisplayObject
		{
			return defaultFactory.create(control, styleClass, styleParent, initializers, supplementalSheets);
		}
		
		
		/**
		 * Create a new instance of a control, following an array of style selectors. 
		 * @param selectors		An array of style selectors. This array will be followed when consulting the StyleSheet(s).
		 * @param styleParent	(Optional) The parent that the new control will inherit styles from
		 * @param initializers	(Optional) An object of initial parameters that will be set on the control
		 * @param supplementalSheets	(Optional) Also attach this array of StyleSheets to the new control
		 * @return The newly created control, typed as a Container.
		 * 
		 */
		public static function createFromRule(selectors:Array, styleParent:StyledContainer = null, initializers:Object = null, supplementalSheets:Array = null):DisplayObject
		{
			return defaultFactory.createFromRule(selectors, styleParent, initializers, supplementalSheets);
		}
		
		
		/**
		 * Return the default ControlFactory instance. 
		 * @return The default ControlFactory instance.
		 * 
		 */
		public static function get defaultFactory():ControlFactory
		{
			return Settings.defaultFactory;
		}
		
		
		/**
		 * Set/Get the rootStyleSheet associated with this ControlFactory.
		 * If not set, this will default to the global root StyleSheet (Settings.rootStyleSheet) 
		 * @param styleSheet	A StyleSheet instance
		 * 
		 */
		public function set rootStyleSheet(styleSheet:StyleSheet):void
		{
			_rootStyleSheet = styleSheet; 
		}
		
		/** @private */
		public function get rootStyleSheet():StyleSheet
		{
			return (_rootStyleSheet != null ? _rootStyleSheet : Settings.rootStyleSheet);
		}
		
		/**
		 * Set/Get the default style associated with this ControlFactory.
		 * If not set, this will default to the global default Style (Settings.style)
		 * @param style		A Style instance
		 */
		public function set defaultStyle(style:Style):void
		{
			_defaultStyle = style;
			_defaultStyleConstructor = Object(style).constructor;
		}
		
		/** @private */
		public function get defaultStyle():Style
		{
			if (_defaultStyle == null)
				return Settings.style;
				
			var newStyle:Style = (new _defaultStyleConstructor() as Style);
			newStyle.integrate(_defaultStyle);
			return newStyle;
		}
		
		/**
		 * Create a new instance of a control. 
		 * @param control	The control class.
		 * @param styleClass	(Optional) The style class of the new control
		 * @param styleParent	(Optional) The parent that the new control will inherit styles from
		 * @param initializers	(Optional) An object of initial parameters that will be set on the control
		 * @param supplementalSheets	(Optional) Also attach this array of StyleSheets to the new control
		 * @return The newly created control, typed as a Container.
		 * 
		 */		
		public function create(control:Class, styleClass:String = null, styleParent:StyledContainer = null, initializers:Object = null, supplementalSheets:Array = null):DisplayObject
		{
			return doCreate(null,control,styleClass,styleParent,initializers,supplementalSheets);
		}
		
		razor_internal function styleControl(control:StyledContainer):Container
		{
			return doCreate(control) as Container;
		}
		
		private function doCreate(instance:StyledContainer = null, control:Class = null, styleClass:String = null, styleParent:StyledContainer = null, initializers:Object = null, supplementalSheets:Array = null):DisplayObject
		{
			var u:DisplayObject;
			
			if (instance != null)
			{
				u = instance;
				control = Object(instance).constructor;
			}
				
			var className:String = flash.utils.getQualifiedClassName(control).split("::")[1];
			var styleSheet:StyleSheet = rootStyleSheet;
			var blueprint:Object;
			
			if (styleSheet)
			{
				var ss:Object = styleSheet.findCombinedStyle([className], supplementalSheets, styleClass != null ? styleClass : (styleParent ? styleParent.styleClass : null));
				
				if (ss)
				blueprint = ss.style;
			}
			
			var modifiers:Array = new Array();
			
			if (blueprint != null)
			{
				var copy:Object = new Object();
				for (var z:String in blueprint)
					copy[z] = blueprint[z];
				
				modifiers.push(copy);		
			}
			
			// next line is temporary.. its probably too expensive.
			//if(((describeType(control)..extendsClass.(@type=="StyledContainer")).length > 0))
			preConstruct(styleParent, initializers);
			
			if (instance == null) 
				u = new control();
			
			// apply modifiers
			if (u is StyledContainer)
			{
				var c:StyledContainer = u as StyledContainer;
				c.__modifiers = modifiers;
				c.__skinElement = className;
				if (styleClass)
				{
					c.__styleClass = styleClass;
					c.__skinElement = styleClass;
				}
				
				if (modifiers.length > 0)
				{
					var s:Style = c.style;
					
					if (s)
					{
						for (var j:int = 0; j < modifiers.length; j++)
						{
							if (modifiers[j] is Function)
								modifiers[j].call(c,s);
							else
								s.integrate(modifiers[j], true);
						}
					}
				}
			}
			
			if (instance == null)
			postConstruct(u, initializers);
			
			if (u is Bitmap)
			{
				var co:Container = new Container();
				co.addChild(u);
				return co;
			}
			return u;
		}
		
		/**
		 * Create a new instance of a control, following an array of style selectors. 
		 * @param selectors		An array of style selectors. This array will be followed when consulting the StyleSheet(s).
		 * @param styleParent	(Optional) The parent that the new control will inherit styles from
		 * @param initializers	(Optional) An object of initial parameters that will be set on the control
		 * @param supplementalSheets	(Optional) Also attach this array of StyleSheets to the new control
		 * @return The newly created control, typed as a Container.
		 * 
		 */
		public function createFromRule(selectors:Array, styleParent:StyledContainer = null, initializers:Object = null, supplementalSheets:Array = null):DisplayObject
		{
			// Find baseclass and combined style.
			var styleSheet:StyleSheet = rootStyleSheet;
			var className:String = selectors[selectors.length - 1];
			var blueprint:Object;
			var control:Class;
			
			if (styleSheet)
			{
				var ss:Object = styleSheet.findCombinedStyle(selectors, supplementalSheets, styleParent ? styleParent.styleClass : null);
				
				if (ss == null)
					return new NullContainer();
				
				//trace("***CreateFromRule: ["+selectors.join(",")+"]");
				for (var sz:String in ss.style)
				//trace(sz+"   "+ss.style[sz]);
				//trace("*******");
				//if (selectors[1] && selectors[1] == "Label$Over")
				//{
				//	trace("<><><><<>");
				//}
				blueprint = ss.style;
				control = ss.baseClass;
				
			}
			
			if (styleSheet == null || control == null)
			{
				return new NullContainer();
			}
			
			// TODO: No need to make a copy here once we clean up.
			var modifiers:Array = new Array();
			var copy:Object = new Object();
			for (var z:String in blueprint)
				copy[z] = blueprint[z];
			
			modifiers.push(copy);		
			
			preConstruct(styleParent, initializers);
			
			var u:DisplayObject;
			
			u = new control();
			
			// apply modifiers
			if (u is StyledContainer)
			{
				var c:StyledContainer = u as StyledContainer;
				c.__modifiers = modifiers;
				c.__skinElement = className;
				
				if (modifiers.length > 0)
				{
					var s:Style = c.style;
					
					if (s)
						for (var j:int = 0; j < modifiers.length; j++)
						{
							if (modifiers[j] is Function)
								modifiers[j].call(c,s);
							else
								s.integrate(modifiers[j], false);
						}
					
				}
			}
			
			
			postConstruct(u, initializers);
			
			return u;
		}
		
		/**
		 * Stuff that happens before a control class is constructed.
		 * @private
		 */
		protected function preConstruct(styleParent:StyledContainer, initializers:Object):void
		{
			var pStyle:Style = styleParent ? styleParent.style : null;
			// Push the parent style onto the new element (unless overridden by an initializer)
			if (initializers == null && pStyle != null) initializers = { style: pStyle };
			else if ( initializers && initializers.style == null && pStyle != null) initializers.style = pStyle;
			
			//if (StyledContainer.preInitialize != null)
			//{
			//	throw new Error("Do not create StyledContainer subclasses inside your constructor. Override the construct() method instead.");
			//}
			var preInit:Object = new Object();
			StyledContainer.preInitialize = preInit;
			preInit.parent = styleParent;
			
			if (initializers)
			{
				preInit.style = initializers.style;
				delete initializers.style;
			}
			preInit.controlFactory = this;
			preInit.constructionPending = true;
		}
		
		/**
		 * Stuff that happens after a control class has been constructed.
		 * @private
		 */
		protected function postConstruct(c:DisplayObject, initializers:Object):void
		{
			if (!(c is StyledContainer))
				StyledContainer.preInitialize = null;
				
			if (initializers)
				for (var zz:String in initializers)
				{
					try
					{
						c[zz] = initializers[zz];
					}
					catch (e:ReferenceError)
					{
						// Ignore cases where the new component doesnt have an initializer property.
					}
				}
			
			if (c is StyledContainer)
				StyledContainer(c).doConstruct();
		}
	}
}
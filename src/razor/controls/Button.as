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

package razor.controls
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import razor.accessibility.ButtonAccImpl;
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.InteractiveContainer;
	import razor.core.Metrics;
	import razor.core.razor_internal;
	import razor.layout.LayoutData;
	import razor.skins.NullContainer;
	import razor.skins.Settings;
	import razor.skins.SkinBitmap;
	import razor.skins.Style;
	
	/**
	 * Dispatched when the button is clicked. (pressed and released).
	 * @eventType razor.controls.Button.E_CLICK
	 */
	[Event(name="e_click", type="flash.events.Event")]
	
	/**
	 * Dispatched when the button is rolled over.
	 * @eventType razor.controls.Button.E_ROLLOVER
	 */
	[Event(name="e_rollOver", type="flash.events.Event")]
	
	/**
	 * Dispatched when the mouse rolls off the button.
	 * @eventType razor.controls.Button.E_ROLLOUT
	 */
	[Event(name="e_rollOut", type="flash.events.Event")]
	
	/**
	 * Dispatched when the mouse presses the button.
	 * @eventType razor.controls.Button.E_PRESS
	 */
	[Event(name="e_press", type="flash.events.Event")]
	
	/**
	 * Dispatched when the mouse releases the button.
	 * @eventType razor.controls.Button.E_RELEASE
	 */
	[Event(name="e_release", type="flash.events.Event")]
	
	/**
	 * Dispatched when the button is pressed, but the mouse is released outside the confines of the button.
	 * @eventType razor.controls.Button.E_RELEASE_OUTSIDE
	 */
	[Event(name="e_releaseOutside", type="flash.events.Event")]
	
	/**
	 * Class for a clickable button component.
	 * @example
	 * <listing version="3.0">
	 * package
	 * {
	 *     import razor.core.ControlFactory;
	 *     import razor.controls.Button;
	 * 
	 *     public class ButtonIconExample extends flash.display.Sprite
	 *     {
	 *         [Embed(source="./images/button_icon.png")]
	 *         var myIcon:Class;
	 *         
	 *         public function ButtonIconExample()
	 *         {
	 *             var myButton:Button = ControlFactory.create(Button) as Button;
	 *             myButton.setSize(200,20);
	 *             myButton.addIcon(myIcon);
	 *             myButton.labelPlacement = Button.LABEL_LEFT;
	 *             myButton.label = "Hello!";
	 *             addChild(myButton);
	 *         }
	 *     }
	 * }
	 * </listing>
	 */
	public class Button extends InteractiveContainer
	{
		use namespace razor_internal;
		
		// Event identifiers
		public static const E_CLICK:String = InteractiveContainer.E_CLICK;
		public static const E_ROLLOVER:String = InteractiveContainer.E_ROLLOVER;
		public static const E_ROLLOUT:String = InteractiveContainer.E_ROLLOUT;
		public static const E_PRESS:String = InteractiveContainer.E_PRESS;
		public static const E_RELEASE:String = InteractiveContainer.E_RELEASE;
		public static const E_RELEASE_OUTSIDE:String = InteractiveContainer.E_RELEASE_OUTSIDE;
		
		// Primary state identifiers. 
		public static const S_UP:String = "Up";
		public static const S_DOWN:String = "Down";
		public static const S_OVER:String = "Over";
		public static const S_DISABLED:String = "Disabled";
		
		// Label placement constants
		public static const LABEL_RIGHT:String = "right";
		public static const LABEL_LEFT:String = "left";
		public static const LABEL_ABOVE:String = "above";
		public static const LABEL_BELOW:String = "below";
		
		/** @private */ override protected function getClass():String { return "Button"; }
		
		private var _icon:*;
		private var _label:String;
		private var _toggle:Boolean = false;
		private var _state:Boolean = false;
		private var _labelPlacement:String = LABEL_RIGHT;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Add or replace the icon on this button.
		 * You can use an external image, or an embedded image, typed as a class, or a StyleSheet selector.
		 * @example
		 * <listing version="3.0">
		 * package
		 * {
		 *     import razor.core.ControlFactory;
		 *     import razor.controls.Button;
		 * 
		 *     public class ButtonIconExample extends flash.display.Sprite
		 *     {
		 *         [Embed(source="./images/button_icon.png")]
		 *         var myIcon:Class;
		 *         
		 *         public function ButtonIconExample()
		 *         {
		 *             var myButton:Button = ControlFactory.create(Button) as Button;
		 *             myButton.setSize(200,20);
		 *             myButton.addIcon("./images/button_icon.png");
		 *             // Or alternatively:
		 *             myButton.addIcon(myIcon);
		 *             addChild(myButton);
		 *         }
		 *     }
		 * }
		 * </listing>
		 * @param	icon	The url, class, or selector of the icon to attach.
		 */
		public function addIcon(i:*):void
		{
			if (_icon)
			{
				if (_icon is Container) Container(_icon).destroy();
				else if (contains(_icon)) removeChild(_icon);
			}
			
			_icon = addBlueprint(i, null, 49);
			
			if (_icon is NullContainer)
			{
				Container(_icon).destroy();
				
				var s:Style = Settings.style;
				s.url = i;
				_icon = addBlueprint(SkinBitmap, { style:s }, 49);
				unregisterChild(_icon); // TODO: why unregister.
			}
			
			if (_icon is Container)
			{
				// If icon is Container, wait for it to be initialized (finished loading) then layout.
				if (_icon.__initialized)
					doLayout();
				else
					_icon.addEventListener(Container.E_INIT, onIconInit, false, 0, true);
			}
		}
		
		/**
		 * Set the current phase of the button. You can use the state identifiers defined by
		 * the static Button.S_* constants.
		 * @param	p	The new phase to display.
		 * @default up
		 */
		public function set phase(p:String):void
		{
			setState(p);
			doLayout();
		}
		
		/** @private */
		public function get phase():String
		{
			return __currentState;
		}
		
		[Inspectable(name="Label", type=String)]
		/**
		* Set the label for the button. The label text will be styled automatically.
		* @param	str		The string to use for the label.
		*/
		public function set label(str:String):void
		{
			_label = str;
			
			if (_label && _label.length > 0 && getStateElement("Label") == null)
			addStates("Label", 50, [S_UP, S_OVER, S_DOWN]);
			
			doLayout();
		}
		
		/** @private */
		public function get label():String
		{
			return _label;
		}
		
		/**
		 * Set whether this button is enabled (clickable)
		 * @param	b	A boolean indicating whether this button is enabled.
		 * @default true
		 */
		override public function set enabled(b:Boolean):void
		{
			__enabled = b;
			if (!b) phase = S_DISABLED;
			else	phase = S_UP;
			useHandCursor = b;
			mouseEnabled = b;
			tabEnabled = b;
		}
		
		/** @private */
		override public function get enabled():Boolean
		{
			return __enabled;
		}
		
		/**
		 * Set whether this button is toggleable (ie. The button will stay in the DOWN state when
		 * clicked, and toggle back to the UP state when clicked again)
		 * @param	b	A boolean indicating whether this button is toggleable.
		 * @default false
		 */
		public function set toggle(b:Boolean):void
		{
			_toggle= b;
			if (!b) phase = S_UP;
		}
		
		/** @private */
		public function get toggle():Boolean
		{
			return _toggle;
		}
		
		/**
		 * Used to select or deselect a (toggleable) button.
		 * @param	b	A boolean indicating whether the button is currently selected.
		 * @default false
		 */
		public function set selected(b:Boolean):void
		{
			_state = b;
			phase = _state ? S_DOWN : S_UP;
		}
		
		/** @private */
		public function get selected():Boolean
		{
			return _state;
		}
		
		/**
		 * Retrieve the icon displayed on this button as a DisplayObject.
		 * @return The icon (if any).
		 */
		public function get icon():DisplayObject
		{
			return DisplayObject(_icon);
		}
		
		/**
		 * Get/Set the label placement in relation to the icon on this button.
		 * Use the LABEL_ static constants on this class. 
		 * @param str	The label placement to use.
		 * @default right
		 * @see #LABEL_ABOVE
		 * @see #LABEL_BELOW
		 * @see #LABEL_LEFT
		 * @see #LABEL_RIGHT
		 */		
		public function set labelPlacement(str:String):void
		{
			_labelPlacement = str;
			doLayout();
		}
		
		/** @private */
		public function get labelPlacement():String
		{
			return _labelPlacement;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function Button()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			mouseChildren = false;
			
			addStates("Background", 1, [S_UP, S_OVER, S_DOWN]);
			if (_label && _label.length > 0)
			addStates("Label", 50, [S_UP, S_OVER, S_DOWN]);
			addStates("Overlay", 100, [S_UP, S_OVER, S_DOWN]);
			
			phase = S_UP;
		}
		
		/** @private */
		override protected function layout():void
		{
			var background:DisplayObject = getStateElement("Background");
			var label:Label = getStateElement("Label") as Label;
			var overlay:DisplayObject = getStateElement("Overlay");
			
			var m:Metrics;
			
			if (background)
			{
				sizeChild(background, __width, __height);
				m = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			}
			else
				m = new Metrics();
				
			if (overlay)
				sizeChild(overlay, __width, __height);
			
			var iw:Number = 0;
			
			if (_icon)
			{
				iw = _icon.width;
				
				if (iw == 0 && _icon is Container && !(_icon is NullContainer))
				{
					iw = Math.min(__width - m.l - m.r, __height - m.t - m.b);
					_icon.setSize(iw, iw);
				}
			}
			
			var tt:Metrics = new Metrics();
			
			if (label != null)
			{
				var hPad:Number = m.l + __style.padding_l + 4 + __style.padding_r + m.r;
				var vPad:Number = m.t + __style.padding_t + __style.padding_b + m.b;
				var labelWidth:Number = 0;
				var labelHeight:Number = 0;
				
				label.text = _label ? _label : "";
					
				label.multiline = true;
				
				if (labelPlacement == LABEL_LEFT || labelPlacement == LABEL_RIGHT)
				{
					label.wordWrap = false;
					label.autoSize = TextFieldAutoSize.LEFT;
					if (label.width > __width - hPad - iw)
					{
						label.wordWrap = true;
						label.autoSize = TextFieldAutoSize.CENTER;
						labelWidth  = __width - hPad - iw;
					}
					else
						labelWidth = label.width;
						
					
					var row:Number = (iw > 0 ? (iw + 4) : 0) + labelWidth;
					var xx:Number = 0;
					if (label.align == LayoutData.ALIGN_LEFT)
						xx = m.l + __style.padding_l;
					else if (label.align == LayoutData.ALIGN_CENTER)
						xx = (__width - row)/2;
					else if (label.align == LayoutData.ALIGN_RIGHT)
						xx = __width - row - m.r - __style.padding_r;
					
					label.width = labelWidth;
					
					if (labelPlacement == LABEL_RIGHT)
					{
						if (_icon)
						{
							_icon.x = xx;
							xx += iw + 4;
							_icon.y = (__height - _icon.height)/2;
						}
						
						label.x = xx;
						label.y = __style.padding_t + (__height - label.height)/2;
					}
					else if (labelPlacement == LABEL_LEFT)
					{
						label.x = xx;
						label.y = __style.padding_t + (__height - label.height)/2;
						xx += label.width + 4;
						if (_icon)
						{
							_icon.x = xx;
							_icon.y = (__height - _icon.height)/2;
						}
					}
				}
				else if (labelPlacement == LABEL_ABOVE || labelPlacement == LABEL_BELOW)
				{
					label.wordWrap = true;
					label.autoSize = TextFieldAutoSize.CENTER;
					label.width = __width - m.l - m.r - __style.padding_l - __style.padding_r;
					
					var yy:Number = (__height - label.height - (_icon ? _icon.height : 0) - 4)/2;
					if (labelPlacement == LABEL_ABOVE)
					{
						label.move(m.l + __style.padding_l, yy);
						yy += label.height + 4;
						if (_icon)
						{
							_icon.x = (__width - iw)/2;
							_icon.y = yy;
						}
					}
					else
					{
						if (_icon)
						{
							_icon.x = (__width - iw)/2;
							_icon.y = yy;
							yy += _icon.height + 4;
						}
						
						label.move(m.l + __style.padding_l, yy);
					}
				}
				
				
			}
			else
			if (_icon != null)
			{
				_icon.x = (__width - _icon.width)/2;
				_icon.y = (__height - _icon.height)/2;
			}
		}
		
		override protected function createAccessibilityImplementation():void
		{
			accessibilityImplementation = new ButtonAccImpl(this);
		}
		
		private function onIconInit(e:Event):void
		{
			_icon.removeEventListener(Container.E_INIT, onIconInit);
			doLayout();
		}
		
		/** @private */
		override protected function _onRollOver():void
		{
			if (__enabled)
			{
				phase = _state ? S_DOWN : S_OVER;
			}
		}
		
		/** @private */
		override protected function _onRollOut():void
		{
			if (__enabled)
			{
				phase = _state ? S_DOWN : S_UP;
			}
		}
		
		/** @private */
		override protected function _onPress():void
		{
			if (__enabled)
			{
				phase = S_DOWN;
				
				if (_toggle)
					_state = !_state;
			}
		}
		
		/** @private */
		override protected function _onRelease():void
		{
			if (__enabled && !_toggle)
			{
				phase = S_OVER;
			}
			else if (__enabled && _toggle)
			{
				phase = _state ? S_DOWN : S_UP;
			}
		}
		
		/** @private */
		override protected function _onReleaseOutside():void
		{
			_onRollOut();
		}
		
	}
}
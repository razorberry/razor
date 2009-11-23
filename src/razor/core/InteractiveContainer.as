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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import razor.accessibility.BasicAccImpl;
	import razor.core.tooltips.ITooltip;
	import razor.core.tooltips.TooltipData;
	import razor.layout.ModalLayer;
	
	/**
	 * Dispatched when the container is clicked (pressed and released)
	 * @eventType razor.core.InteractiveContainer.E_CLICK
	 */
	[Event(name="e_click", type="flash.events.Event")]
	
	/**
	 * Dispatched when the container is rolled over
	 * @eventType razor.core.InteractiveContainer.E_ROLLOVER
	 */
	[Event(name="e_rollOver", type="flash.events.Event")]
	
	/**
	 * Dispatched when the container is rolled out
	 * @eventType razor.core.InteractiveContainer.E_ROLLOUT
	 */
	[Event(name="e_rollOut", type="flash.events.Event")]
	
	/**
	 * Dispatched when the container is pressed
	 * @eventType razor.core.InteractiveContainer.E_PRESS
	 */
	[Event(name="e_press", type="flash.events.Event")]
	
	/**
	 * Dispatched when the container is released
	 * @eventType razor.core.InteractiveContainer.E_RELEASE
	 */
	[Event(name="e_release", type="flash.events.Event")]
	
	/**
	 * Dispatched when the container is pressed, then the mouse is released
	 * outside of the container bounds.
	 * @eventType razor.core.InteractiveContainer.E_RELEASE_OUTSIDE
	 */
	[Event(name="e_releaseOutside", type="flash.events.Event")]
	
	/**
	 * Class to add mouse interactivity to a StyledContainer.
	 * Used for buttons and such.
	 * <p>In AS3, this mimics the old behaviour of buttons in that you can assign onPress style functions.
	 * You can also use the regular event listeners.</p>
	 * <p>When using the listeners, you should always use the constants provided in this class, since they are
	 * different from the regular MouseEvent constants.</p>
	 */
	public class InteractiveContainer extends StyledContainer
	{
		use namespace razor_internal;
		
		/////////////////////////////////////////////////////////////////
		// EVENT CONSTANTS
		public static const E_CLICK:String = "e_click";
		public static const E_ROLLOVER:String = "e_rollOver";
		public static const E_ROLLOUT:String = "e_rollOut";
		public static const E_PRESS:String = "e_press";
		public static const E_RELEASE:String = "e_release";
		public static const E_RELEASE_OUTSIDE:String = "e_releaseOutside";
		
		private static const traceMouseEvents:Boolean = false;
		
		private var _tooltip:ITooltip;
		private var _tooltipTimer:Timer;
		/** @private */ protected var tooltipData:TooltipData;
		
		/** @private */ protected var mouseIsDown:Boolean = false;
		
		private var _userOnPress:Function;
		private var _userOnRelease:Function;
		private var _userOnRollOver:Function;
		private var _userOnRollOut:Function;
		private var _userOnReleaseOutside:Function;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/** @private */
		public function get onPressCallback():Function
		{
			return _userOnPress;
		}
		
		/**
		 * Set a callback for when this container is pressed.
		 */
		public function set onPressCallback(f:Function):void
		{
			_userOnPress = f;
		}
		
		/** @private */
		public function get onReleaseCallback():Function
		{
			return _userOnRelease;
		}
		
		/**
		 * Set a callback for when this container is released.
		 */
		public function set onReleaseCallback(f:Function):void
		{
			_userOnRelease = f;
		}
		
		/** @private */
		public function get onRollOverCallback():Function
		{
			return _userOnRollOver;
		}
		
		/**
		 * Set a callback for when this container is rolled over with the mouse.
		 */
		public function set onRollOverCallback(f:Function):void
		{
			_userOnRollOver = f;
		}
		
		/** @private */
		public function get onRollOutCallback():Function
		{
			return _userOnRollOut;
		}
		
		/**
		 * Set a callback for when the mouse rolls off this container.
		 */
		public function set onRollOutCallback(f:Function):void
		{
			_userOnRollOut = f;
		}
		
		/** @private */
		public function get onReleaseOutsideCallback():Function
		{
			return _userOnReleaseOutside;
		}
		
		/**
		 * Set a callback for when the mouse is released outside of this container.
		 */
		public function set onReleaseOutsideCallback(f:Function):void
		{
			_userOnReleaseOutside = f;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/**
		 * Constructor.
		 */
		public function InteractiveContainer(disableInitially:Boolean = false)
		{
			super();
			
			if (!disableInitially)
			{
				mouseEnabled = true;
			}
				
			buttonMode = true;
			useHandCursor = true;
			
			addEventListener(MouseEvent.MOUSE_DOWN, __onPress, false, 1);
	        addEventListener(MouseEvent.ROLL_OUT, __onRollOut, false, 1);
	        addEventListener(MouseEvent.ROLL_OVER, __onRollOver, false, 1);
	        addEventListener(MouseEvent.MOUSE_UP, __onRelease, false, 1);
	        addEventListener(MouseEvent.CLICK, __onClick, false, 1);
	        addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
	        addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
		}
		
		override protected function createAccessibilityImplementation():void
		{
			accessibilityImplementation = new BasicAccImpl(this);
		}
		
		// Override these functions in subclasses:
		/**
		 * Abstract rollover method.
		 */
		protected function _onRollOver():void
		{
			
		}
		
		/**
		 * Abstract rollout method.
		 */
		protected function _onRollOut():void
		{
			
		}
		
		/**
		 * Abstract press method.
		 */
		protected function _onPress():void
		{
			
		}
		
		/**
		 * Abstract release method.
		 */
		protected function _onRelease():void
		{
			
		}
		
		/**
		 * Abstract release outside method.
		 */
		protected function _onReleaseOutside():void
		{
			
		}
		
		
		// Super-internal implementations of our button functions that aren't intended to be overridden
		/** @private */
		protected final function __onRollOver(e:MouseEvent = null):void
		{
			if (!mouseEnabled) return;
			
			if (traceMouseEvents)
				debug("onRollOver");
			
			if (mouseIsDown)
				return;
			
			createTimer();
			
			if (_userOnRollOver != null)
				_userOnRollOver();
			_onRollOver();
			if (__enabled)
				dispatchEvent(new Event(E_ROLLOVER));
		}
		
		/** @private */
		protected final function __onRollOut(e:MouseEvent = null):void
		{
			if (!mouseEnabled) return;
			
			if (traceMouseEvents)
				debug("onRollOut");

			if (_tooltip)
				destroyTooltip();
			destroyTimer();
				
			if (mouseIsDown)
				return;
				
			if (_userOnRollOut != null)
				_userOnRollOut();
			_onRollOut();
			if (__enabled)
				dispatchEvent(new Event(E_ROLLOUT));
		}
		
		/** @private */
		protected final function __onPress(e:MouseEvent = null):void
		{
			if (!mouseEnabled) return;
			
			if (traceMouseEvents)
				debug("onPress");
			
			if (_tooltip)
				destroyTooltip();
			destroyTimer();
			
			mouseIsDown = true;
			if (_userOnPress != null)
				_userOnPress();
			_onPress();
			
			if (stage != null)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 1, true);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			}
			
			if (__enabled)
				dispatchEvent(new Event(E_PRESS));
		}
		
		/** @private */
		protected final function __onClick(e:MouseEvent = null):void
		{
			if (!mouseEnabled) return;
			
			if (traceMouseEvents)
				debug("onClick");
			
			if (enterPressed || spacePressed)
			{
				__onPress();
				__onRelease();
			}
			//if (__enabled)
			//dispatchEvent(new Event(E_CLICK));
		}
		
		/** @private */
		private function onRemoved(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false);
		}
		
		/** @private */
		protected final function onStageMouseUp(e:MouseEvent = null):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			mouseIsDown = false;
			if (e && !contains(DisplayObject(e.target)) )
			{
				__onReleaseOutside();
			}
		}
		
		/** @private */
		protected final function __onRelease(e:MouseEvent = null):void
		{
			if (!mouseIsDown || !mouseEnabled)
				return;
				
			if (traceMouseEvents)
				debug("onRelease");
				
			mouseIsDown = false;
			if (_userOnRelease != null)
				_userOnRelease();
			_onRelease();
			if (__enabled)
			{
				dispatchEvent(new Event(E_RELEASE));
				dispatchEvent(new Event(E_CLICK));
			}
		}
		
		/** @private */
		protected final function __onReleaseOutside(e:MouseEvent = null):void
		{
			if (!mouseEnabled) return;
			
			if (traceMouseEvents)
				debug("onReleaseOutside");
			
			if (_userOnReleaseOutside != null)
				_userOnReleaseOutside();
			_onReleaseOutside();
			if (__enabled)
				dispatchEvent(new Event(E_RELEASE_OUTSIDE));
		}
		
		private var enterPressed:Boolean = false;
		private var spacePressed:Boolean = false;
		/** @private */
		protected function __onKeyDown(e:KeyboardEvent):void
		{
			if (e.charCode == Keyboard.ENTER)
				enterPressed = true;
			if (e.charCode == Keyboard.SPACE)
				spacePressed = true;
		}
		
		/** @private */
		protected function __onKeyUp(e:KeyboardEvent):void
		{
			if (e.charCode == Keyboard.ENTER)
				enterPressed = false;
			if (e.charCode == Keyboard.SPACE)
				spacePressed = false;
		}
		
		override public function set enabled(b:Boolean):void
		{
			mouseEnabled = b;
			super.enabled = b;
		}
		
		override public function destroy():void
		{
			if (_tooltipTimer)
			{
				_tooltipTimer.stop();
				
			}
			if (_tooltip)
			{
				_tooltip.destroy();
				_tooltip = null;
			}
			
			super.destroy();
		}
		
		private function createTimer():void
		{
			destroyTimer();
			
			_tooltipTimer = new Timer(750, 1);
			_tooltipTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false, 0, true);
			_tooltipTimer.start();
		}
		
		private function destroyTimer():void
		{
			if (_tooltipTimer)
			{
				_tooltipTimer.stop();
				_tooltipTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_tooltipTimer = null;
			}
		}
		
		private function onTimerComplete(e:TimerEvent):void
		{
			destroyTimer();
			
			// Only put tooltips on stage objects.. otherwise timer gets destroyed
			// no harm, no foul if container is removed mid-timer.
			if (stage != null && tooltipData != null)
			{
				if (_tooltip == null)
				{
					var ml:ModalLayer = ModalLayer.getInstance();
					_tooltip = ml.addBlueprint("ToolTip") as ITooltip;
					if (_tooltip)
					{
						_tooltip.setValue(tooltipData);
						var p:Point = new Point(mouseX, mouseY);
						p = ml.globalToLocal(localToGlobal(p));
						_tooltip.move(p.x, p.y + 20);
					}
					else
						_tooltip = null;
				}
				else
					_tooltip.setValue(tooltipData);
			}
			else
				_tooltip = null;
			
		}
		
		private function destroyTooltip():void
		{
			if (_tooltip)
			{
				_tooltip.destroy();
				_tooltip = null;
			}
		}
		
		public function set tooltip(data:TooltipData):void
		{
			tooltipData = data;
		}
		
		public function get tooltip():TooltipData
		{
			return tooltipData;
		}
		
	}
	
}
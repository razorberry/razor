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
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import razor.core.InteractiveContainer;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Dispatched when the current position of the scrollbar has changed.
	 * @eventType razor.controls.ScrollBar.E_SCROLL
	 */
	[Event(name="scroll", type="razor.core.RazorEvent")]

	/**
	 * A standard scrollbar component.
	 * @example
	 * <listing version="3.0">
	 * var sb:ScrollBar = addChild(new ScrollBar());
	 * sb.setSize(200,24);
	 * sb.horizontal = true;
	 * sb.setScrollProperties(10,0,100);
	 * sb.addEventListener(ScrollBar.E_SCROLL, onScroll);
	 * </listing>
	 */
	public class ScrollBar extends StyledContainer
	{
		use namespace razor_internal;
		
		public static var E_SCROLL:String = Event.SCROLL;
	
		/** @private */ override protected function getClass():String { return "ScrollBar"; }
		
		/** @private */ protected var _horizontal:Boolean = false;
	
		/** @private */ protected var scrollTrack:DisplayObject;
		/** @private */ protected var scrollTrackButton:InteractiveContainer;
		/** @private */ protected var upButton:Button;
		/** @private */ protected var downButton:Button;
		/** @private */ protected var scrollThumb:Button;
		
		/**
		 * The amount to scroll when clicking on the arrow buttons.
		 */
		public var smallScroll:Number = 1;
		
		/** @private */ protected var _minimum:Number = 0;
		/** @private */ protected var _maximum:Number = 10;
		/** @private */ protected var _pageSize:Number = 3;
		/** @private */ protected var _value:Number = 0;
		/** @private */ protected var _wheelTarget:InteractiveObject;
		
		/** @private */ private var interval:Number;
		/** @private */ protected var dragging:Boolean = false;
		
		/**
		 * The delay in milliseconds before the scroll is repeated (when holding down a button).
		 */
		public var repeatDelay:uint = 250; // ms
		/**
		 * The delay in milliseconds between each scroll while repeating.
		 */
		public var repeatInterval:uint = 50;
		
		/**
		 * A boolean to indicate whether to round the position to a whole number.
		 * @default false
		 */
		public var roundPosition:Boolean = false;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set the scroll properties for this scrollbar.
		* @param	pageSize	The size of a page
		* @param	minimum		The minimum scroll value
		* @param	maximum		The maximum scroll value
		*/
		public function setScrollProperties(pageSize:Number, minimum:Number, maximum:Number):void
		{
			if (pageSize == _pageSize && minimum == _minimum && maximum == _maximum) return;
			
			_pageSize = Math.max(1,pageSize);
			_minimum = minimum;
			_maximum = maximum;
			
			if (!isNaN(_maximum) && !isNaN(_minimum))
			{
				_value = Math.min(_value, _maximum);
				_value = Math.max(_value, _minimum);
			}
			
			if (!dragging)
			positionThumb();
		}
		
		/**
		* Get/set the current scroll position. The value will be clamped between minimum and maximum.
		* @param	n	The new scroll position.
		*/
		public function set scrollPosition(n:Number):void
		{
			var old:Number = _value;
			// Restrict to boundaries
			_value = Math.min(n, _maximum);
			_value = Math.max(_value, _minimum);
			
			//if (old == _value) return;
			
			if (!dragging)
			positionThumb();
			
			dispatchScroll();
		}
		
		/** @private */
		public function get scrollPosition():Number
		{
			return _value;
		}
		
		/**
		* Get/Set the orientation of this scrollbar.
		* @param	b	A boolean indicating whether this scrollbar is horizontal.
		*/
		public function set horizontal(b:Boolean):void
		{
			_horizontal = b;
			if (__initialized)
				doLayout();
		}
		
		/** @private */
		public function get horizontal():Boolean
		{
			return _horizontal;
		}
		
		/**
		 * Get/Set the target for the mousewheel.
		 * Scrolling the mousewheel over this target will move the scrollPosition
		 * @param target	The target display object
		 */
		public function set wheelTarget(target:InteractiveObject):void
		{
			if (_wheelTarget)
				_wheelTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheelScroll);
				
			_wheelTarget = target;
			
			_wheelTarget.addEventListener(MouseEvent.MOUSE_WHEEL, onWheelScroll, false, 0, true);
		}
		
		/** @private */
		public function get wheelTarget():InteractiveObject
		{
			return _wheelTarget;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			scrollTrack = addBlueprint("Background");
			scrollTrackButton = new InteractiveContainer();
			addChild(scrollTrackButton);
			upButton = addBlueprint("UpButton") as Button;
			upButton.addIcon("Arrow");
			
			downButton = addBlueprint("DownButton") as Button;
			downButton.addIcon("Arrow");
			
			scrollThumb = addBlueprint("Thumb") as Button;
			scrollTrackButton.useHandCursor = upButton.useHandCursor = downButton.useHandCursor = scrollThumb.useHandCursor = false;
			
			downButton.addEventListener(Button.E_PRESS, onDownPress);
			downButton.addEventListener(Button.E_RELEASE, stopScrolling);
			downButton.addEventListener(Button.E_RELEASE_OUTSIDE, stopScrolling);
			upButton.addEventListener(Button.E_PRESS, onUpPress);
			upButton.addEventListener(Button.E_RELEASE, stopScrolling);
			upButton.addEventListener(Button.E_RELEASE_OUTSIDE, stopScrolling);
			scrollTrackButton.addEventListener(Button.E_PRESS, onTrackPress);
			scrollTrackButton.addEventListener(Button.E_RELEASE, stopScrolling);
			scrollTrackButton.addEventListener(Button.E_RELEASE_OUTSIDE, stopScrolling);
			scrollThumb.addEventListener(Button.E_PRESS, onThumbPress);
			scrollThumb.addEventListener(Button.E_RELEASE, stopThumbScrolling);
			scrollThumb.addEventListener(Button.E_RELEASE_OUTSIDE, stopThumbScrolling);
		}
		
		/** @private */
		override protected function layout():void
		{
			if (isNaN(__width) || isNaN(__height))
				return;
				
			if (upButton && upButton.icon)
			upButton.icon.rotation = (_horizontal ? -180 : -90);
			if (downButton && downButton.icon)
			downButton.icon.rotation = (_horizontal ? 0 : 90);
			if (_horizontal)
			{
				upButton.setSize(__height,__height);
				downButton.setSize(__height,__height);
				sizeChild(scrollTrack, __width - (__height*2), __height);
				
				downButton.move(__width - __height,0);
				scrollTrack.x = __height;
				scrollTrack.y = 0;
				scrollTrackButton.graphics.clear();
				scrollTrackButton.graphics.beginFill(0,0);
				scrollTrackButton.graphics.drawRect(__height,0,__width - (__height*2), __height);
				scrollTrackButton.graphics.endFill();
			}
			else
			{
				upButton.setSize(__width,__width);
				downButton.setSize(__width,__width);
				sizeChild(scrollTrack, __width,__height - (__width*2));
				
				downButton.move(0,__height - __width);
				scrollTrack.x = 0;
				scrollTrack.y = __width;
				scrollTrackButton.graphics.clear();
				scrollTrackButton.graphics.beginFill(0,0);
				scrollTrackButton.graphics.drawRect(0,__width,__width,__height - (__width*2));
				scrollTrackButton.graphics.endFill();
			}
			if (!dragging)
			positionThumb();
		}
		
		/** @private */
		protected function positionThumb():void
		{
			var h:Number = Math.min(1, _pageSize/(_maximum+_pageSize));
			//trace(_pageSize + "  "+_maximum);
			var ah:Number;
			if (_horizontal)
			{
				ah = Math.max(10, h * scrollTrack.width);
				//if (ah != scrollThumb.width)
				scrollThumb.setSize(ah, __height);
				var y:Number = ((_value-_minimum) * (scrollTrack.width-scrollThumb.width) / Math.max(1,(_maximum - _minimum)));
				scrollThumb.move(upButton.width + y,0);
			}
			else
			{
				ah = Math.max(10, h * scrollTrack.height);
				//if (ah != scrollThumb.height)
				scrollThumb.setSize(__width, ah);
				var yy:Number = ((_value-_minimum) * (scrollTrack.height-scrollThumb.height) / Math.max(1,(_maximum - _minimum)));
				scrollThumb.move(0,upButton.height + yy);
			}
		}
		
		/**
		 * Called when the down arrow button is pressed
		 */
		private function onDownPress(e:Event):void
		{
			doScroll(smallScroll);
			interval = setInterval(repeatScroll, repeatDelay, smallScroll);
		}
		
		/**
		 * Called when the up arrow button is pressed
		 */
		private function onUpPress(e:Event):void
		{
			doScroll(0-smallScroll);
			interval = setInterval(repeatScroll, repeatDelay, 0-smallScroll);
		}
		
		/**
		 * Called when the scroll track is clicked
		 */
		private function onTrackPress(e:Event):void
		{
			trackScroll(_pageSize);
			interval = setInterval(repeatTrackScroll, repeatDelay, _pageSize);
		}
		
		private function repeatTrackScroll(amount:Number):void
		{
			clearInterval(interval);
			interval = setInterval(trackScroll, repeatInterval, amount);
		}
		
		private function repeatScroll(amount:Number):void
		{
			clearInterval(interval);
			interval = setInterval(doScroll, repeatInterval, amount); 
		}
		
		/**
		 * Called when the mousewheel is scrolled over wheelTarget
		 */
		private function onWheelScroll(e:MouseEvent):void
		{
			doScroll(e.delta * -smallScroll);
		}
		
		/**
		 * Move the scrollbar by a specific amount (+/-)
		 */
		private function doScroll(amount:Number):void
		{
			scrollPosition = _value + amount;
			dispatchScroll();
		}
		
		private function dispatchScroll():void
		{
			// TODO: formalize this event
			dispatchEvent(new RazorEvent(E_SCROLL, {scrollPosition: _value}));
		}
		
		private function trackScroll(amount:Number):void
		{
			if (_horizontal)
			{
				if (scrollThumb.x+scrollThumb.width < mouseX)
					doScroll(amount);
				else if (scrollThumb.x > mouseX)
					doScroll(0-amount);
			}
			else
			{
				if (scrollThumb.y+scrollThumb.height < mouseY)
					doScroll(amount);
				else if (scrollThumb.y > mouseY)
					doScroll(0-amount);
			}
		}
		
		/**
		 * Called when the scroll thumb is pressed. Start dragging the button.
		 */
		private function onThumbPress(e:Event):void
		{
			if (_horizontal)
				scrollThumb.startDrag(false,new Rectangle(upButton.width,0,downButton.x - upButton.width - scrollThumb.width,0));
			else
				scrollThumb.startDrag(false,new Rectangle(0,upButton.height,0,downButton.y - upButton.height - scrollThumb.height));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbScroll,false,0,true);
			dragging = true;
		}
		
		private function onThumbScroll(e:Event):void
		{
			// TODO: Optimization: Limit dispatching rate while dragging (on frame or per time period).
			var p:Number;
			if (_horizontal)
				p = ((_maximum - _minimum) * (scrollThumb.x - upButton.width)) / (scrollTrack.width-scrollThumb.width-1) + _minimum;
			else
				p = ((_maximum - _minimum) * (scrollThumb.y - upButton.height)) / (scrollTrack.height-scrollThumb.height-1) + _minimum;
			var i:Number = scrollPosition;
			
			var j:Number = roundPosition ? Math.round(p) : p;
	
			scrollPosition = j;
			
			dispatchScroll();
		}
		
		/**
		 * Stop automatically scrolling
		 */
		private function stopScrolling(e:Event):void
		{
			clearInterval(interval);
		}
		
		/**
		 * Called when the scroll thumb is released.
		 */
		private function stopThumbScrolling(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbScroll,false);
			scrollThumb.stopDrag();
			onThumbScroll(null)
			dragging = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			if (_wheelTarget)
				_wheelTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheelScroll);
				
			super.destroy();
		}
	}
}
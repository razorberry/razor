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

package razor.layout
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import razor.controls.ScrollBar;
	import razor.core.Container;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * A container with automatic scrollbars for the content.
	 * You can reference the internal container with the content property.
	 * You can also change the class of the content container with the contentClass property.
	 * @see #content
	 * @see #contentClass
	 * @example
	 * <listing version="3.0">
	 * var sa:ScrollArea = addChild(new ScrollArea());
	 * sa.setSize(400,400);
	 * var acc:Accordion = sa.content.addLayoutElement(Accordion, {width: 400, height: 400});
	 * ...
	 * </listing>
	 */
	public class ScrollArea extends StyledContainer
	{
		use namespace razor_internal;
		
		/**
		* Constants for hScrollPolicy and vScrollPolicy.
		*/
		public static const SCROLL_NEVER:String = "never";
		public static const SCROLL_AUTO:String = "auto";
		public static const SCROLL_ALWAYS:String = "always";
		
		//
		
		/** @private */ override protected function getClass():String { return "ScrollArea"; }
		
		
		public var scrollbarWidth:Number = 16;
		
		/** @private */ protected var _contentClass:Class = Layer;
		
		/** @private */ protected var _content:DisplayObjectContainer;
		/** @private */ protected var cmask:Sprite;
		/** @private */ protected var vScroll:ScrollBar;
		/** @private */ protected var hScroll:ScrollBar;
		/** @private */ protected var _contentWidth:Number;
		/** @private */ protected var _contentHeight:Number;
		
		/** @private */ protected var _hScrollPolicy:String = SCROLL_AUTO;
		/** @private */ protected var _vScrollPolicy:String = SCROLL_AUTO;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		
		/**
		 * Set/Get the class of the content container.
		 * Setting this will destroy the current content.
		 * @default Layer 
		 * @param c	The content class
		 * 
		 */
		public function set contentClass(c:Class):void
		{
			_contentClass = c;
			_content.removeEventListener(Container.E_RESIZE, update);
			if (_content is Container) Container(_content).destroy();
			
			_content = DisplayObjectContainer(addBlueprint(_contentClass));
			_content.addEventListener(Container.E_RESIZE, update);
			_content.mask = cmask;
			
			doLayout();
		}
		
		/** @private */
		public function get contentClass():Class
		{
			return _contentClass;
		}
		
		/**
		 * Update the scrollbars manually.
		 * Scrollbars will normally be updated automatically, but the content must dispatch a resize event.
		 */
		public function update(e:Event = null):void
		{
			adjustScrollbars();
		}
		
		/**
		* Get/Set the vertical scroll position (in px).
		* @param	n	The position to scroll to
		*/
		public function set vScrollPosition(n:Number):void
		{
			_content.y = 0 - Math.max(0,Math.min(contentHeight, n));
			vScroll.scrollPosition = Math.max(0,Math.min(contentHeight, n));
		}
		
		/** @private */
		public function get vScrollPosition():Number
		{
			return (0 - _content.y);
		}
		
		/**
		* Get/Set the horizontal scroll position (in px).
		* @param	n	The position to scroll to
		*/
		public function set hScrollPosition(n:Number):void
		{
			_content.x = 0 - Math.max(0, Math.min(contentWidth, n));
			hScroll.scrollPosition = Math.max(0, Math.min(contentWidth, n));
		}
		
		/** @private */
		public function get hScrollPosition():Number
		{
			return (0 - _content.x);
		}
		
		/**
		* Get/Set the vertical scroll position (in px).
		* @param	n	The position to scroll to
		*/
		private function set _vScrollPosition(n:Number):void
		{
			_content.y = 0 - Math.max(0,Math.min(contentHeight, n));
		}
		
		/** @private */
		private function get _vScrollPosition():Number
		{
			return (0 - _content.y);
		}
		
		/**
		* Get/Set the horizontal scroll position (in px).
		* @param	n	The position to scroll to
		*/
		private function set _hScrollPosition(n:Number):void
		{
			_content.x = 0 - Math.max(0, Math.min(contentWidth, n));
		}
		
		/** @private */
		private function get _hScrollPosition():Number
		{
			return (0 - _content.x);
		}
		
		/**
		* Get or manually set the content width.
		* @param	n	The width of the content.
		*/
		public function set contentWidth(n:Number):void
		{
			_contentWidth = n;
			doLayout();
		}
		
		/** @private */
		public function get contentWidth():Number
		{
			var c:Rectangle = _content.getBounds(_content);
			return (_contentWidth > 0 ? _contentWidth :  ((_content.hasOwnProperty("visibleWidth") && Object(_content).visibleWidth >= 0) ? Object(_content).visibleWidth : (c.width + c.x)));
		}
		
		/**
		* Get or manually set the content height
		* @param	n	The height of the content.
		*/
		public function set contentHeight(n:Number):void
		{
			_contentHeight = n;
			doLayout();
		}
		
		/** @private */
		public function get contentHeight():Number
		{
			var c:Rectangle = _content.getBounds(_content);
			return (_contentHeight > 0 ? _contentHeight : ((_content.hasOwnProperty("visibleHeight") && Object(_content).visibleHeight >= 0) ? Object(_content).visibleHeight : (c.height + c.y)));
		}
		
		/**
		* Get the current content
		* @return	The current content
		*/
		public function get content():DisplayObjectContainer
		{
			return _content;
		}
		
		/**
		* Get/Set the current horizontal scrolling policy.
		* @param	policy	Either SCROLL_NEVER, SCROLL_AUTO(default), or SCROLL_ALWAYS
		*/
		public function set hScrollPolicy(policy:String):void
		{
			_hScrollPolicy = policy;
			adjustScrollbars();
		}
		
		/** @private */
		public function get hScrollPolicy():String
		{
			return _hScrollPolicy;
		}
		
		/**
		* Get/Set the current vertical scrolling policy.
		* @param	policy	Either SCROLL_NEVER, SCROLL_AUTO(default), or SCROLL_ALWAYS
		*/
		public function set vScrollPolicy(policy:String):void
		{
			_vScrollPolicy = policy;
			adjustScrollbars();
		}
		
		/** @private */
		public function get vScrollPolicy():String
		{
			return _vScrollPolicy;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function ScrollArea(contentClass:Class = null)
		{
			if (contentClass)
				this.contentClass = contentClass;
		}
		
		/** @private */
		override protected function construct():void
		{
			_content = DisplayObjectContainer(addBlueprint(_contentClass));
			_content.addEventListener(Container.E_RESIZE, update);
			cmask = new Sprite();
			cmask.graphics.beginFill(0,1);
			cmask.graphics.drawRect(0,0,100,100);
			cmask.graphics.endFill();
			addChild(cmask);
			_content.mask = cmask;
		}
		
		/** @private */
		override protected function layout():void
		{
			//debug("layout");
			var ww:Number = (vScroll && vScroll.visible ? __width - scrollbarWidth : __width);
			var hh:Number = (hScroll && hScroll.visible ? __height - scrollbarWidth : __height);
			cmask.width = ww;
			cmask.height = hh;
			//_content.mask = cmask;
			
			if ((_contentWidth > 0 || _contentHeight > 0 || _content is Layer))
				sizeChild(_content, ww, hh);
				
			// adjustScrollbars is called when _content dispatches a resize event (now)
			
			// draw an invisible box to capture mouse wheel events:
			graphics.clear();
			if (__width > 0 && __height > 0)
			{
				graphics.beginFill(0,0);
				graphics.drawRect(0,0,__width, __height);
				graphics.endFill();
			}
		}
		
		/**
		* Measure the content and adjust the scrollbars accordingly.
		* @private 
		*/
		protected function adjustScrollbars():void
		{
			var ch:Number = contentHeight;
			var cw:Number = contentWidth;
			
			var useh:Boolean = false;
			var usev:Boolean = false;
			var alterwidth:Boolean = false;
			if (cw > __width)
			{
				useh = true;
			}
			
			if (ch > __height - (useh ? scrollbarWidth : 0))
			{
				usev = true;
			}
			
			if (usev && !useh)
			{
				if (contentWidth > __width - scrollbarWidth)
				{
					useh = true;
				}
			}
			else if (useh && !usev)
			{
				if (contentHeight > __height - scrollbarWidth)
				{
					usev = true;
				}
			}
			
			// Policy overrides
			useh = (_hScrollPolicy == SCROLL_NEVER ? false : (_hScrollPolicy == SCROLL_ALWAYS ? true : useh));
			usev = (_vScrollPolicy == SCROLL_NEVER ? false : (_vScrollPolicy == SCROLL_ALWAYS ? true : usev));
			
			if (useh)
			{
				if (hScroll == null)
				{
					hScroll = addBlueprint(ScrollBar) as ScrollBar;
					hScroll.horizontal = true;
					hScroll.addEventListener(ScrollBar.E_SCROLL, onHScroll);
				}
				hScroll.visible = true;
				hScroll.move(0, __height - scrollbarWidth);
				hScroll.setSize(__width - (usev ? scrollbarWidth : 0), scrollbarWidth);
				hScroll.smallScroll = 10;
				hScroll.setScrollProperties(__width - (usev ? scrollbarWidth : 0), 0, cw - __width + (usev ? scrollbarWidth : 0) + 2);
				//hScroll.scrollPosition = xPos;
			}
			else
			{
				if (hScroll != null)
				{
					hScroll.setScrollProperties(__width - (usev ? scrollbarWidth : 0), 0, cw - __width + (usev ? scrollbarWidth : 0) + 2);
					hScroll.visible = false;
				}
			}
			
			if (usev)
			{
				if (vScroll == null)
				{
					vScroll = addBlueprint(ScrollBar) as ScrollBar;
					vScroll.addEventListener(ScrollBar.E_SCROLL,onVScroll);
				}
				vScroll.visible = true;
				vScroll.move(__width - scrollbarWidth, 0);
				vScroll.setSize(scrollbarWidth, __height - (useh ? scrollbarWidth : 0));
				
				vScroll.setScrollProperties(__height - (useh ? scrollbarWidth : 0), 0, ch - __height + (useh ? scrollbarWidth : 0) + 2);
				vScroll.smallScroll = 10;
				vScroll.wheelTarget = this;
			}
			else
			{
				if (vScroll != null)
				{
					vScroll.setScrollProperties(__height - (useh ? scrollbarWidth : 0), 0, ch - __height + (useh ? scrollbarWidth : 0) + 2);
					vScroll.visible = false;
				}
			}
			
			if (hScroll)
				_hScrollPosition = hScroll.scrollPosition;
			if (vScroll)
				_vScrollPosition = vScroll.scrollPosition;
		}
		
		/**
		* Called when the vertical scroll bar is moved.
		*/
		private function onVScroll(e:Event):void
		{
			_vScrollPosition = vScroll.scrollPosition;
		}
		
		/**
		* Called when the horizontal scroll bar is moved.
		*/
		private function onHScroll(e:Event):void
		{
			_hScrollPosition = hScroll.scrollPosition;
		}
		
	}
}
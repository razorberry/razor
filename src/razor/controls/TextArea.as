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
	import flash.text.TextField;
	
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.razor_internal;
	
	/**
	 * Class for a text area component with automatic scrollbars and the usual accoutrements.
	 * @example
	 * <listing version="3.0">
	 * var ta:TextArea = addChild(new TextArea());
	 * ta.setSize(200,200);
	 * ta.text = "Default text.";
	 * ta.editable = true;
	 * </listing>
	 */
	public class TextArea extends Label
	{
		use namespace razor_internal;
		
		// Event constants:
		public static const E_CHANGE:String = Event.CHANGE;
		public static const E_SCROLL:String = Event.SCROLL;
		
		/** @private */ override protected function getClass():String { return "TextArea"; }
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var hScroll:ScrollBar;
		/** @private */ protected var vScroll:ScrollBar;
		/** @private */ protected var overlay:DisplayObject;
		/** @private */ protected var _scrolling:Boolean = false;
	
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Set whether this TextArea should wordwrap text.
		* @param	b	A boolean indicating whether to wordwrap.
		*/
		override public function set wordWrap(b:Boolean):void
		{
			super.wordWrap = b;
			checkScroll();
		}
		
		public function set scrollV(v:Number):void
		{
			textField.scrollV = v;
			checkScroll();
		}
		
		public function get scrollV():Number
		{
			return textField.scrollV;
		}
		
		public function set scrollH(v:Number):void
		{
			textField.scrollH = v;
			checkScroll();
		}
		
		public function get scrollH():Number
		{
			return textField.scrollH;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function TextArea():void
		{
			
		}
		
		/** @private */ 
		override protected function construct():void
		{
			background = addBlueprint("Background");
			textField = createTF();
			addChild(textField);
			overlay = addBlueprint("Overlay");
		}
		
		/** @private */ 
		override protected function layout():void
		{
			sizeChild(background, __width, __height);
			sizeChild(overlay, __width, __height);
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			if (textField.styleSheet == null)
				textField.defaultTextFormat = __style.textFormat;
			
			textField.x = m.l;
			textField.y = m.t;
			
			checkScroll();
		}
		
		
		/**
		* Adjust scrollbars depending on text content.
		* Scrollbars will become invisible when not required.
		 * @todo Scrollbar width is hardcoded in this method.
		* @private 
		*/
		protected function checkScroll():void
		{
			if (!(__width > 0 && __height > 0))
				return;
				
			var baseScrollV:int;
			var baseScrollH:int;
			_scrolling = true;
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			var w:Number = __width - m.l - m.r;
			var h:Number = __height - m.t - m.b;
			baseScrollV = textField.scrollV;
			baseScrollH = textField.scrollH;
			textField.width = w; 
			textField.height = h;
			//
			//
			// Wait until the next frame to adjust the scrollbars because maxScroll is incorrect
			// at this point.
			removeEventListener(Event.ENTER_FRAME, adjustScrollbars);
			addEventListener(Event.ENTER_FRAME, adjustScrollbars);
		}
		
		protected function adjustScrollbars(e:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, adjustScrollbars);
			
			if (!(__width > 0 && __height > 0))
				return;
				
			var baseScrollV:int;
			var baseScrollH:int;
			_scrolling = true;
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			var w:Number = __width - m.l - m.r;
			var h:Number = __height - m.t - m.b;
			baseScrollV = textField.scrollV;
			baseScrollH = textField.scrollH;
			textField.width = w; 
			textField.height = h;
			//
			//
			
			var usev:Boolean = (textField.maxScrollV > 1);
			if (usev)
				w -= 14;
		
			var useh:Boolean = (textField.maxScrollH > 0);
			if (useh)
				h -= 14;
					
			textField.width = w;
			textField.height = h;
			
			if (useh && !usev && (textField.maxScrollV > 1))
			{
				usev = true;
				w -= 14;
				textField.width = w;
			}
			
			//trace("max: "+textField.maxScrollV +"  page: "+ps + "  bottom: "+ textField.bottomScrollV);
			
			
			if (useh)
			{
				textField.height = __height - m.t - m.b - 14;
				
				if (hScroll == null)
				{
					createHScroll();
				}
				else
					hScroll.visible = true;
				
				textField.scrollH = baseScrollH;
				hScroll.setScrollProperties(textField.width, 0, textField.maxScrollH);
				hScroll.smallScroll = 8;
				hScroll.scrollPosition = textField.scrollH;
			}
			else
			{
				textField.scrollH = baseScrollH;
				if (hScroll != null)
					hScroll.visible = false;
			}
			
			if (usev)
			{
				textField.width = __width -  m.l - m.r - 14;
				
				if (vScroll == null)
				{
					createVScroll();
				}
				else
					vScroll.visible = true;
				
				textField.scrollV = baseScrollV;
				vScroll.setScrollProperties((textField.bottomScrollV - textField.scrollV), 1, textField.maxScrollV);
				vScroll.scrollPosition = textField.scrollV;
			}
			else
			{
				textField.scrollV = baseScrollV;
				if (vScroll != null)
					vScroll.visible = false;
			}
			
			positionScrollbars();
			
			_scrolling = false;
		}
		
		/**
		 * Position the scrollbars
		 * @private
		 */
		protected function positionScrollbars():void
		{
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			var usev:Boolean = false;
			var useh:Boolean = false;
			
			if (textField.maxScrollV > 1) usev = true;
			if (textField.maxScrollH > 0) useh = true;
			
			// TODO: scrollbar width shouldnt be fixed at 16 here:
			if (vScroll != null)
			{
				vScroll.setSize(16, __height - m.t - m.b - (useh ? 16 : 0));
				vScroll.move(__width - m.r - 16, m.t);
			}
			
			if (hScroll != null)
			{
				hScroll.setSize(__width - m.l - m.r - (usev ? 16 : 0), 16);
				hScroll.move(m.l, __height - m.b - 16);
			}
		}
		
		/**
		* Create the vertical scrollbar.
		* @private
		*/
		protected function createVScroll():void
		{
			vScroll = addBlueprint(ScrollBar, {horizontal: false}, 70) as ScrollBar;
			vScroll.addEventListener(ScrollBar.E_SCROLL,onScroll);
		}
		
		/**
		* Create the horizontal scrollbar.
		* @private
		*/
		protected function createHScroll():void
		{
			hScroll = addBlueprint(ScrollBar, {horizontal: true}, 70) as ScrollBar;
			hScroll.addEventListener(ScrollBar.E_SCROLL,onScroll);
		}
		
		//
		//
		//
		
		/**
		* @inheritDoc
		*/
		override protected function onTFChanged(e:Event):void
		{
			onTFSet();
			dispatchEvent(new Event(E_CHANGE));
		}
		
		/**
		* @inheritDoc
		*/
		override protected function onTFSet():void
		{
			checkScroll();
			sizeToField();
		}
		
		
		private function sizeToField():void
		{
			if (autoSize == "left" || autoSize == "center" || autoSize == "right")
			{
				var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
				__width = textField.width + m.l + m.r + (vScroll && vScroll.visible ? vScroll.width - 2 : 0);
				__height = textField.height + m.t + m.b + (hScroll && hScroll.visible ? hScroll.height - 2: 0);
			}
		}
		
		/**
		* Called when the text field is scrolled. (ie. with the cursor down key).
		* @param	target	The textfield that was scrolled
		* @private
		*/
		override protected function onFieldScroll(target:TextField = null):void
		{
			if (!_scrolling)
			{
				checkScroll();
				super.onFieldScroll(target);
			}
		}
		
		/**
		* Called when the scrollbar is scrolled.
		* @param	evOb	The scrollbar that was scrolled.
		*/
		private function onScroll(e:Event):void
		{
			if (!_scrolling)
			{
				_scrolling = true;
				if (vScroll && vScroll.visible) textField.scrollV = vScroll.scrollPosition;
				if (hScroll && hScroll.visible) textField.scrollH = hScroll.scrollPosition;
				_scrolling = false;
				dispatchEvent(new Event(E_SCROLL));
			}
			
		}
		
		/** @private */ 
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,80);
		}
	}
}
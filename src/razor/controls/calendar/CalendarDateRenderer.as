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

package razor.controls.calendar 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	
	import razor.controls.Calendar;
	import razor.controls.Label;
	import razor.core.InteractiveContainer;
	import razor.core.razor_internal;
	
	/**
	 * The default renderer for a single date (ie, "21") in the Calendar control.
	 */
	public class CalendarDateRenderer extends InteractiveContainer
		implements ICalendarDateRenderer, ICalendarEventRenderer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "DateRenderer"; }
		
		/** @private */ protected var _owner:Calendar;
		/** @private */ protected var hasEvents:Boolean = false;
		/** @private */ protected var _events:Array;
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var label:Label;
		/** @private */ protected var overlay:Sprite;
		/** @private */ protected var _date:Date;
		/** @private */ protected var _isCurrent:Boolean = false;
		/** @private */ protected var _isOutOfMonth:Boolean = false;
		/** @private */ protected var _isSelected:Boolean = false;
		
		/** @private */ protected var mouseIsOver:Boolean = false;
		
		public function CalendarDateRenderer() 
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			label = addBlueprint(Label) as Label;
			label.autoSize = "left";
			mouseChildren = false;
			overlay = addChild(new Sprite()) as Sprite;
			
			if (__width > 0 && __height > 0)
			{
				drawOverlay();
			}
		}
		
		/** @private */
		override protected function layout():void
		{
			if (__width > 0 && __height > 0)
				drawOverlay();
				
			sizeChild(background, __width, __height);
			if (_date)
			{
				label.text = String(_date.date);
			}
			label.move((__width - label.width) / 2, (__height - label.height) / 2);
			label.mergeStyle({fontColor: (_isOutOfMonth ? 0xBBBBBB : 0), italic: _isOutOfMonth});
			mouseEnabled = !_isOutOfMonth;
			useHandCursor = mouseEnabled;
		}
		
		/** @private */
		protected function drawOverlay():void
		{
			var g:Graphics = overlay.graphics;
			g.clear();

			// Main area
			
			g.beginFill(0, mouseIsOver ? 0.2 : 0);
			var off:int = _isCurrent ? 1 : 0;
			g.drawRect(off, off, __width - off*2, __height - off*2);
			g.endFill();
			
			// borders...
			
			if (_isCurrent || _isSelected)
			{
				g.lineStyle(2, _isSelected ? 0xff0000 : 0, 0.4, true, "normal", null, JointStyle.MITER);
				g.drawRect( 1, 1, __width - 2, __height - 2);
			}
			
			
		}
		
		
		public function set date(d:Date):void
		{
			_date = d;
			
			doLayout();
		}
		
		public function get date():Date
		{
			return _date;
		}
		
		public function set isCurrent(b:Boolean):void
		{
			_isCurrent = b;
			doLayout();
		}
		public function get isCurrent():Boolean
		{
			return _isCurrent;
		}
		
		public function set isOutOfMonth(b:Boolean):void
		{
			_isOutOfMonth = b;
			doLayout();
		}
		public function get isOutOfMonth():Boolean
		{
			return _isOutOfMonth;
		}
		
		public function set isSelected(b:Boolean):void
		{
			_isSelected = b;
			doLayout();
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		public function set owner(calendar:Calendar):void
		{
			_owner = calendar;
		}
		
		public function get owner():Calendar
		{
			return _owner;
		}
		
		public function set events(arr:Array):void
		{
			hasEvents = (arr && arr.length > 0);
			_events = arr;
			doLayout();
		}
		
		public function get events():Array
		{
			return _events;
		}
		
		override protected function _onRollOver():void
		{
			mouseIsOver = true;
			doLayout();
		}
		
		override protected function _onRollOut():void
		{
			mouseIsOver = false;
			doLayout();
		}
		
		override protected function _onReleaseOutside():void
		{
			_onRollOut();
		}
		
	}
	
}

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
	import flash.events.Event;
	
	import razor.controls.Button;
	import razor.controls.Calendar;
	import razor.controls.Label;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.utils.DateUtils;

	/**
	 * Default renderer for the header (ie, "November 2008") of a Calendar control.
	 * This renderer also incorporates left and right buttons for traversing through months.
	 */
	public class CalendarHeaderRenderer extends StyledContainer
		implements ICalendarRenderer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "HeaderRenderer"; }
		
		/** @private */ protected var _owner:Calendar;
		
		/** @private */ protected var label:Label;
		/** @private */ protected var leftArrow:Button;
		/** @private */ protected var rightArrow:Button;
		
		/** @private */ protected var _date:Date;
		
		public function CalendarHeaderRenderer() 
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			label = addBlueprint(Label) as Label;
			label.autoSize = "left";
			
			leftArrow = addBlueprint(Button) as Button;
			leftArrow.addIcon("Arrow");
			leftArrow.addEventListener(Button.E_CLICK, onLeftClick, false, 0, true);
			
			rightArrow = addBlueprint(Button) as Button;
			rightArrow.addIcon("Arrow");
			rightArrow.addEventListener(Button.E_CLICK, onRightClick, false, 0, true);
			
		}
		
		/** @private */
		override protected function layout():void
		{
			if (_date)
			{
				label.text = DateUtils.getMonth(_date) + " " + _date.getFullYear();
				if (label.width > __width - label.height*2)
					label.text = DateUtils.getShortMonth(_date) + " '" + _date.getFullYear().toString().substr(2);
			}
			label.move(Math.floor((__width - label.width) / 2), 0);
			var lh:Number = label.height;
			
			
			leftArrow.move(2, 0);
			leftArrow.setSize(lh,lh);
			leftArrow.icon.rotation = 180;
			
			rightArrow.move(__width - 2 - lh, 0);
			rightArrow.setSize(lh, lh);
			
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
		
		public function set owner(calendar:Calendar):void
		{
			_owner = calendar;
		}
		
		public function get owner():Calendar
		{
			return _owner;
		}
		
		/** @private */
		protected function onLeftClick(e:Event):void
		{
			var dd:Date = owner.displayDate;
			dd.month = dd.month == 0 ? 11 : dd.month - 1;
			if (dd.month == 11) dd.fullYear--;
			owner.displayDate = dd;
			owner.dispatchEvent(new Event(Calendar.E_MONTH_CHANGE));
		}
		
		/** @private */
		protected function onRightClick(e:Event):void
		{
			var dd:Date = owner.displayDate;
			dd.month = dd.month == 11 ? 0 : dd.month + 1;
			if (dd.month == 0) dd.fullYear++;
			owner.displayDate = dd;
			owner.dispatchEvent(new Event(Calendar.E_MONTH_CHANGE));
		}
	}
	
}

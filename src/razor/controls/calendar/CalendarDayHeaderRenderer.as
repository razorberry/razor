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
	import razor.controls.Calendar;
	import razor.controls.Label;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.utils.DateUtils;

	/**
	 * Default renderer for a day header (ie, "Wednesday") inside a Calendar control.
	 */
	public class CalendarDayHeaderRenderer extends StyledContainer
		implements ICalendarRenderer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "DayHeaderRenderer"; }
		
		/** @private */ protected var _owner:Calendar;
		
		/** @private */ protected var label:Label;
		/** @private */ protected var _date:Date;
		
		public function CalendarDayHeaderRenderer() 
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			label = addBlueprint(Label) as Label;
			label.autoSize = "left";
		}
		
		/** @private */
		override protected function layout():void
		{
			if (_date)
			{
				
				var useSize:int = 2;
				label.text = "Wednesday";
				if (label.width > __width - 4)
				{
					label.text = "Wed";
					useSize = 1;
				}
				if (label.width > __width - 4)
					label.text = DateUtils.getDay(_date).charAt(0);
				else
				if (useSize == 2)
					label.text = DateUtils.getDay(_date);
				else if (useSize == 1)
					label.text = DateUtils.getShortDay(_date);
				
			}
			label.move(Math.floor((__width - label.width) / 2), 0);
			
			__height = label.height;
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
	}
	
}

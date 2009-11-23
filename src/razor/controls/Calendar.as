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
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import razor.controls.calendar.*;
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.InteractiveContainer;
	import razor.core.Metrics;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Dispatched when a date is selected on the calendar.
	 * @eventType razor.controls.Calendar.E_SELECT
	 */
	[Event(name="select", type="flash.events.Event")]

	/**
	 * Displays a single month calendar with selectable dates.
	 * @example
	 * <listing version="3.0">
	 * package
	 * {
	 *     import razor.core.ControlFactory;
	 *     import razor.controls.Calendar;
	 *     import flash.events.Event;
	 * 
	 *     public class CalendarExample extends flash.display.Sprite
	 *     {
	 *         public function CalendarExample()
	 *         {
	 *             var myCal:Calendar = ControlFactory.create(Calendar) as Calendar;
	 *             myCal.setSize(300,200);
	 *             myCal.addEventListener(Calendar.E_SELECT, onDateChanged);
	 *             addChild(myCal);
	 *         }
	 * 
	 *         protected function onDateChanged(e:Event):void
	 *         {
	 *             var myCal:Calendar = e.target as Calendar;
	 *             trace(myCal.selectedDate);
	 *         }
	 *     }
	 * }
	 * </listing>
	 */
	public class Calendar extends StyledContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
		public static const E_MONTH_CHANGE:String = "e_monthChange";
		
		/** @private */ override protected function getClass():String { return "Calendar"; }
		
		protected var _headerRenderer:String = "HeaderRenderer";
		protected var _columnHeaderRenderer:String = "DayHeaderRenderer";
		protected var _dateRenderer:String = "DateRenderer";
		
		protected var _dataProvider:Array;
		
		protected var _displayDate:Date;
		protected var _currentDate:Date;
		protected var _selectedDate:Date;
		
		protected var background:DisplayObject;
		protected var header:ICalendarRenderer;
		
		protected var dates:Array;
		protected var days:Array;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/Set the current date, (ie. today)
		 * @param A Date instance representing the date you want to display as the current date.
		 * @default The current system date
		 */
		public function set currentDate(date:Date):void
		{
			_currentDate = date;
			
			update();
		}
		
		/** @private */
		public function get currentDate():Date
		{
			if (_currentDate == null) return new Date();
			
			return _currentDate;
		}
		
		/**
		 * Get/Set the date that is currently displayed on the calendar.
		 * The calendar will change month depending on the date you supply.
		 * @param A Date instance representing the date you want to display.
		 * @default The current system date
		 */
		public function set displayDate(date:Date):void
		{
			_displayDate = date;
			
			update();
		}
		
		/** @private */
		public function get displayDate():Date
		{
			if (_displayDate == null)
				return currentDate;
				
			return _displayDate;
		}
		
		/**
		 * Replace the header with your own implementation.
		 * This renderer will be instantiated from the StyleSheets
		 * @param	str	The selector of the header renderer to use.
		 * @default HeaderRenderer
		 */
		public function set headerRenderer(str:String):void
		{
			_headerRenderer = str;
			
			if (header && header is DisplayObject && contains(DisplayObject(header)))
				removeChild(DisplayObject(header));
				
			createHeader();
			update();
		}
		
		/** @private */
		public function get headerRenderer():String
		{
			return _headerRenderer;
		}
		
		/**
		 * Replace the day renderers with your own implementation.
		 * This renderers will be instantiated from the StyleSheets
		 * @param	str	The selector of the day renderer to use.
		 * @default DayHeaderRenderer
		 */
		public function set dayRenderer(str:String):void
		{
			_columnHeaderRenderer = str;
			
			for each (var dr:ICalendarRenderer in days)
			{
				if (dr)
				{
					//if (dr is IEventDispatcher)
					//{
						//IEventDispatcher(dr).removeEventListener(MouseEvent.CLICK, onDateClick);
						//IEventDispatcher(dr).removeEventListener(InteractiveContainer.E_CLICK, onDateClick);
					//}
					if (dr is Container)
						Container(dr).destroy();
					else if (dr is DisplayObject && contains(DisplayObject(dr)))
						removeChild(DisplayObject(dr));
				}
			}
			
			createDays();
			update();
		}
		
		/** @private */
		public function get dayRenderer():String
		{
			return _columnHeaderRenderer;
		}
		
		/**
		 * Replace the dates with your own implementation.
		 * This renderer will be instantiated from the StyleSheets
		 * @param	str	The selector of the daterenderer to use.
		 * @default DateRenderer
		 */
		public function set dateRenderer(str:String):void
		{
			_dateRenderer = str;
			
			for each (var dr:ICalendarDateRenderer in dates)
			{
				if (dr)
				{
					if (dr is IEventDispatcher)
					{
						IEventDispatcher(dr).removeEventListener(MouseEvent.CLICK, onDateClick);
						IEventDispatcher(dr).removeEventListener(InteractiveContainer.E_CLICK, onDateClick);
					}
					if (dr is Container)
						Container(dr).destroy();
					else if (dr is DisplayObject && contains(DisplayObject(dr)))
						removeChild(DisplayObject(dr));
				}
			}
			
			createDates();
			update();
		}
		
		/** @private */
		public function get dateRenderer():String
		{
			return _dateRenderer;
		}
		
		/**
		 * Set the data provider for this calendar.
		 * The data provider is an array of ICalendarEvent implementations to
		 * display on the calendar. In order to display events on the calendar,
		 * the date renderer needs to implement ICalendarEventRenderer
		 * @param arr	An array of calendar events
		 */
		public function set dataProvider(arr:Array):void
		{
			_dataProvider = arr;
			update();
		}
		
		/** @private */
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
		
		/**
		 * Get/Set the currently selected date.
		 * The date will show up as highlighted on the calendar.
		 * @param date	A Date instance representing the date to be highlighted.
		 * @default null (no selection)
		 */
		public function set selectedDate(date:Date):void
		{
			_selectedDate = date;
			update();
		}
		
		/** @private */
		public function get selectedDate():Date
		{
			return _selectedDate;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function Calendar() 
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			createHeader();
			
			createDays();
			
			createDates();
			
			update();
		}
		
		/** @private */
		override protected function layout():void
		{
			if (!(__width > 0 && __height > 0))
				return;
				
			sizeChild(background, __width, __height);
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			var yy:Number = m.t;
			
			var h:DisplayObject = header as DisplayObject;
			if (h)
			{
				h.width = __width - m.l - m.r;
				h.x = m.l;
				h.y = yy;
				
				yy += h.height;
			}
			
			var columnWidth:Number = (__width - m.l - m.r) / 7;
			var maxH:Number = 0;
			
			for (var day:int = 0; day < 7; day++)
			{
				var cc:DisplayObject = days[day] as DisplayObject;
				if (cc)
				{
					cc.width = Math.ceil(columnWidth);
					cc.x = Math.floor(m.l + columnWidth * day);
					cc.y = yy;
					maxH = Math.max(maxH, cc.height);
				}
			}
			
			yy += maxH;
			
			var rowHeight:Number = Math.floor((__height - yy - m.b) / 6);
			for (day = 0; day < 42; day++)
			{
				var c:DisplayObject = dates[day] as DisplayObject;
				if (c)
				{
					sizeChild(c, columnWidth, rowHeight);
					c.x = m.l + (day % 7 * columnWidth);
					c.y = yy;
				}
				if (day % 7 == 6) yy += rowHeight;
			}
		}
		
		/** @private */
		protected function update():void
		{
			if (header)
			header.date = displayDate;
			
			// Get start date:
			var startDate:Date = new Date(displayDate.time);
			startDate.date = 1;
			var diff:Number = startDate.day * 86400000 + (startDate.day < 4 ? 86400000*7: 0);
			startDate = new Date(startDate.getTime() - diff);
			
			var startDate2:Date = new Date(startDate.time);
			
			for (var day:int = 0; day < 7; day++)
			{
				var c:ICalendarRenderer = days[day] as ICalendarRenderer;
				if (c)
				c.date = new Date(startDate2.time);
				startDate2.date += 1; //time += 86400000;
			}
			
			// Gather all events in this month.
			var events:Array = new Array();
			
			if (_dataProvider)
			{
				for (var i:int = 0; i < _dataProvider.length; i++)
				{
					var e:ICalendarEvent = _dataProvider[i] as ICalendarEvent;
					
					if (e && e.date && e.date.month == displayDate.month && e.date.fullYear == displayDate.fullYear)
					events.push(e);
				}
			}
			
			for (day = 0; day < 42; day++)
			{
				var d:ICalendarDateRenderer = dates[day] as ICalendarDateRenderer;
				
				// If date renderer can render events, then gather events that fall on this day and apply them.
				if (dates[day] is ICalendarEventRenderer)
				{
					var currentEvents:Array = new Array();
					
					for each (var event:ICalendarEvent in events)
						if (startDate.date == event.date.date && startDate.month == event.date.month)
							currentEvents.push(event);
							
					ICalendarEventRenderer(dates[day]).events = currentEvents;
				}
				
				updateDateRenderer(d, new Date(startDate.time), displayDate, currentDate);
				
				//startDate.time += 86400000;
				startDate.date += 1;
			}
			
			doLayout();
		}
		
		/** @private */
		protected function updateDateRenderer(renderer:ICalendarDateRenderer, date:Date, displayDate:Date, today:Date):void
		{
			if (renderer)
			{
				renderer.date = date;
				
				renderer.isOutOfMonth = (date.month != displayDate.month);
				renderer.isSelected = (selectedDate != null && date.date == selectedDate.date && date.month == selectedDate.month && date.fullYear == selectedDate.fullYear);
				renderer.isCurrent = (date.date == today.date && date.month == today.month && date.fullYear == today.fullYear);
			}
		}
		
		/** @private */
		protected function createHeader():void
		{
			//trace("Calendar: creating header: " +_headerRenderer);
			header = addBlueprint(_headerRenderer) as ICalendarRenderer;
			//trace(flash.utils.getQualifiedClassName(header));
			if (header)
			header.owner = this;
		}
		
		/** @private */
		protected function createDays():void
		{
			days = new Array();
			for (var day:int = 0; day < 7; day++)
			{
				var newheader:ICalendarRenderer = addBlueprint(_columnHeaderRenderer) as ICalendarRenderer;
				if (newheader)
				newheader.owner = this;
				days.push(newheader);
			}
		}
		
		/** @private */
		protected function createDates():void
		{
			dates = new Array();
			for (var i:int = 0; i < 42; i++)
			{
				var newdate:ICalendarDateRenderer = addBlueprint(_dateRenderer) as ICalendarDateRenderer;
				if (newdate)
				newdate.owner = this;
				
				if (newdate is IEventDispatcher)
				{
					if (newdate is InteractiveContainer)
						InteractiveContainer(newdate).addEventListener(InteractiveContainer.E_CLICK, onDateClick, false, 0, true);
					else
						IEventDispatcher(newdate).addEventListener(MouseEvent.CLICK, onDateClick, false, 0, true);
				}
					
				dates.push(newdate);
			}
		}
		
		/** @private */
		protected function onDateClick(e:Event):void
		{
			selectedDate = ICalendarDateRenderer(e.target).date;
			dispatchEvent(new Event(E_SELECT));
		}
		
		/** @inheritDoc */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(160, 140);
		}
	}
	
}

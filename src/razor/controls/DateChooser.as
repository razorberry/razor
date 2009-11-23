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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.layout.ModalLayer;
	import razor.skins.Settings;
	import razor.skins.StyleSheet;
	import razor.utils.DateUtils;
	
	/**
	 * Dispatched when a date is selected.
	 * You can get the currently selected date with selectedDate
	 * @see #selectedDate
	 * @eventType razor.controls.DateChooser.E_SELECT
	 */
	[Event(name="select", type="razor.core.RazorEvent")]
	
	/**
	 * A clickable date chooser that will pop up a calendar when clicked, then display the selected
	 * date in a text input.
	 * You can also define the format of the displayed date.
	 */
	public class DateChooser extends StyledContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
		
		public static const FORMAT_MMDDYY:String = "mmddyy";
		public static const FORMAT_DDMMYY:String = "ddmmyy";
		public static const FORMAT_MMDDYYYY:String = "mmddyyyy";
		public static const FORMAT_DDMMYYYY:String = "ddmmyyyy";
		
		/** @private */ override protected function getClass():String { return "DateChooser"; }
		
		/** @private */ protected var btn:Button;
		/** @private */ protected var input:TextInput;
		/** @private */ protected var calendar:Calendar;
		/** @private */ protected var format:String = FORMAT_MMDDYY;
		
		protected var _selectedDate:Date;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/Set the currently selected date displayed on both the text input and the popup
		 * calendar.
		 * @param	date	A Date instance representing the date to display
		 */
		public function set selectedDate(date:Date):void
		{
			_selectedDate = date;
			updateField();
		}
		
		/** @private */
		public function get selectedDate():Date
		{
			return _selectedDate;
		}
		
		/**
		 * Get/Set the current date format displayed in the text input.
		 * @param	format	One of the constants defined by FORMAT_*
		 * @default mmddyy
		 * @see #FORMAT_MMDDYY
		 * @see #FORMAT_DDMMYY
		 * @see #FORMAT_MMDDYYYY
		 * @see #FORMAT_DDMMYYYY
		 */
		public function set dateFormat(format:String):void
		{
			this.format = format;
			updateField();
		}
		
		/** @private */
		public function get dateFormat():String
		{
			return format;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function DateChooser()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			btn = addBlueprint("ToggleButton") as Button;
			if (btn)
			{
				var ss:StyleSheet = Settings.rootStyleSheet.findStyle(__styleChain.concat("Icon"))
				if (ss)
				btn.addIcon(ss.getBaseClass());
				btn.addEventListener(Button.E_CLICK, onClick);
			}
			input = addBlueprint(TextInput) as TextInput;
			input.editable = false;
			input.selectable = true;
		}
		
		/** @private */
		override protected function layout():void
		{
			if (btn)
			{
				btn.move(__width - __height, 0);
				btn.setSize(__height, __height);
			}
			
			input.setSize(__width - __height, __height);
			
			if (calendar)
			{
				//var p:Point = new Point(0, __height);
				//var np:Point = ModalLayer.getInstance().globalToLocal(localToGlobal(p));
				var np:Point = ModalLayer.getInstance().getNearestPopPoint(calendar, btn);
				var m:Metrics = calendar.getPreferredMetrics();
				calendar.setSize(m.width, m.height);
				calendar.move(np.x, np.y);
			}
		}
		
		/** @private */
		protected function updateField():void
		{
			if (_selectedDate == null)
				input.text = "";
			else
			{
				switch (format)
				{
					default:
					case FORMAT_MMDDYY:
						input.text = DateUtils.getMMDDYY(_selectedDate);
						break;
					case FORMAT_DDMMYY:
						input.text = DateUtils.getDDMMYY(_selectedDate);
						break;
					case FORMAT_MMDDYYYY:
						input.text = DateUtils.getMMDDYYYY(_selectedDate);
						break;
					case FORMAT_DDMMYYYY:
						input.text = DateUtils.getDDMMYYYY(_selectedDate);
						break;
				}
			}
				
		}
		
		/** @private */
		protected function onClick(e:Event):void
		{
			togglePopup(!(calendar));
		}
		
		/** @private */
		protected function onStageMouseDown(e:MouseEvent = null):void
		{
			var ml:ModalLayer = ModalLayer.getInstance();
			var p:Point = stage.localToGlobal(new Point(e.stageX, e.stageY));
			p = ml.globalToLocal(p);
			if ((mouseX < 0 || mouseX > __width || mouseY < 0 || mouseY > __height) && !calendar.hitTestPoint(p.x, p.y))
				togglePopup(false);
		}
		
		/**
		 * Create or hide the Calendar popup.
		 * @private
		 */
		private function togglePopup(open:Boolean):void
		{
			if (open && calendar == null)
			{
				calendar = ModalLayer.getInstance().addBlueprint(Calendar, {style: __style}) as Calendar;
				var m:Metrics = calendar.getPreferredMetrics();
				calendar.setSize(m.width, m.height);
				registerChild(calendar);
				if (_selectedDate)
					calendar.selectedDate = _selectedDate;
				calendar.addEventListener(Calendar.E_SELECT, closePopup);
				
				if (stage)
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				doLayout();
			}
			else
			{
				if (!open)
				{
					_selectedDate = calendar.selectedDate;
					updateField();
					if (stage)
						stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
					calendar.destroy();
					calendar = null;
					dispatchEvent(new RazorEvent(E_SELECT));
				}
				else
				{
					if (stage)
						stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				}
				
				doLayout();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			togglePopup(false);
			
			// calendar should be in our list of elements, so it will be destroyed on this next call:
			super.destroy();
		}
		
		/**
		 * Close the calendar popup.
		 */
		protected function closePopup(e:Event):void
		{
			togglePopup(false);
		}
		
		
	}
}
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

package razor.utils 
{
	// TODO: Class stub. Not finished
	/**
	 * Class containing a variety of date utility methods.
	 */
	public class DateUtils 
	{
		public static const months:Array =
			["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		public static const days:Array =
			["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		public static const suffixes:Array =
			["st", "nd", "rd", "th"];
			
		public function DateUtils() 
		{
			
		}
		
		public static function getMonth(d:Date):String
		{
			return months[d.getMonth()] ? months[d.getMonth()] : "";
		}
		
		public static function getDay(d:Date):String
		{
			return days[d.getDay()] ? days[d.getDay()] : "";
		}
		
		public static function getDate(d:Date):String
		{
			var suf:String = suffixes[(d.date % 10) - 1];
			return suf ? d.date.toString() + suf : d.date.toString() + suffixes[3];
		}
		
		public static function getShortMonth(d:Date):String
		{
			return getMonth(d).substring(0, 3);
		}
		
		public static function getShortDay(d:Date):String
		{
			return getDay(d).substring(0, 3);
		}
		
		public static function getFullDate(d:Date):String
		{
			return getDay(d) + " " + getDate(d) + " " + getMonth(d) + ", " + d.getFullYear().toString();
		}
		
		public static function getDDMMYY(d:Date, delimiter:String = "/"):String
		{
			var dd:String = d.getDate().toString();
			dd = (dd.length == 1 ? "0"+dd : dd);
			var mm:String = String(d.getMonth()+1);
			mm = (mm.length == 1 ? "0"+mm : mm);
			var yy:String = d.getFullYear().toString().substr(2);
			
			return dd+delimiter+mm+delimiter+yy;
		}
		
		public static function getMMDDYY(d:Date, delimiter:String = "/"):String
		{
			var dd:String = d.getDate().toString();
			dd = (dd.length == 1 ? "0"+dd : dd);
			var mm:String = String(d.getMonth()+1);
			mm = (mm.length == 1 ? "0"+mm : mm);
			var yy:String = d.getFullYear().toString().substr(2);
			
			return mm+delimiter+dd+delimiter+yy;
		}
		
		public static function getDDMMYYYY(d:Date, delimiter:String = "/"):String
		{
			var dd:String = d.getDate().toString();
			dd = (dd.length == 1 ? "0"+dd : dd);
			var mm:String = String(d.getMonth()+1);
			mm = (mm.length == 1 ? "0"+mm : mm);
			var yy:String = d.getFullYear().toString();
			
			return dd+delimiter+mm+delimiter+yy;
		}
		
		public static function getMMDDYYYY(d:Date, delimiter:String = "/"):String
		{
			var dd:String = d.getDate().toString();
			dd = (dd.length == 1 ? "0"+dd : dd);
			var mm:String = String(d.getMonth()+1);
			mm = (mm.length == 1 ? "0"+mm : mm);
			var yy:String = d.getFullYear().toString();
			
			return mm+delimiter+dd+delimiter+yy;
		}
	}
	
}

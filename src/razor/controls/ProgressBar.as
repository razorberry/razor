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
	
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.skins.Style;

	/**
	 * Class for a standard progress bar.
	 * @example
	 * <listing version="3.0">
	 * var progressBar:ProgressBar = addChild(new ProgressBar());
	 * progressBar.label = "%p% done.";
	 * progressBar.maximum = 32;
	 * progressBar.value = 6;
	 * </listing>
	 */
	public class ProgressBar extends StyledContainer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "ProgressBar"; }
		
		/** @private */ protected var _total:Number = 100;
		/** @private */ protected var _value:Number = 0;
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var overlay:DisplayObject;
		/** @private */ protected var bar:DisplayObject;
		/** @private */ protected var label_mc:Label;
		/** @private */ protected var label_str:String = "";
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/set the maximum real value of the progress bar.
		 * @param	n	The maximum numeric value
		 * @default 100
		 */
		public function set total(n:Number):void
		{
			_total = n;
			updateBar();
		}
		
		/** @private */
		public function get total():Number
		{
			return _total;
		}
		
		/**
		 * Set the current real value of the progress bar.
		 * @param	v	The current numeric value.
		 * @default 0
		 */
		public function set value(v:Number):void
		{
			_value = v;
			updateBar();
		}
		
		/** @private */
		public function get value():Number
		{
			return _value;
		}
		
		/**
		 * Get/set the current progress as a value between 0 and 1. 0=empty, 1=full.
		 * Warning: The bounds of this value are not checked.
		 * @param	n	The current progress as a number between 0 and 1.
		 * @default 0
		 */
		public function set progress(n:Number):void
		{
			value = _total * n;
		}
		
		/** @private */
		public function get progress():Number
		{
			return _value / _total;
		}
		
		/**
		* Get/set the current progress as a percentage.
		* Warning: The bounds of this value are not checked.
		* @param	n	The current progress as a percentage.
		*/
		public function set percent(n:Number):void
		{
			value = _total * n / 100;
		}
		
		/** @private */
		public function get percent():Number
		{
			return progress*100;
		}
		
		/**
		* Get/set the format of the label for the progress bar.
		* The following strings will be replaced by their respective values:
		* %p percent
		* %v value
		* %t total
		* @example
		* <listing version="3.0">progressBar.label = "%p percent, (%v out of %t)";</listing>
		*/
		public function set label(str:String):void
		{
			label_str = str;
		}
		
		/** @private */
		public function get label():String
		{
			return label_str;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function ProgressBar()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			bar = addBlueprint("Bar");
			label_mc = addBlueprint("Label") as Label;
			label_mc.selectable = false;
			overlay = addBlueprint("Overlay");
		}
		
		/** @private */
		override protected function layout():void
		{
			sizeChild(background, __width, __height);
			sizeChild(overlay, __width, __height);
			var s:Style = bar is StyledContainer ? StyledContainer(bar).style : null;
			var b:* = __style.bevel;
			
			//TODO: We shouldn't be doing any style related stuff here.
			if (s != null && __style.roundedness is Number)
			{
				s.roundedness = (__style.roundedness - b) as Number;
			}
			else if (s != null)
			{
				if (b is Number)
				{
					var r:Object = __style.roundedness as Object;
					r.tl -= b;
					r.tr -= b;
					r.bl -= b;
					r.br -= b;
				}
			}
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			if (s) s.bevel = (__height - m.t - m.b )/2;
			bar.x = m.l;
			bar.y = m.t;
			bar.height = __height - m.t - m.b;
			
			updateBar();
			
			label_mc.width = __width - m.l - __style.padding_l - m.r - __style.padding_r;
			label_mc.move(m.l + __style.padding_l, (__height - label_mc.textHeight) / 2 +__style.padding_t - 2);
		}
		
		/**
		 * Draw the bar depending on the values
		 * @private
		 */
		protected function updateBar():void
		{
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			bar.width = (__width - m.l - m.r) * Math.max(0,Math.min(1,progress));
			label_mc.text = getLabel();
			label_mc.move(m.l + __style.padding_l, (__height - label_mc.textHeight) / 2 +__style.padding_t - 2);
		}
		
		/**
		 * Get the actual formatted label text.
		 */
		protected function getLabel():String
		{
			var str:String = label_str;
			str = str.split("%p").join(String(Math.round(percent))).split("%v").join(String(value)).split("%t").join(String(total));
			return str;
		}
		
		/** @private */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,20);
		}
	}
}
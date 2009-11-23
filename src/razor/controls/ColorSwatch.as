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
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.razor_internal;
	import razor.layout.ModalLayer;
	
	/**
	 * Dispatched when the current color is changed.
	 * @eventType razor.controls.ColorSwatch.E_CHANGE
	 */
	[Event(name="change", type="razor.core.RazorEvent")]
	
	/**
	* A clickable color swatch that will pop up the color picker when clicked.
	* Will dispatch two types of event, E_CHANGE when the user is dragging the handles
	* in the color picker, and E_SET once the color picker is closed and the swatch is updated.
	* 
	* @example
	* <listing version="3.0">
	* var cs:ColorSwatch = addChild(new ColorSwatch());
	* cs.setSize(24,24);
	* cs.color = 0xffff00;
	* cs.addEventListener(ColorSwatch.E_CHANGE, onColorChange);
	* </listing>
	*/
	public class ColorSwatch extends Button
	{
		use namespace razor_internal;
		
		public static const E_CHANGE:String = ColorPicker.E_CHANGE;
		
		/** @private */ override protected function getClass():String { return "ColorSwatch"; }
		
		/** @private */ protected var background:DisplayObject;
		/** @private */ protected var overlay:DisplayObject;
		/** @private */ protected var swatch:Container;
		/** @private */ protected var picker:ColorPicker;
		
		protected var _color:uint = 0xFF0000;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Get/set the current color, setting this will update the visual representation.
		* @param	v	The color value
		*/
		public function set color(v:uint):void
		{
			_color = v;
			if (picker)
				picker.color = _color;
			layout();
		}
		
		/** @private */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		* Get/set the current color using a hex string of the form: "rrggbb".
		* Also handles "#" and "0x" as prefixes.
		* @param	str		The color string to set.
		*/
		public function set hex(str:String):void
		{
			var numStr:String = str.split("#").join("").split("0x").join("");
			var num:Number = parseInt(numStr, 16);
			if (!isNaN(num))
				color = num;
		}
		
		/** @private */
		public function get hex():String
		{
			var _b:uint = (_color & 0xff);
			var _g:uint = (_color & 0xff00) >> 8;
			var _r:uint = (_color & 0xff0000) >> 16;
			return (_r<16?"0":"")+_r.toString(16)+(_g<16?"0":"")+_g.toString(16)+(_b<16?"0":"")+_b.toString(16);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function ColorSwatch()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			super.construct();
			
			swatch = addBlueprint(Container, null, 48) as Container;
		}
		
		/** @private */
		override protected function layout():void
		{
			super.layout();
			
			var bg:DisplayObject = getStateElement("Background");
			var m:Metrics = (bg is IBordered) ? IBordered(bg).getBorderMetrics() : new Metrics();
			
			if (swatch)
			{
				var g:Graphics = swatch.graphics;
				g.clear();
				g.beginFill(_color,1);
				g.moveTo(m.l + 1, m.t + 1);
				g.lineTo(__width - m.r - 1, m.t + 1);
				g.lineTo(__width - m.r - 1, __height - m.b - 1);
				g.lineTo(m.l + 1, __height - m.b - 1);
				g.endFill();
			}
			
			if (picker && picker.visible)
			{
				//var p:Point = new Point(0, __height);
				//var np:Point = ModalLayer.getInstance().globalToLocal(localToGlobal(p));
				var np:Point = ModalLayer.getInstance().getNearestPopPoint(picker, this);
				picker.move(np.x, np.y);
			}
		}
		
		/** @private */
		override protected function _onRelease():void
		{
			togglePopup(!(picker && picker.visible));
			super._onRelease();
		}
		
		/** @private */
		protected function onMouseDown(e:MouseEvent = null):void
		{
			var ml:ModalLayer = ModalLayer.getInstance();
			if ((mouseX < 0 || mouseX > __width || mouseY < 0 || mouseY > __height) && !picker.hitTestPoint(ml.mouseX, ml.mouseY))
				togglePopup(false);
		}
		
		/**
		 * Create or hide the ColorPicker popup.
		 * @private
		 */
		private function togglePopup(open:Boolean):void
		{
			if (open && picker == null)
			{
				picker = ModalLayer.getInstance().addBlueprint(ColorPicker, {style: __style}) as ColorPicker;
				var m:Metrics = picker.getPreferredMetrics();
				picker.setSize(m.width, m.height);
				registerChild(picker);
				if (_color)
					picker.color = _color;
				//picker.addEventListener(ColorPicker.E_CLICK, closePopup);
				//bubbleEvent(picker, ColorPicker.E_CHANGE);
				
				if (stage)
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				doLayout();
			}
			else
			{
				picker.visible = open;
				if (!open)
				{
					_color = picker.color;
					if (stage)
						stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					dispatchEvent(new RazorEvent(E_CHANGE, {color: _color, hex: hex}));
				}
				else
				{
					if (stage)
						stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				
				doLayout();
			}
		}
		
		protected function closePopup(e:Event = null):void
		{
			togglePopup(false);
		}
	}
}
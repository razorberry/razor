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
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.InteractiveContainer;
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.utils.ColorUtils;

	/**
	 * Dispatched when the current color is changed.
	 * @eventType razor.controls.ColorPicker.E_CHANGE
	 */
	[Event(name="change", type="razor.core.RazorEvent")]
	
	/**
	* An HSL (Hue-Saturation-Lightness) color picker component.
	* You can either use this component standalone, or with the ColorSwatch control,
	* which automatically handles popping up the color picker when clicked on.
	* 
	* The color picker will translate positions of the clickable handles into RGB values,
	* or conversely, will translate RGB values into HSL values and move the handles programatically.
	* 
	* @example
	* <listing version="3.0">
	* var cp:ColorPicker = addChild(new ColorPicker());
	* cp.color = 0xffff00;
	* cp.addEventListener(ColorPicker.E_CHANGE, onColorChange);
	* trace(cp.hex);
	* </listing>
	*/
	public class ColorPicker extends StyledContainer
	{
		use namespace razor_internal;
		
		public static const E_CHANGE:String = Event.CHANGE;
		
		/** @private */ override protected function getClass():String { return "ColorPicker"; }
		
		/** @private */ protected var _hue:uint;			// Color
		/** @private */ protected var _saturation:Number;		// Scalar, 0-1
		/** @private */ protected var _lightness:Number;			// Scalar, 0-1
		/** @private */ protected var _saturatedHue:uint;	// Color
		/** @private */ protected var _color:uint = 0xff0000;			// Color
		/** @private */ protected var _r:uint = 0xff;
		/** @private */ protected var _g:uint = 0;
		/** @private */ protected var _b:uint = 0;
		
		private var background:DisplayObject;
		private var colorContainer:Container;
		private var saturationContainer:InteractiveContainer;
		private var lightnessContainer:InteractiveContainer;
		private var swatch:InteractiveContainer;
		
		private var overlay:DisplayObject;
		
		private var handle:InteractiveContainer;
		private var handle2:InteractiveContainer;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		[Inspectable(name="Color", type=Color, defaultValue="#FF0000")]
		/**
		* Get/Set the current color. Setting this will update the visual representation.
		* @param	v	The color value
		*/
		public function set color(v:uint):void
		{
			if (!isNaN(v))
				_color = v;
			updateFromColor();
		}
		
		/** @private */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		* Get/Set the current color using a hex string of the form: "rrggbb".
		* Also handles "#" and "0x" as prefixes.
		* @param	str		The color string to set.
		*/
		public function set hex(str:String):void
		{
			var numStr:String = str.split("#").join("").split("0x").join("");
			var num:Number = parseInt(numStr, 16);
			if (!isNaN(num))
				color = uint(num);
		}
		
		/** @private */
		public function get hex():String
		{
			return (_r<16?"0":"")+_r.toString(16)+(_g<16?"0":"")+_g.toString(16)+(_b<16?"0":"")+_b.toString(16);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function ColorPicker()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{
			background = addBlueprint("Background");
			
			colorContainer = addBlueprint(Container) as Container;
			saturationContainer = addBlueprint(InteractiveContainer) as InteractiveContainer;
			
			saturationContainer.addEventListener(InteractiveContainer.E_PRESS, onMainHandlePress);
			saturationContainer.addEventListener(InteractiveContainer.E_RELEASE, onMainHandleRelease);
			saturationContainer.addEventListener(InteractiveContainer.E_RELEASE_OUTSIDE, onMainHandleRelease);
			
			lightnessContainer = addBlueprint(InteractiveContainer) as InteractiveContainer;
			
			lightnessContainer.addEventListener(InteractiveContainer.E_PRESS, onSecondHandlePress);
			lightnessContainer.addEventListener(InteractiveContainer.E_RELEASE, onMainHandleRelease);
			lightnessContainer.addEventListener(InteractiveContainer.E_RELEASE_OUTSIDE, onMainHandleRelease);
			
			swatch = addBlueprint(InteractiveContainer) as InteractiveContainer;
			//bubbleEvent(swatch, InteractiveContainer.E_CLICK);
			
			handle = addBlueprint(InteractiveContainer) as InteractiveContainer;
			
			handle.addEventListener(InteractiveContainer.E_PRESS, onMainHandlePress);
			handle.addEventListener(InteractiveContainer.E_RELEASE, onMainHandleRelease);
			handle.addEventListener(InteractiveContainer.E_RELEASE_OUTSIDE, onMainHandleRelease);
			
			handle2 = addBlueprint(InteractiveContainer) as InteractiveContainer;
			
			handle2.addEventListener(InteractiveContainer.E_PRESS, onSecondHandlePress);
			handle2.addEventListener(InteractiveContainer.E_RELEASE, onMainHandleRelease);
			handle2.addEventListener(InteractiveContainer.E_RELEASE_OUTSIDE, onMainHandleRelease);
			
			overlay = addBlueprint("Overlay");
		}
		
		/** @private */
		override protected function layout():void
		{
			sizeChild(background, __width, __height);
			
			var m:Metrics = (background is IBordered) ? IBordered(background).getBorderMetrics() : new Metrics();
			
			drawColorGamut(__width - 26 - m.l - m.r, __height - 20 - m.t - m.b);
			colorContainer.move(m.l, m.t);
			drawSaturationOverlay(__width - 26 - m.l - m.r, __height - 20 - m.t - m.b);
			saturationContainer.move(m.l, m.t);
			drawLightnessContainer(24, __height - 20 - m.t - m.b);
			lightnessContainer.move(__width - 24 - m.r, m.t);
			drawSwatch(__width - m.l - m.r, 18);
			swatch.move(m.l, __height - 18 - m.b);
			
			// Draw handles:
			drawHandle(handle, 4, 4);
			handle.move(m.l, m.t);
			drawHandle(handle2, lightnessContainer.width + 4, 4);
			handle2.move(lightnessContainer.x + lightnessContainer.width/2, Math.floor(lightnessContainer.y) + lightnessContainer.height/2);
			
			sizeChild(overlay, __width, __height);
			
			updateFromPosition(null, true);
		}
		
		private function onMainHandlePress(e:Event):void
		{
			handle.move(mouseX,mouseY);
			handle.startDrag(true, new Rectangle(colorContainer.x, colorContainer.y,
								   colorContainer.width, colorContainer.height));
			addEventListener(MouseEvent.MOUSE_MOVE, updateFromPosition);
			updateFromPosition();
		}
		
		private function onSecondHandlePress(e:Event):void
		{
			handle2.move(handle2.x, mouseY);
			handle2.startDrag(true, new Rectangle(lightnessContainer.x + lightnessContainer.width / 2, lightnessContainer.y,
									0, lightnessContainer.height));
			addEventListener(MouseEvent.MOUSE_MOVE, updateFromPosition);
			updateFromPosition();
		}
		
		private function onMainHandleRelease(e:Event):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, updateFromPosition);
			handle.stopDrag();
			handle2.stopDrag();
		}
		
		/**
		 * Update the internal color values from the position of the handles. 
		 * @private
		 */
		protected function updateFromPosition(e:MouseEvent = null, isInternal:Boolean = false):void
		{
			_hue = translateHue((handle.x - Math.floor(colorContainer.x)) / colorContainer.width);
			_saturation = 1-((handle.y - Math.floor(colorContainer.y)) / colorContainer.height);
			calculateSaturatedHue();
			if (handle2.y - Math.floor(lightnessContainer.y) < lightnessContainer.height/2)
			{
				_color = ColorUtils.blend(0xffffff,_saturatedHue, (handle2.y - Math.floor(lightnessContainer.y))/(lightnessContainer.height/2))
			}
			else
			{
				_color = ColorUtils.blend(_saturatedHue,0, (handle2.y - lightnessContainer.height/2 - Math.floor(lightnessContainer.y))/(lightnessContainer.height/2));
			}
			calculateRGB();
			drawLightnessContainer(lightnessContainer.width, lightnessContainer.height);
			drawSwatch(swatch.width, swatch.height);
			
			if (isInternal == false)
				dispatchEvent(new RazorEvent(E_CHANGE, {color: _color, hex: hex}));
		}
		
		/**
		 * Update the position of the handles from the color value.
		 * @private
		 */
		protected function updateFromColor():void
		{
			calculateRGB();
			
			// Calculate HSL values!
			var rr:Number = _r / 0xFF;
			var gg:Number = _g / 0xFF;
			var bb:Number = _b / 0xFF;
			var max:Number = Math.max(bb, Math.max(rr,gg));
			var min:Number = Math.min(bb, Math.min(rr,gg));
			
			var h:Number;
			var s:Number;
			var l:Number;
			
			// Calculate Hue (in degrees)
			if (max == min)
				h = 0;
			else if (max == rr)
			{
				h = 60 * ((gg - bb)/(max - min)) + (gg < bb ? 360 : 0);
			}
			else if (max == gg)
			{
				h = 60 * ((bb - rr)/(max - min)) + 120;
			}
			else
			{
				h = 60 * ((rr - gg)/(max - min)) + 240;
			}
			// Restrict 0 <= hue < 360
			while (h < 0)
				h += 360;
			while (h >= 360)
				h -= 360;
			
			// Calculate Lightness
			l = (max + min)/2;
			
			// Calculate Saturation
			if (l == 0 || max == min)
				s = 0;
			else if (l <= 0.5)
				s = (max - min)/(2*l);
			else
				s = (max - min)/(2-2*l);
				
			// trace("HSL: "+h+","+s+","+l);
			// position handles accordingly
			handle.x = (h/360 * colorContainer.width) + Math.floor(colorContainer.x);
			handle.y = ((1-s) * colorContainer.height) + Math.floor(colorContainer.y);
			
			handle2.y = (1-l) * lightnessContainer.height + Math.floor(lightnessContainer.y);
			
			_hue = translateHue(h/360);
			_saturation = s;
			calculateSaturatedHue();
			
			drawLightnessContainer(lightnessContainer.width, lightnessContainer.height);
			drawSwatch(swatch.width, swatch.height);
		}
		
		/**
		 * Draw the color gamut gradient.
		 * @private
		 */
		protected function drawColorGamut(sw:Number, sh:Number):void
		{
			var g:Graphics = colorContainer.graphics;
			colorContainer.setSize(sw,sh);
			g.clear();
			if (sw > 0 && sh > 0)
			{
				var colors:Array = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000];
				var alphas:Array = [1,1,1,1,1,1,1];
				var ratios:Array = [0,42,85,127,170,212,255];
				//var matrix:Object = { matrixType: "box", x: 0, y: 0, w: sw, h: sh, r: 0};
				var matr:Matrix = new Matrix();
				matr.createGradientBox(sw,sh);
				g.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matr);
				g.lineStyle(0,0,0);
				g.drawRect(0,0,sw,sh);
				g.endFill();
			}
		}
		
		/** 
		 * Overlay a saturation gradient on top of the color gamut.
		 * @private
		 */
		protected function drawSaturationOverlay(sw:Number, sh:Number):void
		{
			var g:Graphics = saturationContainer.graphics;
			saturationContainer.setSize(sw,sh);
			g.clear();
			if (sw > 0 && sh > 0)
			{
				var colors:Array = [0x7F7F7F, 0x7F7F7F];
				var alphas:Array = [0,1];
				var ratios:Array = [0,255];
				//var matrix:Object = { matrixType: "box", x: 0, y: 0, w: sw, h: sh, r: Math.PI/2};
				var matr:Matrix = new Matrix();
				matr.createGradientBox(sw,sh, Math.PI/2);
				g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
				g.lineStyle(0,0,0);
				g.drawRect(0,0,sw,sh);
				g.endFill();
			}
		}
		
		/**
		 * Draw the lightness bar. This will change color depending on the H/S values.
		 * @private
		 */
		protected function drawLightnessContainer(sw:Number, sh:Number, horizontal:Boolean = false):void
		{
			var g:Graphics = lightnessContainer.graphics;
			lightnessContainer.setSize(sw,sh);
			g.clear();
			var colors:Array = [0xFFFFFF, _saturatedHue, 0x000000];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,127,255];
			//var matrix:Object = { matrixType: "box", x: 0, y: 0, w: sw, h: sh, r: horizontal ? 0 : Math.PI/2 };
			var matr:Matrix = new Matrix();
			matr.createGradientBox(sw,sh,horizontal ? 0 : Math.PI/2,0,0);
			g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
			g.lineStyle(0,0,0);
			g.drawRect(0,0,sw,sh);
			g.endFill();
		}
		
		/**
		 * Draw the current-color swatch below the controls.
		 * @private
		 */
		protected function drawSwatch(sw:Number, sh:Number):void
		{
			var g:Graphics = swatch.graphics;
			swatch.setSize(sw, sh);
			g.clear();
			if (sw > 0 && sh > 0)
			{
				g.beginFill(_color, 1);
				g.drawRect(0,0,sw,sh);
				g.endFill();
			}
		}
		
		/**
		 * Draw a handle graphic.
		 * TODO: Does this need to be skinnable?
		 * @private
		 */
		protected function drawHandle(c:Container, w:Number, h:Number):void
		{
			var g:Graphics = c.graphics;
			g.clear();
			g.beginFill(0,0);
			g.drawRect(w/2 - 2, h/2 - 2, 4, 4);
			g.endFill();
			g.lineStyle(1,0,1);
			g.drawRect(-w/2,-h/2,w,h);
		}
		
		/**
		 * Convert a scalar value (0-1) (X-position on the color gamut) into a hue.
		 * @private
		 */
		protected function translateHue(v:Number):uint
		{
			var r:Number = 0; var g:Number = 0; var b:Number = 0;
			if (v <= 1/6) {
				r = 255;
				g = ColorUtils.blend(0,255,v*6);
				b = 0;
			}
			else if (v <= 2/6) {
				r = ColorUtils.blend(255,0,v*6-1);
				g = 255;
				b = 0;
			}
			else if (v <= 3/6) {
				r = 0;
				g = 255;
				b = ColorUtils.blend(0,255,(v*6 - 2));
			}
			else if (v <= 4/6) {
				r = 0;
				g = ColorUtils.blend(255,0,(v*6 - 3));
				b = 255;
			}
			else if (v <= 5/6) {
				r = ColorUtils.blend(0,255,(v*6 - 4));
				g = 0;
				b = 255;
			}
			else if (v <= 1) {
				r = 255;
				g = 0;
				b = ColorUtils.blend(255,0,(v*6 - 5));
			}
			
			return uint((b) | (g<<8) | (r<<16));
		}
		
		/**
		 * Blend the saturation value with the current hue.
		 * @private
		 */
		protected function calculateSaturatedHue():void
		{
			_saturatedHue = ColorUtils.blend(_hue, 0x7f7f7f, 1-_saturation);
		}
		
		/**
		 * Calculate the RGB values from the current color.
		 * @private
		 */
		protected function calculateRGB():void
		{
			_b = (_color & 0xff);
			_g = (_color & 0xff00) >> 8;
			_r = (_color & 0xff0000) >> 16;
		}
		
		
		
		/** @private */
		override public function getPreferredMetrics():Metrics
		{
			return new Metrics(120,120);
		}
	}
}
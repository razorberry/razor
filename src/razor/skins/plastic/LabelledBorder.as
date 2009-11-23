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

package razor.skins.plastic
{
	import flash.display.Graphics;
	import flash.text.TextFieldAutoSize;
	
	import razor.controls.Label;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.razor_internal;
	import razor.skins.RenderLayer;
	import razor.utils.ColorUtils;

	/**
	 * Class for a labelled border.. used in the Pane container, but can be used
	 * elsewhere.
	 * @private
	 */
	public class LabelledBorder extends RenderLayer
		implements IBordered
	{
		use namespace razor_internal;
		
		private var label_mc:Label;
		
		public function LabelledBorder()
		{
			
		}
		
		override protected function layout():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			
			if (isNaN(__width) || isNaN(__height)) return;
			
			if (__style.opacity <= 0) return;
			
			var tw:Number = label_mc && label_mc.textWidth ? label_mc.textWidth + 4 : 0;
			if (label_mc) label_mc.move((__width - tw)/2, 0);
			
			var hicol:Number = ColorUtils.fade(__style.border, 0.8);
			var bt:Number = __style.borderThickness > 0 ? __style.borderThickness : 1;
			var y:Number = label_mc ? label_mc.textHeight/2 +2 : 2;
			g.beginFill(__style.border,1);
			// topleft
			drawSimpleRect(0,y - bt,(__width - tw)/2 - 5,y);
			g.endFill();
			g.beginFill(__style.border,1);
			// topright
			drawSimpleRect((__width + tw)/2 + 5,y - bt, __width,y);
			g.endFill();
			g.beginFill(__style.border,1);
			// left
			drawSimpleRect(0,y - bt,bt,__height);
			g.endFill();
			g.beginFill(__style.border,1);
			// right
			drawSimpleRect((__width - 2*bt), y - bt, __width - bt, __height);
			g.endFill();
			g.beginFill(__style.border,1);
			// bottom
			drawSimpleRect(bt, __height - 2*bt, __width - bt, __height - bt);
			g.endFill();
			
			g.beginFill(hicol,1);
			// topleft
			drawSimpleRect(bt,y,(__width - tw)/2 - 5,y+bt);
			g.endFill();
			g.beginFill(hicol,1);
			// topright
			drawSimpleRect((__width + tw)/2 + 5,y, __width-bt,y+bt);
			g.endFill();
			g.beginFill(hicol,1);
			// left
			drawSimpleRect(bt,y+bt,bt*2,__height);
			g.endFill();
			g.beginFill(hicol,1);
			// right
			drawSimpleRect((__width - bt), y, __width, __height);
			g.endFill();
			g.beginFill(hicol,1);
			// bottom
			drawSimpleRect(bt*2, __height - bt, __width, __height);
			g.endFill();
		}
		
		override public function getBorderMetrics():Metrics
		{
			var o:Metrics = new Metrics(0,0,10,10,label_mc ? label_mc.textHeight + 2 : 2,10);
			return o;
		}
		
		public function set label(str:String):void
		{
			if (label_mc == null)
				label_mc = addBlueprint(Label) as Label;
			label_mc.selectable = false;
			label_mc.wordWrap = false;
			label_mc.autoSize = TextFieldAutoSize.LEFT;
			label_mc.text = str;
			doLayout();
		}
		
		public function get label():String
		{
			return label_mc.text;
		}
	}
}
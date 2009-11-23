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

package razor.layout.types
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import razor.core.Container;
	import razor.core.Metrics;
	import razor.layout.Layer;
	import razor.layout.LayoutData;
	
	/**
	 * Class for a row-based Layout implementation.
	 * Used by Layer to automatically layout containers.
	 * @see Layer
	 */
	public class RowBasedLayout
		implements ILayoutImpl
	{
		/** @private */ protected var __width:Number;
		/** @private */ protected var __height:Number;
		/** The total visible width after the content has been positioned. */
		public var visibleWidth:Number = 0;
		/** The total visible height after the content has been positioned. */
		public var visibleHeight:Number = 0;
		
		/**
		 * Takes an array of objects of type {container:Container, layout:LayoutData}
		 * and sizes and arranges the containers accordingly.
		 * @param	data	The array of containers and their associated LayoutDatas
		 * @param	width	The available width
		 * @param	height	The available height
		 * @param	margins	A metrics object that contains l/r/t/b margins.
		 */
		public function doLayout(children:Array, layoutDatas:Dictionary, width:Number, height:Number, margins:Metrics = null):void
		{
			__width = width;
			__height = height;
			
			var layout:LayoutData;
			if (layoutDatas == null)
				layoutDatas = new Dictionary();
			var dummyLayout:LayoutData = new LayoutData(LayoutData.POS_BELOW);
			
			if (margins == null)
				margins = new Metrics();
			
			var n:int = children.length;
			var x:Number = margins.l;
			var y:Number = margins.t;
			visibleWidth = 0;
			visibleHeight = 0;
			// Group data into rows
			var a:Array = new Array();
			a.push(new Array());
			var k:uint = 0;
			for (var j:uint = 0; j < n; j++)
			{
				layout = layoutDatas[children[j]];
				if (layout && layout.position == LayoutData.POS_RIGHT)
				{
					a[k].push(children[j]);
				}
				else
				{
					a.push(new Array());
					k++;
					a[k].push(children[j]);
				}
			}
			
			n = a.length;
			for (var i:uint = 0; i < n; i++)
			{
				var row:Array = a[i];
				
				///////////////////////////////////////////////////////////////
				/////// CALCULATE ROW WIDTH/AVAILABLE WIDTH:
				
				var aw:Number = __width - margins.l - margins.r; // available width after fixed width components
				var tw:Number = aw; // total width without any components
				var rw:Number = 0; // total width of all components
				var unknowns:uint = 0; // number of components that we're gonna have to size ourselves
				var rowAlign:String = LayoutData.ALIGN_LEFT;  // overall align of the row
				var preferredWidths:Dictionary = new Dictionary(true);
				
				for each(var z:DisplayObject in row)
				{
					layout = layoutDatas[z];
					
					if (!layout)
						layout = dummyLayout;
					
					// Align the row.. center takes precedence over right over left.
					if (layout.hAlign == LayoutData.ALIGN_CENTER) rowAlign = layout.hAlign;
					if (layout.hAlign == LayoutData.ALIGN_RIGHT && rowAlign != LayoutData.ALIGN_CENTER) rowAlign = layout.hAlign;
					var preferred:Number = z is Container ? Container(z).getPreferredMetrics().width : 0;
					// If component's preferred width is greater than the available width, ignore it.
					if (preferred > aw - rw - layout.padding_l - layout.padding_r)
						preferred = 0;
						
					if (preferred > 0)
						preferredWidths[z] = preferred;
					
					rw += ((layout.width > 0 && layout.widthType != LayoutData.TYPE_PERCENT) ? layout.width : preferred) + layout.padding_l + layout.padding_r;
					if (layout.widthType == LayoutData.TYPE_PERCENT || !(layout.width > 0))
						unknowns++;
				}
				
				aw -= rw;
				var uw:Number = aw; // unused available width
				var u:uint = unknowns; // unknown components that we havent sized yet
				
				var maxY:Number = 0;
				var baseX:Number = x;
				var baseY:Number = y;
				var d:DisplayObject;
				var c:Container;
				var l:LayoutData;
				/////////////////////////////////////////////////////////////
				/////// SIZING IN ROW:
				for (var m:uint = 0; m < row.length; m++)
				{
					d = row[m];
					c = d as Container;
					l = layoutDatas[row[m]];
					
					if (!l) l = dummyLayout;
					
					// TODO: Percentage and distribution over Y axis
					// TODO: Set Y below sub-Layers
					var w:Number;
					if (l.width > 0 && (l.width != 100 || l.widthType != LayoutData.TYPE_PERCENT))
					{
						w = (l.widthType == LayoutData.TYPE_PERCENT) ? 
							Math.min(uw, Math.max(aw*l.width/100, (tw * l.width / unknowns / 100))) :
							l.width;
					}
					else if (preferredWidths[d] > 0)
						w = 0;
					else 
						w = uw / u;
					
					uw -= w;
					rw += w;
					
					u -= (l.widthType == LayoutData.TYPE_PERCENT || l.width <= 0) ? 1 : 0;
					
					if (c is Layer)
						(c as Layer).width = w;
						
					var h:Number = l.height > 0 ? l.height : (c is Layer ? (c as Layer).height : ( c ? c.getPreferredMetrics().height: d.height));
					maxY = Math.max(maxY, l.padding_t + h + l.padding_b);
					//debug(c.toString()+"  "+w+","+h);
					if (c && !(c is Layer))
						c.setSize(w, h);
					else if (c == null)
					{
						d.width = w;
						d.height = h;
					}

					// TODO: y pos depending on vertical align
				}
				
				//////////////////////////////////////////////////////////////
				/////// POSITIONING IN ROW:
				
				if (rowAlign == LayoutData.ALIGN_CENTER) x = (__width - rw)/2;
				else if (rowAlign == LayoutData.ALIGN_RIGHT) x = __width - margins.r - rw;
				
				// Cycle through components in this row again, for positioning:
				for (m = 0; m < row.length; m++)
				{
					d = row[m];
					c = d as Container;
					l = layoutDatas[d];
					w = d.width;
					
					if (!l) l = dummyLayout;
					
					if (l.position != LayoutData.POS_ABSOLUTE)
					{
						x += l.padding_l;
						y += l.padding_t;
						
						if (l.position == LayoutData.POS_RELATIVE)
						{
							x+= l.x;
							y+= l.y;
						}
					}
					else
					{
						x = baseX + l.x + l.padding_l;
						y = baseY + l.y + l.padding_t;
					}
					
					if (c != null)
						c.move(x,y);
					else
					{
						d.x = x;
						d.y = y;
					}
					
					if (d.visible)
					{
						visibleWidth = Math.max(visibleWidth, d.x + d.width + margins.r);
						visibleHeight = Math.max(visibleHeight, d.y + d.height + margins.b);
					}
					
					x += w + l.padding_r;
					y = baseY;
				}
				
				// Next row
				x = baseX;
				y += maxY;
			}
		}
		
		/**
		 * Get the visible size after a layout operation.
		 * These dimensions will ignore any invisible components
		 * @return A Metrics object containing the width and height.
		 */
		public function getVisibleMetrics():Metrics
		{
			var m:Metrics = new Metrics(visibleWidth, visibleHeight);
			return m;
		}
	}
}
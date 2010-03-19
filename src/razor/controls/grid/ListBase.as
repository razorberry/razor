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

package razor.controls.grid
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import razor.controls.ScrollBar;
	import razor.core.ListContainer;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Base class for a List component. Abstracts some methods for reusability.
	 * @private
	 */
	public class ListBase extends ListContainer
	{
		use namespace razor_internal;
		
		public static const E_SELECT:String = Event.SELECT;
	
		public static const ORIENT_ROWS:String = "rows";
		public static const ORIENT_COLUMNS:String = "columns";
		
		public var scrollbarWidth:Number = 16;
		
		private var xPos:Number = 0;
		private var yPos:Number = 0;
		private var _orientation:String = ORIENT_ROWS;
		private var cells:Object;
		private var states:Dictionary;
		private var providerChanged:Boolean = false;
		private var container:StyledContainer;
		private var listMask:Shape;
		private var _rowHeights:Number = 20;
		private var _columnWidths:Number = 100;
		private var hScroll:ScrollBar;
		private var vScroll:ScrollBar;
		private var rowsVisible:Number = 0;
		private var columnsVisible:Number = 0;
		private var _labelField:String = "label";
		private var _selectedIndex:int = -1;
		
		//////////////////////////////////////////////////////////////////////////////
		// Public methods..
		
		/**
		 * @inheritdoc
		 */
		override public function set dataProvider(arr:Array):void
		{
			providerChanged = true;
			super.dataProvider = arr;
			providerChanged = false;
		}
		
		public function get contentWidth():Number
		{
			return _columnWidths;
		}
		
		public function get contentHeight():Number
		{
			var h:Number = 0;
			//if (_rowHeights is Array)
			//{
			//	var z:Number = Math.min(_rowHeights.length, dP.length);
			//	while (--z >= 0)
			//		h += _rowHeights[z];
			//}
			//else 
			h = _rowHeights * dP.length;
			return h;
		}
		
		public function set vScrollPosition(n:Number):void
		{
			yPos = n;
			//doLayout();
			layoutContents();
		}
		
		public function get vScrollPosition():Number
		{
			return yPos;
		}
		
		public function deselectAll():void
		{
			for each (var z:Cell in cells)
				if (z is SelectableCell)
				{
					SelectableCell(z).selected = false;
					if (SelectableCell(z).dataProvider != null)
					{
						delete states[SelectableCell(z).dataProvider];
					} 
				}
		}
		
		public function set selectedItem(item:Object):void
		{
			if (dP == null)
				return;
				
			for (var j:int = 0; j < dP.length; j++)
				if (dP[j] == item)
					selectedIndex = j;
		}
		
		public function get selectedItem():Object
		{
			if (dP == null || _selectedIndex < 0)
				return null;
				
			return dP[_selectedIndex];
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
			/*
			var l:uint = dataProvider.length;
			for (var i:uint = 0; i < l; i++)
			{
				if (cells["0/"+i].selected)
					return i;
			}
			
			return -1;
			*/
		}
		
		public function set selectedIndex(n:int):void
		{
			deselectAll();
			_selectedIndex = n < 0 ? -1 : n;
			if (cells && cells["0/"+n])
				cells["0/"+n].selected = true;
		}
		
		public function get hasHScroll():Boolean
		{
			return hScroll && hScroll.visible;
		}
		
		public function get hasVScroll():Boolean
		{
			return vScroll && vScroll.visible;
		}
		
		public function set labelField(str:String):void
		{
			_labelField = str;
		}
		
		public function get labelField():String
		{
			return _labelField;
		}
		
		/**
		 * Returns an array of the same length as the dataProvider containing the states
		 * retrieved from each cell renderer.
		 * This allows you to find out which items are selected, checked, or other custom state
		 * without modifying the dataProvider in the cell renderer class.
		 */
		public function getStates():Array
		{
			var a:Array = new Array(dP.length);
			for (var i:int = 0; i < dP.length; i++)
			{
				var o:Object = states[dP[i]];
				if (o)
				a[i] = o;
			}
			
			return a;
		}
		
		////////////////////////////////////////////////////////////////////////
		// Private methods..
		
		public function ListBase()
		{
			cells = new Object();
			states = new Dictionary(true);
		}
		
		/** @private */
		override protected function construct():void
		{
			container = addBlueprint(StyledContainer) as StyledContainer;
			addChild(container);
			listMask = new Shape();
			addChild(listMask);
			listMask.graphics.beginFill(0,1);
			listMask.graphics.drawRect(0,0,100,100);
			listMask.graphics.endFill();
			container.mask = listMask;
		}
		
		/** @private */
		override protected function layout():void
		{
			listMask.x = 1;
			listMask.y = 1;
			adjustScrollbars();
			
			checkColumnWidth();
			layoutContents();
		}
		
		private function checkColumnWidth():void
		{
			_columnWidths = __width - (vScroll && vScroll.visible ? vScroll.width : 0);	
		}
		
		private function adjustScrollbars():void
		{
			var ch:Number = contentHeight;
			var cw:Number = contentWidth;
			
			var useh:Boolean = false;
			var usev:Boolean = false;
			var alterwidth:Boolean = false;
			if (cw > __width)
			{
				useh = true;
			}
			
			if (ch > __height - (useh ? scrollbarWidth : 0))
			{
				usev = true;
				_columnWidths = __width - scrollbarWidth;
			}
			
			if (usev && !useh)
			{
				if (contentWidth > __width - scrollbarWidth)
				{
					useh = true;
				}
			}
			
			if (useh)
			{
				if (hScroll == null)
				{
					hScroll = addBlueprint(ScrollBar) as ScrollBar;
					hScroll.horizontal = true;
					hScroll.wheelTarget = this;
					hScroll.smallScroll = _columnWidths/5;
				}
				hScroll.visible = true;
				hScroll.move(0, __height - scrollbarWidth);
				hScroll.setSize(__width - (usev ? scrollbarWidth : 0), scrollbarWidth);
				container.height = __height - scrollbarWidth;
				listMask.height = container.height-2;
				
				hScroll.setScrollProperties(1, 1, 1); // TODO: this
				hScroll.scrollPosition = xPos;
			}
			else
			{
				if (hScroll)
					hScroll.visible = false;
				container.height = __height;
				listMask.height = container.height-2;
			}
			
			if (usev)
			{
				if (vScroll == null)
				{
					vScroll = addBlueprint(ScrollBar) as ScrollBar;
					vScroll.addEventListener(ScrollBar.E_SCROLL,onVScroll);
					vScroll.smallScroll = _rowHeights;
					vScroll.wheelTarget = this;
				}
				vScroll.visible = true;
				vScroll.move(__width - scrollbarWidth, 0);
				vScroll.setSize(scrollbarWidth, __height - (useh ? scrollbarWidth : 0));
				container.width = __width - scrollbarWidth;
				listMask.width = container.width-2;
				
				//trace(ch +" - "+__height);
				vScroll.setScrollProperties(__height - (useh ? scrollbarWidth : 0), 0, ch - __height + (useh ? scrollbarWidth : 0) + 2);
				vScroll.scrollPosition = yPos;
			}
			else
			{
				if (vScroll)
				vScroll.visible = false;
				container.width = __width;
				listMask.width = container.width-2;
			}
		}
		
		private function onVScroll(e:Event):void
		{
			vScrollPosition = vScroll.scrollPosition;
		}
		
		private function layoutContents():void
		{
			var current:Object = new Object();
			var ah:Number = __height - (hScroll && hScroll.visible ? hScroll.height : 0);
			var x:Number = 0;
			var y:Number = 0;
			var i:Number = Math.floor(yPos / _rowHeights);
			y -= yPos - (_rowHeights * i);
			var ci:String;
			var cell:DisplayObject;
			
			/*
			for (var j:int = 0; j < i; j++)
			{
				ci = "0/"+j;
				
				cell = cells[ci];
				delete cells[ci];
				cell.visible = false;
				current[ci] = cell;
			}
			*/
			
			while (y < ah && dP[i] != null)
			{
				ci = "0/"+i;
				
				// Find the cell if its already there
				
				var o:Object = null;
				
				if (cells[ci] != null)
				{
					cell = cells[ci];
					delete cells[ci];
					
					if (providerChanged && cell is ICellRenderer)
					{
						ICellRenderer(cell).dataProvider = dP[i];
						o = states[dP[i]];
						if (o)
						ICellRenderer(cell).state = o;
					}	
					//cell.visible = true;
				}
				else
				{
					cell = createCell(i);
					
					if (cell is ICellRenderer)
					{
						o = states[dP[i]];
						if (o)
						ICellRenderer(cell).state = o;
					}
				}
				
					
				current[ci] = cell;
				
				// Size and position
				sizeChild(cell, _columnWidths, _rowHeights);
				cell.x = x;
				cell.y = y;
				
				i++;
				y += cell.height;
			}
			
			/*
			while(dP[i] != null)
			{
				ci = "0/"+i;
				
				if (cells[ci] != null)
				{
					cell = cells[ci];
					delete cells[ci];
					cell.visible = false;
					current[ci] = cell;
				}
				
				i++;
			}
			*/
			
			for each (var z:DisplayObject in cells)
				if (z != null)
				{
					//trace(z);
					if (z is ICellRenderer)
					{
						var cr:ICellRenderer = ICellRenderer(z);
						if (cr.dataProvider != null)
						states[cr.dataProvider] = cr.state;
						
						if (z is SelectableCell)
						z.removeEventListener(SelectableCell.E_CLICK, onItemClick);
					}
					if (container.contains(z))
					container.removeChild(z);
					
				}
					
			
			cells = current;
		}
		
		/**
		 * Create a new cell renderer.
		 * @param i	The index of the cell we are creating.
		 * @return	A cell renderer instance.
		 */
		protected function createCell(i:int):DisplayObject
		{
			var cell:DisplayObject = container.addBlueprint(cellClass != null ? cellClass : cellStyle, { dataProvider: dP[i], style:__style });
			
			if (cell is ICellRenderer)
			ICellRenderer(cell).labelField = _labelField;
			
			if (cell is SelectableCell)
			{
				if (i == _selectedIndex)
					SelectableCell(cell).selected = true;
					
				cell.addEventListener(SelectableCell.E_CLICK, onItemClick, false, 0, true);
			}
					
			return cell;
		}
		
		private function onItemClick(e:Event):void
		{
			dispatchEvent(new RazorEvent(E_SELECT, {item: e.currentTarget, data: e.currentTarget.dataProvider}));
		}
	}
}
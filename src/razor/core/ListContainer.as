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

package razor.core
{
	/** Adds list specific methods to a StyledContainer 
	 * @private
	 */
	public class ListContainer extends StyledContainer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "List"; }
		
		private var listCellStyle:String = "ListCell";
		private var listCellClass:Class;
		/** @private */ protected var dP:Array;
		public var listOwner:ListContainer;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		* Get/Set the data provider array for this list.
		* When set, the list will be redrawn with the new content.
		* @param	arr		The new data provider array.
		*/
		public function set dataProvider(arr:Array):void
		{
			dP = arr;
			doLayout();
		}
		
		/** @private */
		public function get dataProvider():Array
		{
			return dP;
		}
		
		/**
		* Get/set the cell renderer style used for each list item.
		* @param	styleName	The style to use in the stylesheets
		*/
		public function set cellStyle(styleName:String):void
		{
			listCellStyle = styleName;
			doLayout();
		}
		
		/** @private */
		public function get cellStyle():String
		{
			var cs:String;
			if (listOwner != null)
				cs = listOwner.cellStyle;
			else
				cs = listCellStyle;
			
			return cs;
		}
		
		/**
		* Get/set the cell renderer class used for each list item.
		 * Setting this will override the cell renderer created if you had just set cellStyle.
		* @param	c	The class to use
		*/
		public function set cellClass(c:Class):void
		{
			listCellClass = c;
			doLayout();
		}
		
		/** @private */
		public function get cellClass():Class
		{
			var c:Class;
			if (listOwner != null)
				c = listOwner.cellClass;
			else
				c = listCellClass;
			
			return c;
		}
		
		/**
		* Add an item to the end of the data provider.
		* @param	item	The new item
		*/
		public function addItem(item:Object):void
		{
			dataProvider.push(item);
			doLayout();
		}
		
		/**
		* Remove an item from the data provider
		* @param	item	The item to remove
		* @return	A boolean indicating whether item was found and removed.
		*/
		public function removeItem(item:Object):Boolean
		{
			var d:Array = dataProvider;
			var i:int = indexOf(item);
			if (i >= 0)
				d.splice(i,1);
			doLayout();
			return (i >= 0);
		}
		
		/**
		* Add a list item at a specific index in the data provider.
		* @param	item	The item to add.
		* @param	index	The index in the dataprovider to insert the new item
		*/
		public function addItemAt(item:Object, index:int):void
		{
			var d:Array = dataProvider;
			d.splice(index,0,item);
			layout();
		}
		
		/**
		* Remove a list item at a specific index in the data provider.
		* @param	index	The index of the item to remove.
		* @return	The item that was removed.
		*/
		public function removeItemAt(index:int):Object
		{
			var d:Array = dataProvider;
			var a:Array = d.splice(index, 1);
			doLayout();
			return a;
		}
		
		/**
		* Find the index of a particular item in the data provider.
		* @param	item	The item to find.
		* @return	The index of the item in the data provider, or -1 if the item was not found.
		*/
		public function indexOf(item:Object):int
		{
			var d:Array = dataProvider;
			var l:uint = d.length;
			for (var i:uint = 0; i < l; i++)
			{
				if (d[i] == item)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		* Get the item at a specific index in the data provider.
		* @param	index	The index of the item to find.
		* @return	The item at the requested index.
		*/
		public function itemAt(index:int):Object
		{
			return dataProvider[index];
		}
		
		/**
		* Get the length of the current data provider.
		* @return	The length of the data provider.
		*/
		public function get length():uint
		{
			return dP.length;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function ListContainer()
		{
			dP = new Array();
		}
	}
}
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
	import razor.controls.Label;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Base class for a standard list item renderer.
	 * <p>Has no interactivity.. for a selectable cell, extend SelectableCell</p>
	 * @see razor.controls.grid.SelectableCell
	 */
	public class Cell extends StyledContainer implements ICellRenderer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "ListCell"; }
		
		protected var dP:*;
		protected var labelClip:Label;
		/** @private */ protected var _labelField:String = "label";
		
		///////////////////////////////////////////////////////////////////////////
		// Public methods..
		
		/**
		 * Get/set the property on the dataProvider to use as label text.
		 */
		public function set labelField(str:String):void
		{
			_labelField = str;
		}
		
		/** @private */
		public function get labelField():String
		{
			return _labelField;
		}
		
		/**
		 * Set the data provider for this cell.
		 */
		public function set dataProvider(v:*):void
		{
			dP = v;
			if (__initialized)
				doLayout();
		}
		
		/** @private */
		public function get dataProvider():*
		{
			return dP;
		}
		
		/**
		 * Set the state of this cell.
		 */
		public function set state(o:Object):void
		{
			//
		}
		
		/** @private */
		public function get state():Object
		{
			return null;
		}
		
		/**
		 * Set the label for this cell directly. This will modify the dataProvider if appropriate.
		 */
		public function set label(str:String):void
		{
			if (dP is String)
				dP = str;
			else
				dP[labelField] = str;
		}
		
		/** @private */
		public function get label():String
		{
			return dP is String ? dP : (dP.hasOwnProperty(labelField) ? dP[labelField] : "");
		}
		
		//////////////////////////////////////////////////////////////////////////////
		// Private methods
		
		public function Cell()
		{
			
		}
		
		/** @private */
		override protected function construct():void
		{	
			labelClip = addBlueprint(Label) as Label;
			labelClip.selectable = false;
			labelClip.mouseChildren = false;
			labelClip.mouseEnabled = false;
		}
		
		/** @private */
		override protected function layout():void
		{
			labelClip.text = label;
			labelClip.setSize(__width, __height);
		}
	}
}
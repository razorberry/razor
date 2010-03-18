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
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.layout.AccordionPane;
	import razor.layout.Layer;
	import razor.layout.LayoutData;
	import razor.layout.ScrollArea;
	import razor.layout.types.RowBasedLayout;

	/**
	 * Tag so we can use this container with mxml.
	 */
	[DefaultProperty("children")]
	
	/**
	 * Class for an accordion component.
	 * <p>You can add any number of collapsible panes.
	 * </p>
	 * @example
	 * <listing version="3.0">
	 * var accordion:Accordion = ControlFactory.create(Accordion) as Accordion;
	 * accordion.setSize(400,500);
	 *
	 * trace("adding pane 1");
	 * var content:CollapsiblePane = accordion.addPane("First Pane");
	 * trace("adding pane 2");
	 * var content2:CollapsiblePane = accordion.addPane("Second Pane");
	 * </listing>
	 */
	public class Accordion extends Layer
	{
		use namespace razor_internal;
		
		/** @private */ override protected function getClass():String { return "Accordion"; }
		
		/** @private */ protected var panes:Array;
		/** @private */ protected var scrollArea:ScrollArea;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/** @private */
		override public function set children( value:Array ):void
		{
			
			while ( numChildren > 0 )
			{
				removeChildAt( 0 );
			}
			
			panes = new Array();
			
			for (var i:int = 0; i < value.length; i++)
			{
				var ld:LayoutData = new LayoutData();
				ld.padding = 0;
				Layer(scrollArea.content).addChildWithLayout( value[i] , ld);
				panes.push( value[i] );
			}
			
		}
		
		/**
		* Add a new pane to this Accordion.
		* @param	title	The header string to use
		* @return	The newly created CollapsiblePane instance.
		*/
		public function addPane(title:String):AccordionPane
		{
			var ld:LayoutData = new LayoutData();
			ld.padding = 0;
			var newpane:AccordionPane = __controlFactory.create(AccordionPane) as AccordionPane;
			Layer(scrollArea.content).addChildWithLayout(newpane, ld);
			newpane.label = title;
			panes.push(newpane);
			return newpane;
		}
		
		/**
		* Remove a pane from this Accordion. The pane's contents will also be destroyed.
		* @param	pane	The pane instance to remove.
		*/
		public function removePane(pane:AccordionPane):void
		{
			var thepane:AccordionPane;
			
			var i:int = int(panes.length);
			while (--i >= 0)
			{
				if (panes[i] == pane)
				{
					thepane = panes[i];
					panes.splice(i,1);
				}
			}
			
			if (thepane != null)
				Layer(scrollArea.content).destroyChild(thepane);
		}
		
		/**
		 * Get a pane in this Accordion by title. 
		 * @param title	The title of the pane to retrieve.
		 * @return 	A CollapsiblePane instance, or null if the pane was not found.
		 */		
		public function getPaneByTitle(title:String):AccordionPane
		{
			var thepane:AccordionPane;
			
			var i:int = int(panes.length);
			while (--i >= 0)
				if ("label" in panes[i] && panes[i].label == title)
					return panes[i] as AccordionPane;
				
			return null;
		}
		
		/**
		 * Get a pane in this Accordion by index. 
		 * @param i	The index of the pane to retrieve.
		 * @return A CollapsiblePane instance, or null if the pane was not found.
		 */		
		public function getPaneByIndex(i:int):AccordionPane
		{
			if (panes[i])
				return panes[i] as AccordionPane;
				
			return null;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function Accordion()
		{
			panes = new Array();
		}
		
		/** @private */
		override protected function construct():void
		{
			scrollArea = addBlueprint(ScrollArea) as ScrollArea;
			Layer(scrollArea.content).layoutImplementation = new RowBasedLayout();
			scrollArea.hScrollPolicy = ScrollArea.SCROLL_NEVER;
			scrollArea.vScrollPolicy = ScrollArea.SCROLL_ALWAYS;
		}
		
		/** @private */
		override protected function layout():void
		{
			scrollArea.setSize(__width, __height);
		}
	}
}
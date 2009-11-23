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
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.display.DisplayObject;
	
	/**
	 * An extension of StyledContainer that provides additional depth management functions.
	 * 
	 */
	public class DepthManagedContainer extends StyledContainer
	{
		private var onTop:Dictionary;
		
		/**
		 * Contructor.
		 */
		public function DepthManagedContainer()
		{
		}
		
		/** @private */
		protected function addChildAlwaysOnTop(child:DisplayObject):DisplayObject
		{
			onTop[child] = child;
			return addChild(child);
		}
		
		/** @private */
		protected function getTopDepth():uint
		{
			var i:int = 0;
			for each(var z:DisplayObject in onTop)
				i++;
				
			return numChildren - 1 - i;
		}
		
		/** @private */
		override protected function construct():void
		{
			onTop = new Dictionary(true);
			addEventListener(Event.ADDED, onAdd);
			addEventListener(Event.REMOVED, onRemove);
		}
		
		/** @private */
		private function onAdd(e:Event):void
		{
			if (contains(e.target as DisplayObject))
			{
				for each (var z:DisplayObject in onTop)
				{
					setChildIndex(z, numChildren-1);
				}
			}
		}
		
		/** @private */
		private function onRemove(e:Event):void
		{
			if (onTop[e.target])
				delete onTop[e.target];
		}
	}
}
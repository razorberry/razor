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
	import flash.utils.Dictionary;
	
	import razor.core.Metrics;
	
	/**
	 * Interface for a layout implementation.
	 * @see Layer
	 */
	public interface ILayoutImpl
	{
		/**
		 * Takes an array of objects of type {container:Container, layout:LayoutData}
		 * and sizes and arranges the containers accordingly.
		 * @param	data	The array of containers and their associated LayoutDatas
		 * @param	width	The available width
		 * @param	height	The available height
		 */
		function doLayout(children:Array, layoutDatas:Dictionary, width:Number, height:Number, margins:Metrics = null):void;
		
		/**
		 * Get the visible size after a layout operation.
		 * These dimensions will ignore any invisible components
		 * @return A Metrics object containing the width and height.
		 */
		function getVisibleMetrics():Metrics;
		
	}
}
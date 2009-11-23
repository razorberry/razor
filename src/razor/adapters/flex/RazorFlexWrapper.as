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

package razor.adapters.flex
{
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	
	[DefaultProperty("children")]
	
	public class RazorFlexWrapper extends UIComponent
	{
		public function RazorFlexWrapper()
		{
			super();
		}
		
		private var _children:Vector.<DisplayObject>;
        private var childrenChanged:Boolean = false;
        
        /**
         * Array of DisplayObject instances to be added as children
         */
        public function get children():Vector.<DisplayObject>
        {
            return _children;
        }
        
        public function set children( value:Vector.<DisplayObject> ):void
        {
            if ( _children != value )
            {
                _children = value;
                childrenChanged = true;
               	invalidateProperties();
            }
        }
        
        override protected function commitProperties() : void
        {
            if ( childrenChanged )
            {
                while ( numChildren > 0 )
                {
                    removeChildAt( 0 );
                }
                
                for each ( var child:DisplayObject in _children )
                {
                    addChild( child );
                }
                
                childrenChanged = false;
            }
            
            super.commitProperties();
        }

		override protected function measure() : void
		{
			super.measure();
			
			var w:Number = 0;
			var h:Number = 0;
			for each ( var child:DisplayObject in _children )
            {
            	w = Math.max(w, child.x + child.width);
            	h = Math.max(h, child.y + child.height);
            }
			measuredWidth = measuredMinWidth = w;
			measuredHeight = measuredMinHeight = h;
		}
	}
}
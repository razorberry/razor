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

package razor.layout
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import razor.core.Container;
	import razor.core.Metrics;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;
	import razor.layout.types.ILayoutImpl;
	import razor.layout.types.NoLayout;

	/**
	 * Dispatched when the contents have resized after a layout operation.
	 * @eventType razor.layout.Layer.E_RESIZE
	 */
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Tag so we can use this container with mxml.
	 */
	[DefaultProperty("children")]
	
	/**
	 * Class for an automatic layout container.
	 * You add components using addLayoutElement(). Layout parameters are set using LayoutData.
	 * You can nest layers for more complex layouts.
	 * You can also swap the layout implementation using the layoutImplementation property.
	 * @see #addLayoutElement
	 * @see #layoutImplementation
	 * @see LayoutData
	 * @example
	 * <listing version="3.0">
	 * var newLayer = addChild(new Layer());
	 * newLayer.setSize(500,400);
	 * var newButton:Button = newLayer.addLayoutElement(Button) as Button;
	 * var secondButton:Button = newLayer.addLayoutElement(Button, {width: 50, widthType: LayoutData.TYPE_PERCENT}) as Button;
	 * var ld:LayoutData = new LayoutData(LayoutData.POS_RIGHT, 50, 0, LayoutData.TYPE_PERCENT);
	 * var thirdButton:Button = newLayer.addLayoutElement(Button, ld) as Button;
	 * </listing>
	 */
	public class Layer extends StyledContainer
	{
		use namespace razor_internal;
		
		public static const E_RESIZE:String = Event.RESIZE;

		/** @private */ override protected function getClass():String { return "Layer"; }
		
		/**
		 * The array of children that are automatically positioned by this layer
		 */
		protected var _children:Array;
		
		protected var _layoutDatas:Dictionary;
		
		/** The space between the top of the layer and the top of the content. */
		protected var margin_t:Number = 0;
		/** The space between the bottom of the layer and the bottom of the content. */
		protected var margin_b:Number = 0;
		/** The space between the left of the layer and the left of the content. */
		protected var margin_l:Number = 0;
		/** The space between the right of the layer and the right of the content. */
		protected var margin_r:Number = 0;
		
		/** The total visible width after the content has been positioned. */
		public var visibleWidth:Number = 0;
		/** The total visible height after the content has been positioned. */
		public var visibleHeight:Number = 0;
		
		/** @private */ protected var layingOut:Boolean = false;
		
		/** @private */ protected var autoCollapse:Boolean = true;
		
		/** @private */ protected var implementation:ILayoutImpl;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Get/Set the children of this container.
		 */
		public function get children():Array
        {
            return _children;
        }
        
        /** @private */
        public function set children( value:Array ):void
        {
            
            while ( numChildren > 0 )
            {
                removeChildAt( 0 );
            }
            
            for (var i:int = 0; i < value.length; i++)
            {
                addChild( value[i] );
            }
           
        }
        
		/**
		* Add a child component to this layer with optional LayoutData.
		* The component will be automatically positioned and sized whenever the layer changes.
		* NOTE: This method redraws the layer, so be sure to freeze it when adding a large
		* number of components, with layer.freeze(true); and then layer.freeze(false);
		* when you are done.
		* @see LayoutData
		* @param	tagOrClass	The skin ID or class of the component to add.
		* @param	layoutData	Optional layout data for the new component
		* @param	initObj		Any initial parameters can be pushed into the component here.
		* @throws IllegalOperationError You cannot add a non-Container using this method. 
		*/
		/*
		[Deprecated]
		public function addLayoutElement(tagOrClass:*, layoutData:Object = null, initObj:Object = null):Container
		{
			var untyped:* = addBlueprint(tagOrClass, initObj);
			
			if (!(untyped is Container))
			{
				throw new IllegalOperationError("Tried to add a non-Container to a Layer");
			}
			
			var c:Container = untyped as Container;
			
			if (layoutData == null)
			{
				layoutData = new LayoutData();
				layoutData.position = LayoutData.POS_BELOW;
				//layoutData.width = 100;
				//layoutData.widthType = LayoutData.TYPE_PERCENT;
			}
			else if (!(layoutData is LayoutData))
			{
				var l:LayoutData = new LayoutData();
				for (var z:String in layoutData)
					if (l.hasOwnProperty(z))
						l[z] = layoutData[z];
				layoutData = l;
			}
			
			if (_children == null)
				_children = new Array();
				
			_children.push(c);
			_layoutDatas[c] = layoutData;
			
			doLayout();
			return c;
		}
		*/
		
		
		/**
		 * Add a child to this Layer with specific layout data. 
		 * @param child	The DisplayObject to add
		 * @param layoutData	(Optional) A LayoutData instance
		 * @return The added DisplayObject.
		 * 
		 */
		public function addChildWithLayout(child:DisplayObject, layoutData:LayoutData = null):DisplayObject
		{
			if (layoutData == null)
			{
				layoutData = new LayoutData();
				layoutData.position = LayoutData.POS_BELOW;
			}
			
			_layoutDatas[child] = layoutData;
			
			return addChild(child);
		}
		
		/** @inheritdoc */
		override public function addChild(child:DisplayObject) : DisplayObject
		{
			if (_children == null)
				_children = new Array();
				
			_children.push(child);
			
			if (child is Container)
				registerChild(child as Container);
				
			super.addChild(child);
			doLayout();
			return child;
		}
		
		/** @inheritdoc */
		override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
		{
			addChild(child);
			setChildIndex(child, index);
			
			return child;
		}
		
		/** @inheritdoc */
		override public function removeChild(child:DisplayObject) : DisplayObject
		{
			if (_layoutDatas[child] != undefined)
			{
				delete _layoutDatas[child];
			}
			
			var i:int = _children.indexOf(child);
			
			if (i >= 0)
				_children.splice(i,1);
			
			if (child is Container)
			unregisterChild(child as Container);
			
			super.removeChild(child);
			return child;
		}
		
		/** @inheritdoc */
		override public function removeChildAt(index:int) : DisplayObject
		{
			var child:DisplayObject = getChildAt(index);
			removeChild(child);
			
			return child;
		}
		
		/**
		* Remove a component from the layer. The component will be destroyed.
		* @param	container	The component to remove.
		*/
		public function destroyChild(container:Container):void
		{
			removeChild(container);
			
			container.destroy();
		}
		
		/**
		 * Change the default layout implementation.
		 * @param impl	An instance of a layout implementation to use
		 */
		public function set layoutImplementation(impl:ILayoutImpl):void
		{
			if (impl == null)
				impl = new NoLayout();
				
			implementation = impl;
			
			doLayout();
		}
		
		/** @private */
		public function get layoutImplementation():ILayoutImpl
		{
			return implementation;
		}
		
		/**
		* Internal method to register a reference to a child.
		* @private
		* @param	c	The child container
		*/
		override protected function registerChild(c:Container):void
		{
			if (c == null) return;
			super.registerChild(c);
			c.addEventListener(E_RESIZE, onChanged, false, 0, true);
		}
		
		/**
		* Internal method to unregister a child from this container.
		* @private
		* @param	c
		*/
		override protected function unregisterChild(c:Container):void
		{
			super.unregisterChild(c);
			c.removeEventListener(E_RESIZE, onChanged);
		}
		
		/**
		 * Retrieve an array of children positioned by this Layer.
		 * @return An array of children DisplayObjects.
		 */
		public function getChildren():Array
		{
			if (children == null) return new Array();
			
			return children.concat();
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		public function Layer()
		{
			// Set style to null here, so that Layer doesn't push a default style onto children.
			// The user can set a style later if they want to.
			style = null;
			
			mouseEnabled = false; // Dont dispatch any mouse events ourself, leave that up to the children.
			
			implementation = new NoLayout();
			
			_layoutDatas = new Dictionary(true);
		}
		
		/** @private */
		override protected function construct():void
		{
			// Override me
		}
		
		/** @private */
		override protected function layout():void
		{
			var n:uint = _children ? _children.length : 0;
			
			if (n == 0)
				return;
				
			var originalWidth:Number = __width;
			var originalHeight:Number = __height;
			var m:Metrics = new Metrics(0,0,margin_l,margin_r,margin_t,margin_b);
			
			if (__style)
			{
				m.t = isNaN(__style.margin_t) ? m.t : __style.margin_t;
				m.b = isNaN(__style.margin_b) ? m.b : __style.margin_b;
				m.l = isNaN(__style.margin_l) ? m.l : __style.margin_l;
				m.r = isNaN(__style.margin_r) ? m.r : __style.margin_r;
			}
			
			layingOut = true;
			implementation.doLayout(_children, _layoutDatas, __width, __height, m);
			layingOut = false;
			
			var vm:Metrics = implementation.getVisibleMetrics();
			visibleWidth = vm.width;
			visibleHeight = vm.height;
			if (autoCollapse)
				__height = visibleHeight;
			
			if (originalHeight != __height || originalWidth != __width)
				dispatchEvent(new Event(E_RESIZE));
		}
		
		/** 
		 * Called when a child container has changed size.
		 * @private
		 */
		private function onChanged(e:Event):void
		{
			if (layingOut) return;
			
			layout();
			dispatchEvent(new Event(E_RESIZE));
		}
	}
}
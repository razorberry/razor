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
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.getClassByAlias;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import razor.layout.ModalLayer;
	
	/**
	 * Dispatched before the container has started to create its children.
	 * @eventType razor.core.Container.E_PREINIT
	 */
	[Event(name="preInit", type="flash.events.Event")]
	
	/**
	 * Dispatched when this Container has initialized and is ready to display.
	 * @eventType razor.core.Container.E_INIT
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * Dispatched when this Container has resized.
	 * @eventType razor.core.Container.E_RESIZE
	 */
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	* Base class for a visible screen element. Controls drawing and layout methods.
	* 
	* <p>Normally, components will be constructed immediately, but this can be delayed in
	* subclass constructors in case you need to do some extra initialization.</p>
	* <p>
	* The order of initialization is:<br>
	* construct();</p>
	* 
	* <p>And then arbitrarily in the future:<br>
	* layout();</p>
	* 
	* <p>You should override these abstract methods to provide your own functionality. 
	* As a general rule, construction functionality should be kept entirely separate from layout functionality.
	* Children may need to be repositioned or redrawn any number of times after construction.</p>
	*/
	public class Container extends Sprite
	{
		use namespace razor_internal;
	
		// Event constants:
		public static const E_PREINIT:String = "preInit";
		public static const E_INIT:String = Event.INIT;
		public static const E_RESIZE:String = Event.RESIZE;
		
		/** @private */ protected var __width:Number;
		/** @private */ protected var __height:Number;
		
		/** @private */ razor_internal var __initialized:Boolean = false;
		/** @private */ protected var __frozen:Boolean = false;
		/** @private */ protected var __enabled:Boolean = true;
		
		/**
		* Constructor.
		* @param	delayConstruction	A boolean indicating whether to delay construction til later.
		*/
		public function Container(delayConstruction:Boolean = false)
		{
			createAccessibilityImplementation();
			
			var modalLayer:ModalLayer = ModalLayer.getInstance();
			if (modalLayer && modalLayer.getStage() == null)
			{
				if (stage) modalLayer.setStage(stage);
				else addEventListener(Event.ADDED_TO_STAGE, onAddToStage, false, 0, true);
			}
			
			if (delayConstruction != true)
			constructObject();
		}
		
		/**
		* Create children for this component. You normally wouldn't position anything here
		* but you could call your layout method at the end.
		*/
		protected function construct():void { doLayout(); }
		
		/**
		* Position and size any children. This method may be called at any time after
		* construction.. usually on setSize or when the content changes.
		*/
		protected function layout():void {}
		
		/** @private */
		razor_internal final function doLayout():void { /* graphics.clear(); */ if (!__frozen) layout(); /* drawBorder(); */ }
		
		razor_internal final function doConstruct():void { constructObject(); }
		
		/**
		* Begin the regular initialization of this component.
		* Will dispatch an E_INIT event when finished.
		* @private
		*/
		protected function constructObject():void
		{
			// This is the order in which subclasses are initialized
			
			/*
			//CS3:
			var ps:Class;
			try
			{
				ps = flash.utils.getDefinitionByName("razor.adapters.flash.PlasticSkin") as Class;
			}
			catch (e:Error) {trace("Skin not found");}
			if (ps && Object(ps).initialized === false)
			{
				Object(ps).initialized = true;
				var psi:* = new ps();
			}
			var r:Number = rotation;
			rotation = 0;
			var w:Number = super.width;
			var h:Number = super.height;
			super.scaleX = super.scaleY = 1;
			
			if (numChildren > 0) {
				removeChildAt(0);
			}
			// end CS3
			
			construct();
			
			// CS3 Live preview: remove our component avatar
			move(super.x,super.y);
			rotation = r;
			if (w > 0 && h > 0)
			{ setSize(w,h); }
			else
			{
				var m:Metrics = getPreferredMetrics();
				setSize(m.width,m.height);
			}
			// end CS3
			*/
			
			dispatchEvent(new Event(E_PREINIT));
			
			//trace("constructing: "+toString());
			construct();
			
			checkPending();
		}
		
		/** @private */ razor_internal var __pendingConstruction:int = 0;
		
		/** @private */
		private function checkPending(e:Event = null):void
		{
			if (e != null)
			{
				e.target.removeEventListener(E_INIT, checkPending);
				__pendingConstruction--;
			}
			if (__pendingConstruction <= 0)
			{
				__initialized = true;
				dispatchEvent(new RazorEvent(E_INIT));
			}
		}
		
		protected function waitForInit(component:IEventDispatcher):void
		{
			component.addEventListener(E_INIT, checkPending, false, 0, true);
			__pendingConstruction++;
		}
		
		private function onAddToStage(e:Event):void
		{
			var modalLayer:ModalLayer = ModalLayer.getInstance();
			if (modalLayer.getStage() == null)
				modalLayer.setStage(stage);
				
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}
		
		protected function createAccessibilityImplementation():void
		{
			// Override
		}
		
		/**
		* Set/Get the width of this component. Setting this will trigger layout().
		* @param	w	The new width
		*/
		override public function set width(w:Number):void
		{
			__width = w;
			setSize(__width, __height);
		}
		
		/** @private */
		override public function get width():Number
		{
			return !isNaN(__width) ? __width : super.width;
		}
		
		/**
		* Set/Get the height of this component. Setting this will trigger layout().
		* @param	h	The new height
		*/
		override public function set height(h:Number):void
		{
			__height = h;
			setSize(__width, __height);
		}
		
		/** @private */
		override public function get height():Number
		{
			return !isNaN(__height) ? __height : super.height;
		}
		
		/**
		* Set the width and height of this component.
		* @param	w	The width (in px)
		* @param	h	The height (in px)
		*/
		public function setSize(w:Number,h:Number):void
		{
			__width = w;
			__height = h;
			doLayout();
			dispatchEvent(new RazorEvent(E_RESIZE, {width: __width, height: __height}));
		}
		
		/**
		* Set the position of this component.
		* @param	x	The X position
		* @param	y	The Y position
		*/
		public function move(x:Number,y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		/**
		* Freezing a component prevents it from redrawing itself until you unfreeze it
		* (with freeze(false)).
		* This is useful for optimization if you want to make a large number of changes
		* to a component's size or style without redrawing it on every change.
		* @param	b	A boolean indicating whether the component is frozen.
		*/
		public function freeze(b:Boolean):void
		{
			__frozen = b;
			
			if (!b)
			{
				doLayout();
			}
		}
		
		/**
		* Enable or disable this component.
		* Subclasses should override this method to change their behavior depending
		* on this setting.
		* @default true
		* @param	b	A boolean indicating whether this component is enabled.
		*/
		public function set enabled(b:Boolean):void
		{
			__enabled = b;
		}
		
		/** @private */
		public function get enabled():Boolean
		{
			return __enabled;
		}
		
		/**
		 * Get the preferred size of this component. Subclasses can override this.
		 * @return	A Metrics object with width and height values.
		 */
		public function getPreferredMetrics():Metrics
		{
			return new Metrics(0,20);
		}
		
		/**
		 * Destroy this component cleanly. Will automatically remove it from the display list, but make
		 * sure you have no active references to this container, so that it can be garbage collected.
		 */
		public function destroy():void
		{
			// Remove all hooks to this container..
			// Override this function, but dont forget to call super.destroy();
			
			if (hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE, onAddToStage, false);
			if (hasEventListener(E_INIT))
				removeEventListener(E_INIT, checkPending);
				
			if (parent != null)
			{
				parent.removeChild(this);
			}
				
			__enabled = false;
			__frozen = true;	
		}
		
		/**
		 * Mimic the old AS2 delegate functionality.
		 * @deprecated
		 * @private
		 */
		razor_internal function delegate(o:Object, f:Function):Function
		{
			return function():Function { return f.apply(o, arguments); };
		}
		
		razor_internal function sizeChild(child:DisplayObject, w:Number, h:Number):void
		{
			if (child == null)
				return;
			if ("setSize" in child)
				Object(child).setSize(w,h);
			else
			{
				child.width = w;
				child.height = h;
			}
		}
		
		private static var __traceCount:Number = 0;
		
		/**
		* Private utility method to provide specialized debugging.
		* Currently prepends a trace count and the class name to the trace.
		* TODO: Integrate with a logging subsystem.
		* @private
		* @param	str	A string to trace.
		*/
		protected function debug(str:String):void
		{
			var s:String = "("+(++__traceCount)+") "+toString()+" : "+str;
			try
			{
				var c:Class = flash.utils.getDefinitionByName("FlashConnect") as Class;
				if (c)
					c.trace(s);
			}
			catch (e:ReferenceError)
			{
				trace(s);
			}
		}
		
		/**
		* Get a string representation of this class.
		* By default will return the class name.
		* @return	The class name of this component.
		*/
		override public function toString():String
		{
			return "["+getQualifiedClassName(this)+"]";
		}
		
		private function drawBorder():void
		{
			if (__width > 0 && __height > 0)
			{
				
				graphics.lineStyle(1,0xff0000,1);
				graphics.drawRect(0,0,__width,__height);
			}
		}
	}	
}

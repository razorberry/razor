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
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import razor.core.Container;
	import razor.core.DepthManagedContainer;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Class for a Container that always sits on top of all other content.
	 * This is a singleton, so you should reference it with ModalLayer.getInstance();
	 * A modal layer is created the moment a Container is added to the stage, and is then used
	 * for all subsequent Containers.
	 * @private
	 */
	public class ModalLayer extends DepthManagedContainer
	{
		use namespace razor_internal;

		private static var _application:Container;

		private static var instance:ModalLayer;
		private static var pending:Boolean = false;

		/** @private */ protected var target:DisplayObjectContainer;

		public function ModalLayer(singletonEnforcer:SingletonEnforcer)
		{
			// This modal layer can sometimes get constructed while another styledcontainer
			// is being constructed.
			// This breaks the preInitialize object.. so store it and reset it here.
			var preInit:Object = StyledContainer.preInitialize;
			StyledContainer.preInitialize = null;
			super();
			StyledContainer.preInitialize = preInit;
			mouseEnabled = false; // Dont dispatch any mouse events ourself.
		}

		public static function getInstance():ModalLayer
		{
			if (instance == null)
				if (!pending)
				{
					pending = true;
					instance = new ModalLayer(new SingletonEnforcer());
				}

			return instance;
		}

		public static function getApplication():Container
		{
			return _application;
		}

		/** @private */
		razor_internal static function setApplication(c:Container):void
		{
			_application = c;
		}

		/**
		 * Set the stage for which we will always sit on top.
		 * The ModalLayer listens for every time something is added
		 * to stage, then makes sure it is positioned above it.
		 */
		public function setStage(d:DisplayObjectContainer):void
		{
			target = d;
			target.addChild(this);

			target.addEventListener(Event.ADDED, onAdd);
		}

		public function addPopup(child:DisplayObject, alwaysOnTop:Boolean = false, obscureBackground:Boolean = false):DisplayObject
		{
			var c:DisplayObject;

			if (alwaysOnTop)
			{
				c = addChildAlwaysOnTop(child);
			}
			else
			{
				c = addChild(child);
			}

			if (obscureBackground)
			{
				//TODO
			}

			return c;
		}


		/**
		 * Called every time something is added to our stage.
		 * Change our depth to above everything else.
		 */
		private function onAdd(e:Event):void
		{
			if (e.target.parent != target)
				return;

			if (target == null)
				return;

			// Force modal layer to always be on top.
			target.setChildIndex(this, target.numChildren-1);
		}

		public function getStage():DisplayObjectContainer
		{
			return target;
		}

		/**
		 * Return a suitable point to position a popup.
		 * Either in the center of the stage, or next to an object.
		 * Adjusts for available screen space.
		 */
		public function getNearestPopPoint(popup:DisplayObject, outsideOf:DisplayObject = null, allowAbove:Boolean = true, nextToMouse:Boolean = false):Point
		{
			var rect:Rectangle;

			if (nextToMouse && outsideOf == null)
			{
				rect = new Rectangle(stage.mouseX, stage.mouseY);
			}
			else if (outsideOf == null || outsideOf.parent == null)
			{
				return new Point((stage.width - popup.width)/2, (stage.height - popup.height)/2);
			}

			if (outsideOf)
			{
				rect = new Rectangle(outsideOf.x, outsideOf.y, outsideOf.width, outsideOf.height);
			}

			var p:Point = new Point();
			var maxP:Point = local(stage, new Point(stage.stageWidth, stage.stageHeight));
			var minP:Point = local(stage, new Point(0,0));
			var par:DisplayObject = outsideOf ? outsideOf.parent : stage;
			var below:Point = local(par, new Point(rect.x, rect.y + rect.height));
			var above:Point = local(par, new Point(rect.x, rect.y - popup.height));

			// find x:
			p.x = Math.min(maxP.x - popup.width, below.x);
			p.y = Math.min(maxP.y - popup.height, below.y);

			// find y:
			if (p.y < below.y && allowAbove)
			{
				p.y = Math.max(minP.y, above.y)
			}

			return p;
		}

		private function local(space:DisplayObject, p:Point):Point
		{
			return this.globalToLocal(space.localToGlobal(p));
		}
	}
}

class SingletonEnforcer{}
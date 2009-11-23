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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import razor.core.Container;
	import razor.core.Metrics;
	import razor.core.razor_internal;

	/**
	 * Dispatched when the image is loaded and ready to be displayed.
	 * @eventType razor.controls.Image.E_COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Class to load and display an image.
	 * The image can be an external file, or embedded as a class.
	 */
	public class Image extends Container
	{
		use namespace razor_internal;
		
		public static const E_COMPLETE:String = Event.COMPLETE;
		
		/** @private */ protected function getClass():String { return "Image"; }
		
		/** @private */ protected var _content:DisplayObject;
		private var loader:Loader;
		private var _url:String;
		private var _context:LoaderContext;
		private var _scaleContent:Boolean = false;
		private var _aspect:Boolean = true;
		private var _center:Boolean = true;
		private var unscaledWidth:Number = 0;
		private var unscaledHeight:Number = 0;
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PUBLIC METHODS
		
		/**
		 * Retrieve the internal content as a DisplayObject.
		 * @return	A DisplayObject instance, or null.
		 */
		public function get content():DisplayObject
		{
			return _content;
		}
		
		/**
		 * Get/Set the url for the image. Setting this will automatically initiate a load operation.
		 */
		public function set url(str:String):void
		{
			_url = str;
			load(str);
		}
		
		/** @private */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * Get/Set the source class for the image.
		 * You can use this for embedded images, but also for any class that extends DisplayObject.
		 * @param	c	The class to instantiate and use as content.
		 */
		public function set sourceClass(c:Class):void
		{
			if (_content)
				removeChild(_content);
				
			if (c)
			{
				_content = new c();
				addChild(_content);
				doLayout();
				dispatchEvent(new Event(Container.E_RESIZE));
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/** @private */
		public function get sourceClass():Class
		{
			return _content ? (_content as Object).constructor : null;
		}
		
		/**
		 * Get/Set the bitmap data for the current image.
		 * Setting this will load the bitmap image into the content.
		 * Getting this property will draw the content into a new BitmapData instance.
		 * @param	bmp	The BitmapData to show.
		 */
		public function set bitmapData(bmp:BitmapData):void
		{
			if (_content)
				removeChild(_content);
			
			if (bmp != null)
			{
				_content = new Bitmap(bmp, "auto", true);
				addChild(_content);
				doLayout();
				dispatchEvent(new Event(Container.E_RESIZE));
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/** @private */
		public function get bitmapData():BitmapData
		{
			if (_content)
			{
				if (_content is Bitmap)
					return Bitmap(_content).bitmapData;
					
				var bmp:BitmapData = new BitmapData(_content.width, _content.height, true, 0);
				bmp.draw(_content);
				
				return bmp;
			}
			
			return null;
		}
		
		/**
		 * Get/Set the LoaderContext for the next load operation (set via url).
		 * @param loaderContext	A LoaderContext instance.
		 * @see #url
		 */
		public function set context(loaderContext:LoaderContext):void
		{
			_context = loaderContext;
		}
		
		/** @private */
		public function get context():LoaderContext
		{
			return _context;
		}
		
		/**
		 * Get/Set whether to automatically scale the content of this image to a preset
		 * width and height.
		 * @param	b	A boolean representing whether to scale the content.
		 * @default false
		 */
		public function set scaleContent(b:Boolean):void
		{
			_scaleContent = b;
			doLayout();
		}
		
		/** @private */
		public function get scaleContent():Boolean
		{
			return _scaleContent;
		}
		
		/**
		 * Get/Set whether to keep the aspect ratio when scaling the content.
		 * @param	b	A boolean representing whether to keep the aspect ratio.
		 * @default true
		 */
		public function set keepAspectRatio(b:Boolean):void
		{
			_aspect = b;
			doLayout();
		}
		
		/** @private */
		public function get keepAspectRatio():Boolean
		{
			return _aspect;
		}
		
		/**
		 * Get/Set whether to center the content within the bounds of this image component.
		 * @param	b	A boolean representing whether to center the content.
		 * @default true
		 */
		public function set centerContent(b:Boolean):void
		{
			_center = b;
			doLayout();
		}
		
		/** @private */
		public function get centerContent():Boolean
		{
			return _center;
		}
		
		/**
		 * Retrieve whether this Image instance has any content (a loaded image)
		 * or if it is empty.
		 * @return	True if the Image has content, false otherwise.
		 */
		public function get hasContent():Boolean
		{
			return (_content && _content.width > 0 && _content.height > 0);
		}
		
		////////////////////////////////////////////////////////////////////////////////////////
		// PRIVATE METHODS
		
		/** @private */
		override protected function construct():void
		{
			// nothing to do!
		}
		
		/** @private */
		override protected function layout():void
		{
			if (hasContent)
			{
				_content.scaleX = _content.scaleY = 1;
				unscaledWidth = _content.width;
				unscaledHeight = _content.height;			
				
				if (_scaleContent)
				{
					if (__width > 0 || __height > 0)
					{
						if (_aspect)
						{
							if (__width / _content.width < __height / _content.height)
							{
								_content.width = __width;
								_content.scaleY = _content.scaleX;
							}
							else
							{
								_content.height = __height;
								_content.scaleX = _content.scaleY;
							}
							
							//if (!(__width > 0))
								__width = _content.width;
							//if (!(__height > 0)) 
								__height = _content.height;
							
							_content.x = _center ? (__width - _content.width)/2 : 0;
							_content.y = _center ? (__height - _content.height)/2 : 0;
						}
						else
						{
							_content.width = __width;
							_content.height = __height;
						}
					}
				}
				else
				{
					if (!(__width > 0))
					__width = _content.width;
					if (!(__height > 0)) 
					__height = _content.height;
					_content.x = _center ? (__width - _content.width)/2 : 0;
					_content.y = _center ? (__height - _content.height)/2 : 0;
				}
			}
		}
		
		/**
		 * Load an external image.
		 * @private
		 */
		protected function load(str:String):void
		{
			if (_content)
				removeChild(_content);
				
			if (loader)
				loader.unload();
			else
			{
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad, false, 0, true);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus, false, 0, true);
			}
			
			_content = null;
			
			var c:LoaderContext = _context;
			if (!c)
				c = new LoaderContext();
			
			var req:URLRequest = new URLRequest(str);
			loader.load(req, c);
		}
		
		/**
		 * Called when a loader dispatches a complete event.
		 * @private
		 */
		protected function onImageLoad(e:Event):void
		{
			_content = loader.content;
			addChild(_content);
			doLayout();
			dispatchEvent(new Event(Container.E_RESIZE));
			dispatchEvent(new Event(E_COMPLETE));
		}
		
		/**
		 * Called when a progress event is dispatched from a loading process.
		 * @private
		 */
		protected function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e.clone());
		}
		
		/**
		 * @private
		 */
		protected function onIOError(e:IOErrorEvent):void
		{
			//trace("IOError: "+e.text);
			dispatchEvent(e.clone());
		}
		
		/**
		 * @private
		 */
		protected function onHttpStatus(e:HTTPStatusEvent):void
		{
			dispatchEvent(e.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void
		{
			if (loader)
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoad);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			}
			
			super.destroy();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getPreferredMetrics():Metrics
		{
			if (hasContent)
				return new Metrics(Math.min(_content.width, unscaledWidth), Math.min(_content.height, unscaledHeight));
			else
				return super.getPreferredMetrics();
		}
	}
}
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
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	/**
	 * Dispatched when an asset has completed loading.
	 * Event contains two custom properties:
	 * link - The original link that was requested
	 * bitmap - A BitmapData instance containing the image data
	 * @eventType razor.core.AssetCache.E_ASSET_COMPLETE
	 */
	[Event(name="assetComplete", type="razor.core.RazorEvent")]
	
	/**
	 * Dispatched when there are no more assets in the queue to be loaded.
	 * @eventType razor.core.AssetCache.E_QUEUE_COMPLETE
	 */
	[Event(name="queueComplete", type="razor.core.RazorEvent")]
	
	/**
	 * Dispatched when loading an asset generated an error.
	 * The event contains one custom property:
	 * link - The original link that was requested.
	 * @eventType razor.core.AssetCache.E_ASSET_ERROR
	 */
	[Event(name="assetError", type="razor.core.RazorEvent")]
	
	/**
	 * Load and cache remote assets as Bitmaps.
	 * This is used for bitmap based skins, so we dont have to load images multiple times per skin.
	 * You wouldn't normally instantiate this class directly. The Settings class keeps an AssetCache instance.
	 * @private
	 */
	public class AssetCache extends EventDispatcher
	{
		public static const E_ASSET_COMPLETE:String = "assetComplete";
		public static const E_QUEUE_COMPLETE:String = "queueComplete";
		public static const E_ASSET_ERROR:String = "assetError";
		
		private static var __id:Number = 0;
		private var _id:Number;
		
		/** @private */ protected var _queueLength:Number = 3;
		/** @private */ protected var cache:Object;
		/** @private */ protected var queue:Array;
		/** @private */ protected var loading:Object;
		/** @private */ protected var loadCount:Number = 0;
		/** @private */ protected var links:Dictionary;
		/** @private */ protected var loaders:Dictionary;
		/** @private */ protected var borked:Object;  // 'borked' is a technical term.
		
		/**
		 * Constructor. 
		 */
		public function AssetCache() 
		{
			_id = (++__id);
			cache = new Object();
			queue = new Array();
			loading = new Object();
			links = new Dictionary(true);
			loaders = new Dictionary(true);
			borked = new Object();
		}
		
		/**
		 * Retrieve an asset from the cache.
		 * If it hasn't been loaded yet, then load it automatically.
		 * @param link	The location of the asset to retrieve
		 * @return The asset BitmapData, or null if the asset hasn't loaded.
		 * 
		 */
		public function getAsset(link:String):BitmapData
		{
			if (link == null || link.length == 0)
				return null;
				
			if (cache[link] != undefined)
				return cache[link];
			
			if (loading[link] != undefined || borked[link] == true )
				return null;
			
			// Check if it is already in the queue
			var i:int = queue.length;
			while (--i >= 0)
				if (queue[i] == link)
					return null;
					
			queue.push(link);
			checkQueue();
			
			return null;
		}
		
		/**
		 * Retrieve an asset from the cache.
		 * If it hasn't been loaded yet, then load it automatically, but push it to the
		 * front of the queue (before any previously requested assets). 
		 * @param link	The location of the asset to retrieve
		 * @return	The asset BitmapData, or null if the asset hasn't loaded.
		 * 
		 */
		public function getAssetWithPriority(link:String):BitmapData
		{
			if (link == null || link.length == 0)
				return null;
				
			if (cache[link] != undefined)
				return cache[link];
			
			if (loading[link] != undefined)
				return null;
			
			// Check if it is already in the queue
			var i:int = queue.length;
			while (--i >= 0)
				if (queue[i] == link)
				{
					queue.splice(i,1);
					queue.unshift(link);
					return null;
				}
					
			queue.unshift(link);
			checkQueue();
			
			return null;
		}
		
		/**
		 * Check to see if there are any assets waiting to be loaded.
		 * @private
		 */
		protected function checkQueue():void
		{
			if (loadCount < _queueLength && queue.length > 0)
			{
				var link:String = String(queue.shift());
				
				var newLoader:Loader = new Loader();
				
				newLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				newLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
				newLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				newLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loadCount++;
				loading[link] = newLoader;
				loaders[newLoader.contentLoaderInfo] = newLoader;
				var req:URLRequest = new URLRequest(link);
				var lc:LoaderContext = new LoaderContext(true);
				// Since we're accessing the bitmapdata of each loaded image, we need to check
				// for a policy file to avoid security errors.
				//trace("AssetCache: loading: "+link);
				newLoader.load(req, lc);
				links[newLoader] = link;
				
				checkQueue();
			}
		}
		
		/**
		 * Called when an asset has loaded.
		 * @private
		 */
		protected function onComplete(e:Event):void
		{
			var li:LoaderInfo = e.target as LoaderInfo;
			var lo:Loader = li.loader;
			var content:DisplayObject = li.content;
			var link:String = links[lo];
			
			var bmp:BitmapData = new BitmapData(Math.ceil(content.width), Math.ceil(content.height), true, 0);
			bmp.draw(content, new Matrix(), null, BlendMode.NORMAL, null, false);
			
			cache[link] = bmp;
			
			cleanUp(li);
			
			dispatchEvent(new RazorEvent(E_ASSET_COMPLETE, { link: link, bitmap: bmp }));
			
			checkEmpty();
			
			li.loader.unload();
			
			checkQueue();
		}
		
		/**
		 * Called when a loading asset receives an http status event.
		 * Only status codes >= 400 are actual errors.
		 * @private
		 */
		protected function onHttpStatus(e:HTTPStatusEvent):void
		{
			if (e.status >= 400)
			{
				var loader:Loader = loaders[LoaderInfo(e.target)];
				var link:String = links[loader];
				cleanUp(e.target as LoaderInfo);
				borked[link] = true;
				
				trace("AssetCache http error: " + e.status);
				
				dispatchEvent(new RazorEvent(E_ASSET_ERROR, { link: link }));
			
				checkEmpty();
			}
		}
		
		/**
		 * Called on an IOError
		 * @private
		 */
		protected function onIOError(e:IOErrorEvent):void
		{
			var loader:Loader = loaders[LoaderInfo(e.target)];
			var link:String = links[loader];
			cleanUp(e.target as LoaderInfo);
			borked[link] = true;
			
			trace("AssetCache io error: " + e.text);
			
			dispatchEvent(new RazorEvent(E_ASSET_ERROR, { link: link } ));
			
			checkEmpty();
		}
		
		/**
		 * Check if the queue is empty, and dispatch an event if it is. 
		 * @private
		 */
		protected function checkEmpty():void
		{
			if (loadCount == 0 && queue.length == 0)
				dispatchEvent(new RazorEvent(E_QUEUE_COMPLETE));
		}
		
		/**
		 * Clean up data associated with a LoaderInfo object, so that it can be properly
		 * garbage collected.
		 * @param li	The LoaderInfo in question
		 * @private
		 */
		protected function cleanUp(li:LoaderInfo):void
		{
			var loader:Loader = loaders[li];
			delete loaders[li];
			var link:String = links[loader];
			delete links[loader];
			removeListeners(li);
			delete loading[link];
			
			loadCount--;
		}
		
		/**
		 * Called on file loading progress.
		 */
		protected function onProgress(e:ProgressEvent):void
		{
			
		}
		
		/**
		 * Remove all listeners from the loader.
		 */
		private function removeListeners(loaderInfo:LoaderInfo):void
		{
			loaderInfo.removeEventListener(Event.INIT, onComplete);
			loaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		}
	}
}
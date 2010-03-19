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

package razor.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	import razor.core.AssetCache;
	import razor.core.Container;
	import razor.core.IBordered;
	import razor.core.Metrics;
	import razor.core.RazorEvent;
	import razor.core.StyledContainer;
	import razor.core.razor_internal;

	/**
	 * Class to use an external bitmap as a skin element.
	 * @example Use this class as the base of a skin element, and assign the url and optional scaleNine properties.
	 * <listing version="3.0">
	 * var myStyleSheet:StyleSheet = new StyleSheet({url: "./images/coffee_bg.png", scaleNine: [6,6,6,6]}, SkinBitmap);
	 * 
	 * </listing>
	 */
	public class SkinBitmap extends StyledContainer
		implements IBordered
	{
		use namespace razor_internal;
		
		/** @private */ protected var asset:BitmapData;
		/** @private */ protected var nineBitmaps:Array;
		/** @private */ protected var sliceIt:Boolean = false;
		/** @private */ protected var wasLinked:Boolean = false;
		/** @private */ protected var clip:DisplayObject;
		
		public function SkinBitmap() 
		{
			//trace("new skinbitmap");
		}
		
		/** @private */
		override protected function construct():void
		{
			// Because we're possibly loading a bitmap, we need to delay dispatching the INIT event
			// until this component is ready.
			
			if  (__style && __style.skinClass)
			{
				var cz:Class = __style.skinClass;
				clip = new cz();
				if (clip != null)
				{
					if (clip.scale9Grid)
					{
						wasLinked = true;
						addChild(clip);
					}
					else
					{
						asset = new BitmapData(Math.ceil(clip.width), Math.ceil(clip.height), true, 0);
						asset.draw(clip, new Matrix(), null, BlendMode.NORMAL, null, false);
						clip = null;
						wasLinked = true;
						prepareImage(asset);
					}
					loadComplete();
				}
			}
			else if (__style && __style.linkage && __style.linkage.length > 0)
			{
				try
				{
					var c:Class = flash.utils.getDefinitionByName(__style.linkage) as Class;
				}
				catch (e:Error)
				{
					//trace("SkinBitmap: bad linkage, attempting to load: " + __style.linkage);
					asset = Settings.assets.getAsset(__style.linkage);
					
					if (asset == null)
					{
						Settings.assets.addEventListener(AssetCache.E_ASSET_COMPLETE, onAssetComplete);
						Settings.assets.addEventListener(AssetCache.E_ASSET_ERROR, onAssetError);
						__pendingConstruction++;
					}
					else
					{
						prepareImage(asset);
						loadComplete();
					}
					
					return;
				}
				if (c != null)
				clip = new c();
				if (clip != null)
				{
					asset = new BitmapData(Math.ceil(clip.width), Math.ceil(clip.height), true, 0);
					asset.draw(clip, new Matrix(), null, BlendMode.NORMAL, null, false);
					clip = null;
					wasLinked = true;
					prepareImage(asset);
					loadComplete();
				}
			}
			else if (__style && __style.url && __style.url.length > 0)
			{
				asset = Settings.assets.getAsset(__style.url);
				
				if (asset == null)
				{
					Settings.assets.addEventListener(AssetCache.E_ASSET_COMPLETE, onAssetComplete);
					Settings.assets.addEventListener(AssetCache.E_ASSET_ERROR, onAssetError);
					__pendingConstruction++;
				}
				else
				{
					prepareImage(asset);
					loadComplete();
				}
			}
		}
		
		/** @private */
		override protected function layout():void
		{
			// TODO: scale9Grid conversion..
			var w:Number = __width - __style.margin_l - __style.margin_r;
			var h:Number = __height - __style.margin_t - __style.margin_b;
				
			if (!sliceIt)
			{
				if (clip != null)
				{
					clip.x = __style.margin_l;
					clip.y = __style.margin_t;
					clip.width = w;
					clip.height = h;
				}
			}
			else
			{
				var s:Array = __style.scaleNine;
				var l:Number = s[0];
				var t:Number = s[1];
				var r:Number = s[2];
				var b:Number = s[3];
				var xx:Number = __style.margin_l;
				var yy:Number = __style.margin_t;
				
				nineBitmaps[0].x = nineBitmaps[3].x = nineBitmaps[6].x = xx;
				nineBitmaps[0].y = nineBitmaps[1].y = nineBitmaps[2].y = yy;
				nineBitmaps[1].x = nineBitmaps[4].x = nineBitmaps[7].x = xx+l;
				nineBitmaps[3].y = nineBitmaps[4].y = nineBitmaps[5].y = yy+t;
				nineBitmaps[2].x = nineBitmaps[5].x = nineBitmaps[8].x = w-r;
				nineBitmaps[6].y = nineBitmaps[7].y = nineBitmaps[8].y = h-b;
				
				nineBitmaps[1].width = nineBitmaps[4].width = nineBitmaps[7].width = Math.ceil(w - r - l);
				nineBitmaps[3].height = nineBitmaps[4].height = nineBitmaps[5].height = Math.ceil(h - b - t);
			}
		}
		
		/**
		 * Slice up our bitmap (or not).
		 * @private
		 */
		protected function prepareImage(bmp:BitmapData):void
		{
			var s:Array = __style.scaleNine;  // [l,t,r,b]
			
			if (s)
			{
				
				var l:Number = s[0];
				var t:Number = s[1];
				var r:Number = s[2];
				var b:Number = s[3];
				var o:Point = new Point(0,0);
				var w:Number = bmp.width;
				var h:Number = bmp.height;
				
				sliceIt = true;
				nineBitmaps = new Array();
				/*
				var bmp0:BitmapData = new BitmapData(l,t,true,0);
				bmp0.copyPixels(bmp, new Rectangle(0,0,l,t), o);
				nineBitmaps[0] = new Bitmap(bmp0, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[0]);
				
				var bmp1:BitmapData = new BitmapData(w-r-l,t,true,0);
				bmp1.copyPixels(bmp, new Rectangle(l+1,0,w-r-l,t), o);
				nineBitmaps[1] = new Bitmap(bmp1, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[1]);
				
				var bmp2:BitmapData = new BitmapData(r,t,true,0);
				bmp2.copyPixels(bmp, new Rectangle(w-r+1,0,r,t), o);
				nineBitmaps[2] = new Bitmap(bmp2, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[2]);
				//
				var bmp3:BitmapData = new BitmapData(l,h-t-b,true,0);
				bmp3.copyPixels(bmp, new Rectangle(0,t+1,l,h-t-b), o);
				nineBitmaps[3] = new Bitmap(bmp3, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[3]);
				
				var bmp4:BitmapData = new BitmapData(w-r-l,h-t-b,true,0);
				bmp4.copyPixels(bmp, new Rectangle(l+1,t+1,w-r-l,h-t-b), o);
				nineBitmaps[4] = new Bitmap(bmp4, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[4]);
				
				var bmp5:BitmapData = new BitmapData(r,h-t-b,true,0);
				bmp5.copyPixels(bmp, new Rectangle(w-r+1,t+1,r,h-t-b), o);
				nineBitmaps[5] = new Bitmap(bmp5, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[5]);
				//
				var bmp6:BitmapData = new BitmapData(l,b,true,0);
				bmp6.copyPixels(bmp, new Rectangle(0,h-b+1,l,b), o);
				nineBitmaps[6] = new Bitmap(bmp6, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[6]);
				
				var bmp7:BitmapData = new BitmapData(w-r-l,b,true,0);
				bmp7.copyPixels(bmp, new Rectangle(l+1,h-b+1,w-r-l,b), o);
				nineBitmaps[7] = new Bitmap(bmp7, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[7]);
				
				var bmp8:BitmapData = new BitmapData(r,b,true,0);
				bmp8.copyPixels(bmp, new Rectangle(w-r+1,h-b+1,r,b), o);
				nineBitmaps[8] = new Bitmap(bmp8, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[8]);
				*/
				var bmp0:BitmapData = new BitmapData(l,t,true,0);
				bmp0.copyPixels(bmp, new Rectangle(0,0,l,t), o);
				nineBitmaps[0] = new Bitmap(bmp0, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[0]);
				
				var bmp1:BitmapData = new BitmapData(w-r-l,t,true,0);
				bmp1.copyPixels(bmp, new Rectangle(l,0,w-r-l,t), o);
				nineBitmaps[1] = new Bitmap(bmp1, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[1]);
				
				var bmp2:BitmapData = new BitmapData(r,t,true,0);
				bmp2.copyPixels(bmp, new Rectangle(w-r,0,r,t), o);
				nineBitmaps[2] = new Bitmap(bmp2, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[2]);
				//
				var bmp3:BitmapData = new BitmapData(l,h-t-b,true,0);
				bmp3.copyPixels(bmp, new Rectangle(0,t,l,h-t-b), o);
				nineBitmaps[3] = new Bitmap(bmp3, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[3]);
				
				var bmp4:BitmapData = new BitmapData(w-r-l,h-t-b,true,0);
				bmp4.copyPixels(bmp, new Rectangle(l,t,w-r-l,h-t-b), o);
				nineBitmaps[4] = new Bitmap(bmp4, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[4]);
				
				var bmp5:BitmapData = new BitmapData(r,h-t-b,true,0);
				bmp5.copyPixels(bmp, new Rectangle(w-r,t,r,h-t-b), o);
				nineBitmaps[5] = new Bitmap(bmp5, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[5]);
				//
				var bmp6:BitmapData = new BitmapData(l,b,true,0);
				bmp6.copyPixels(bmp, new Rectangle(0,h-b,l,b), o);
				nineBitmaps[6] = new Bitmap(bmp6, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[6]);
				
				var bmp7:BitmapData = new BitmapData(w-r-l,b,true,0);
				bmp7.copyPixels(bmp, new Rectangle(l,h-b,w-r-l,b), o);
				nineBitmaps[7] = new Bitmap(bmp7, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[7]);
				
				var bmp8:BitmapData = new BitmapData(r,b,true,0);
				bmp8.copyPixels(bmp, new Rectangle(w-r,h-b,r,b), o);
				nineBitmaps[8] = new Bitmap(bmp8, PixelSnapping.ALWAYS);
				addChild(nineBitmaps[8]);
				
				// if asset bitmap was linked from the library, we can dispose of it
				// if asset was retrieved from the cache, we dont dispose it because it is stored in the cache.
				if (wasLinked) bmp.dispose();
			}
			else
			{
				clip = new Bitmap(bmp, "auto", true);
				addChild(clip);
			}
		}
		
		/**
		 * Called when an asset has finished loading in the AssetCache.
		 */
		protected function onAssetComplete(e:RazorEvent):void
		{
			if (e.link != __style.url && e.link != __style.linkage)
				return;
				
			asset = e.bitmap;
			
			Settings.assets.removeEventListener(AssetCache.E_ASSET_COMPLETE, onAssetComplete);
			Settings.assets.removeEventListener(AssetCache.E_ASSET_ERROR, onAssetError);
			__pendingConstruction--;
			prepareImage(asset);
			loadComplete();
		}
		
		protected function onAssetError(e:RazorEvent):void
		{
			if (e.link != __style.url)
				return;
				
			Settings.assets.removeEventListener(AssetCache.E_ASSET_COMPLETE, onAssetComplete);
			Settings.assets.removeEventListener(AssetCache.E_ASSET_ERROR, onAssetError);
			__pendingConstruction--;
			
			loadComplete();
		}
		
		/** @private */
		protected function loadComplete():void
		{
			//trace("load complete! "+__style.url);
			dispatchEvent(new Event(Container.E_INIT));
			layout();
		}
		
		/** @private */
		public function getBorderMetrics():Metrics
		{
			return new Metrics(0,0, __style.margin_l, __style.margin_r, __style.margin_t, __style.margin_b );
		}
	}
}
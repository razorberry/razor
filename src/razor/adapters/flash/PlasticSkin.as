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

package razor.adapters.flash
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import razor.core.Container;
	import razor.skins.Settings;
	import razor.skins.plastic.PlasticStyleSheet;
	import razor.skins.plastic.Rectangle;
	import razor.skins.plastic.RectangleGloss;
	import razor.skins.plastic.presets.*;

	public class PlasticSkin extends Container
	{
		public static var skinSet:Boolean = false;
		public static var initialized:Boolean = false;
		
		private var bg:Rectangle;
		private var gloss:RectangleGloss;
		
		private var presets:Array = [Default, Winter, Regular, Sharp, Plain, Glass, Midnight, Bubblegum];
		
		public function PlasticSkin()
		{
			if (!skinSet)
			{
				Settings.setSkin(new PlasticStyleSheet());
				skinSet = true;
			}
			
			if (numChildren > 0) {
				removeChildAt(0);
			}
			
			drawPreview();
		}
		
		[Inspectable(name="Default Style", type=String, enumeration="Default,Winter,Regular,Sharp,Plain,Glass,Midnight,Bubblegum", defaultValue="Default")]
		public function set defaultStyle(str:String):void
		{
			var c:Class;
			try
			{
				c = getDefinitionByName("razor.skins.plastic.presets."+str) as Class;
			}
			catch (e:Error)
			{
				
			}
			
			if (c)
				Settings.style = new c();
				
			drawPreview();
		}
		
		private function drawPreview():void
		{
			if (checkLivePreview())
			{
				if (bg) bg.destroy();
				
				bg = new Rectangle();
				bg.setSize(20,20);
				addChild(bg);
				
				if (gloss) gloss.destroy();
				
				gloss = new RectangleGloss();
				gloss.setSize(20,20);
				addChild(gloss);
			}
		}
		
		protected function checkLivePreview():Boolean 
		{
			if (parent == null) { return false; }
			var className:String;
			try {
			className = flash.utils.getQualifiedClassName(parent);
			} catch (e:Error) {}
			return (className == "fl.livepreview::LivePreviewParent");
		}
		
	}
}
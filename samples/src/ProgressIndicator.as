/**
 * This class included with thanks to Todd Anderson. Modified slightly to extend Container.
 * 
   @class  			ProgressIndicator
   @author 			Todd Anderson :: http://custardbelly.com/blog
   @example 		
					<pre>
						var prog:ProgressIndicator = new ProgressIndicator();
						addChild(prog);
						
						prog.angle = 1;					// 1 : moves left to right. -1 : moves right to left.
						prog.speed = 2;
						prog.baseColor = 0xFFFFFEEE;
						prog.bandColor = 0xFF1B99FF;
						prog.borderColor = 0xFF999999;
						prog.borderThickness = 0;		//thickness of border
						prog.bandWidth = 10;			//width of individual band
						
						prog.x = prog.y = 10;
						prog.setSize(200, 10);			//size
						
						prog.animate();
					</pre>
   @tooltip 		Indiscriptive progress barberpole.
   
   This is released under a Creative Commons Attribution 2.5 License. 
    More information can be found here:
    
    http://creativecommons.org/licenses/by/2.5/
    ---------------------------------------------
*/
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.*;
	
	import razor.core.razor_internal;
	import razor.core.Container;

	public class ProgressIndicator extends Container
	{
		use namespace razor_internal;
		
		private var __base:BitmapData = null;
		private var __output:BitmapData = null;
		
		private var __bar:Bitmap;
		private var __border:Sprite;
		private var __showBorder:Boolean = true;
		
		private var __matrix:Matrix;
		private var __firstBand:Rectangle;
		private var __secondBand:Rectangle;
		private var __scrollPos:int = 0;
		private var __scrollLimit:int;
		private var __speed:int = 2;
		private var __angle:int = 1;
		
		private var __bandWidth:int = 10;
		private var __baseColor:uint = 0xFFFFFEEE;
		private var __bandColor:uint = 0xFF6BC9FF;
		private var __borderColor:uint = 0xFF999999;
		private var __borderThickness:int = 1;
		
		public function ProgressIndicator()
		{
			
		}
		
		override protected function construct():void
		{
			__border = new Sprite();
			this.addChildAt(__border, 0);
			animate();
		}
		
		override protected function layout():void
		{
			if (!(__width > 0 && __height > 0))
				return;
				
			var adjacent:Number = __height / Math.tan( 30 * Math.PI / 180 );
			var hypot:Number = Math.sqrt(__height * __height + adjacent * adjacent);
			var amt:int = Math.ceil( adjacent / __bandWidth );
			var cutoff:int = ( __bandWidth * 2 );
			var extra:int = ( __bandWidth * amt ) + cutoff;
			var srcWidth:int = __width + extra;
			var px:int = ( __speed > 0 ) ? 0 : __width;
			var len:int = srcWidth / __bandWidth;
			var i:int;
			
			// tranform matrix to apply to output
			__matrix = new Matrix();
			__matrix.c = __angle;
			__matrix.tx = -extra + ( ( __angle > 0 ) ? 0 : adjacent );
			
			// base BitmapData
			if (__base) __base.dispose();
			
			__base = new BitmapData(srcWidth, __height, false, __baseColor);
			for(i = 0; i < len; i++)
			{
				__base.fillRect(new Rectangle(( i * __bandWidth ) * 2, 0, __bandWidth, __height), __bandColor);
			}
			// rect objects for addition during scroll
			__firstBand = new Rectangle(px, 0, __bandWidth, __height);
			__secondBand = new Rectangle(px + __bandWidth, 0, __bandWidth, __height);
			
			// output
			
			if (__output)
			{
				removeChildAt(0);
				__output.dispose();
			}
			
			__output = new BitmapData(__width, __height, true, 0xFF);
			this.addChildAt(new Bitmap(__output), 0);
			
			//limit
			var limit:int = Math.floor( ( __bandWidth * 2 ) /  __speed );
			__scrollLimit = ( __speed * ( limit ) );
			
			setBorder();
		}
		
		protected function scroll(evt:Event):void
		{
			if (__base && __output)
			{
				__base.scroll(__speed, 0);
				__scrollPos += __speed;
				if( ( __scrollPos % __scrollLimit ) == 0 )
				{
					__base.fillRect(__firstBand, bandColor);
					__base.fillRect(__secondBand, baseColor);
				}
				
				__output.draw(__base, __matrix);
			}
		}
		
		private function setBorder():void
		{
			__border.graphics.clear();
			
			if(!__showBorder) return;
			
			var inset:int = __borderThickness / 2;
			var wLimit:int = __width - inset;
			var hLimit:int = __height - inset;
			__border.graphics.lineStyle(__borderThickness, __borderColor, 100, false, "normal", "none", "miter");
			__border.graphics.moveTo(inset, inset);
			__border.graphics.lineTo(wLimit, inset);
			__border.graphics.lineTo(wLimit, hLimit);
			__border.graphics.lineTo(inset, hLimit);
			__border.graphics.lineTo(inset, inset);
		}
		
		override public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, scroll);
			__base.dispose();
			__output.dispose();
			removeChild(__border);
			
			super.destroy();
		}
		
		public function animate():void
		{
			if(!this.hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, scroll);
		}
		
		public function showBorder(b:Boolean):void
		{
			__showBorder = b;
			setBorder();
		}
		
		public function set baseColor(col:uint):void
		{
			__baseColor = col;
			doLayout();
		}
		public function get baseColor():uint
		{
			return __baseColor;
		}
		
		public function set bandColor(col:uint):void
		{
			__bandColor = col;
			doLayout();
		}
		public function get bandColor():uint
		{
			return __bandColor;
		}
		
		public function set borderColor(col:uint):void
		{
			__borderColor = col;
			setBorder();
		}
		public function get borderColor():uint
		{
			return __borderColor;
		}
		
		public function set borderThickness(num:int):void
		{
			__borderThickness = num;
			setBorder();
		}
		public function get borderThickness():int
		{
			return __borderThickness;
		}
		
		public function set bandWidth(num:int):void
		{
			__bandWidth = num;
			doLayout();
		}
		public function get bandWidth():int
		{
			return __bandWidth;
		}
		
		public function set speed(amt:int):void
		{
			__speed = amt;
			doLayout();
		}
		public function get speed():int
		{
			return __speed;
		}
		
		public function set angle(num:int):void
		{
			__angle = ( num > 0 ) ? 1 : -1;
			doLayout();
		}
		public function get angle():int
		{
			return __angle;
		}
	}
}
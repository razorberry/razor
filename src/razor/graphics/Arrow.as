package razor.graphics
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import razor.core.StyledContainer;
	
	/**
	 * Draw an arrow..
	 * @private
	 */
	public class Arrow extends StyledContainer
	{
		protected var arrow:Sprite;
		protected var _rotation:Number;
		
		override protected function construct():void
		{
			arrow = addChild(new Sprite()) as Sprite;
		}
		
		override protected function layout():void
		{
			arrow.x = __width/2;
			arrow.y = __height/2;
			arrow.rotation = _rotation;
			
			var g:Graphics = arrow.graphics;
			g.clear();
			
			var fill:uint = __style.border >= 0 ? __style.border : 0;
			g.beginFill(fill);
			g.moveTo(__width/4 - __width/2,__height/6 - __height/2);
			g.lineTo(__width*5/6  - __width/2,__height/2 - __height/2);
			g.lineTo(__width/4  - __width/2,__height*5/6 - __height/2);
			g.endFill();
		}
		
		override public function set rotation(value:Number):void
		{
			_rotation = value;
			if (arrow)
			arrow.rotation = _rotation;
		}
		
		override public function get rotation():Number
		{
			return _rotation;
		}
	}
}
package razor.adapters.degrafa
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import razor.core.Container;
	import razor.core.razor_internal;
	import com.degrafa.GeometryGroup;
	import com.degrafa.IGeometry;
	//import com.degrafa.GeometryGroup;
	//import com.degrafa.IGeometry;
	
	[DefaultProperty("children")]
	public class RazorDegrafaSurface extends Container
	{
		use namespace razor_internal;
		
		protected var group:GeometryGroup;
		
		public function RazorDegrafaSurface()
		{
			super();
			
			group = new GeometryGroup();
			addChild(group);
		}
		
		override protected function construct() : void
		{
			super.construct();
			
		}
		
		override protected function layout() : void
		{
			super.layout();
			
			if (group)
			group.draw(graphics, new Rectangle(0,0,__width,__height));
		}
		
		override public function addChild(child:DisplayObject) : DisplayObject
		{
			var child:DisplayObject;
			
			if (child is IGeometry && child != group)
			{
				group.geometryCollection.addItem(child as IGeometry);
			}
			else
			{
				super.addChild(child);
			}
			
			return child;
		}
		
		public function set children(value:Array) : void
		{
			while ( numChildren > 0 )
			{
				removeChildAt( 0 );
			}
			
			addChild(group);
			
			for (var i:int = 0; i < value.length; i++)
			{
				if (!(value[i] is IGeometry))
				addChild( value[i] );
			}
			
			group.geometry = value;
			
			doLayout();
		}
		
		public function get children():Array
		{
			return group.geometry;
		}
		
		protected var _fills:Array;
		public function set fills(a:Array):void
		{
			_fills = a;
		}
		public function get fills():Array
		{
			return _fills;
		}
		protected var _strokes:Array;
		public function set strokes(a:Array):void
		{
			_strokes = a;
		}
		public function get strokes():Array
		{
			return _strokes;
		}
		
		public function set geometry(a:Array):void
		{
			children = a;
		}
		public function get geometry():Array
		{
			return children;
		}
		
	}
}
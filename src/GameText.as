package
{
	import org.flixel.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.engine.TabStop;
	import flash.text.engine.TabAlignment;
	import flash.display.Graphics;
	
	public class GameText extends FlxText
	{		
		public var game:VideoGame;
		/**
		* Internal tracker for the tab stops, measured in pixels;
		*/
		protected var _tabStops:Array;
		
		public function GameText(Game:VideoGame, X:Number = 0, Y:Number = 0, Text:String=null, EmbeddedFont:Boolean=true)
		{
			super(X, Y, Game.width - X * 2, Text, EmbeddedFont);
			
			_tabStops = null;

			game = Game;
			antialiasing = false;
			tabStops = [22, 81];
			
			/*tabStops.push(
				new TabStop(TabAlignment.START, 28),
				//new TabStop(TabAlignment.CENTER, 120),
				//new TabStop(TabAlignment.DECIMAL, 220, "."),
				new TabStop(TabAlignment.END, 108)
			);*/ 
		}
		
		override public function update():void
		{
			super.update();
		}
		
		override public function draw():void
		{
			drawOntoSprite(game.gamePixels);
		}
		
		public function drawOntoSprite(Sprite:FlxSprite):void
		{
			if(_flickerTimer != 0)
			{
				_flicker = !_flicker;
				if(_flicker)
					return;
			}
			
			if(dirty)	//rarely 
				calcFrame();
			
			_point.x = x - offset.x;
			_point.y = y - offset.y;
			_point.x += (_point.x > 0)?0.0000001:-0.0000001;
			_point.y += (_point.y > 0)?0.0000001:-0.0000001;
			if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null)) //&& (skew.x == 0) && (skew.y == 0)
			{	//Simple render
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				Sprite.framePixels.copyPixels(framePixels,_flashRect,_flashPoint,null,null,true);
			}
			else
			{	//Advanced render
				_matrix.identity();
				//_matrix.concat(new flash.geom.Matrix(1, skew.y, skew.x, 1, 0, 0));//***
				_matrix.translate(-origin.x,-origin.y);
				_matrix.scale(scale.x,scale.y);
				if((angle != 0) && (_bakedRotation <= 0))
					_matrix.rotate(angle * 0.017453293);
				_matrix.translate(_point.x+origin.x,_point.y+origin.y);
				Sprite.framePixels.draw(framePixels,_matrix,null,blend,null,antialiasing);
			}
			if(FlxG.visualDebug && !ignoreDrawDebug) drawDebugOntoSprite(Sprite);
		}
		
		public function drawDebugOntoSprite(Sprite:FlxSprite):void
		{
			//get bounding box coordinates
			var boundingBoxX:Number = x;// - int(Camera.scroll.x*scrollFactor.x); //copied from getScreenXY()
			var boundingBoxY:Number = y;// - int(Camera.scroll.y*scrollFactor.y);
			boundingBoxX = int(boundingBoxX + ((boundingBoxX > 0)?0.0000001:-0.0000001));
			boundingBoxY = int(boundingBoxY + ((boundingBoxY > 0)?0.0000001:-0.0000001));
			var boundingBoxWidth:int = (width != int(width))?width:width-1;
			var boundingBoxHeight:int = (height != int(height))?height:height-1;
			
			//fill static graphics object with square shape
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			gfx.moveTo(boundingBoxX,boundingBoxY);
			var boundingBoxColor:uint;
			if(allowCollisions)
			{
				if(allowCollisions != ANY)
					boundingBoxColor = FlxG.PINK;
				if(immovable)
					boundingBoxColor = FlxG.GREEN;
				else
					boundingBoxColor = FlxG.RED;
			}
			else
				boundingBoxColor = FlxG.BLUE;
			gfx.lineStyle(1,boundingBoxColor,0.5);
			gfx.lineTo(boundingBoxX+boundingBoxWidth,boundingBoxY);
			gfx.lineTo(boundingBoxX+boundingBoxWidth,boundingBoxY+boundingBoxHeight);
			gfx.lineTo(boundingBoxX,boundingBoxY+boundingBoxHeight);
			gfx.lineTo(boundingBoxX,boundingBoxY);
			
			//draw graphics shape to camera buffer
			Sprite.framePixels.draw(FlxG.flashGfxSprite);
		}
		
		public function get tabStops():Array
		{
			return _tabStops;
		}
		
		/**
		 * An array of numbers, measured in pixels, representing the position of each tab stop.
		 */
		public function set tabStops(TabArray:Array):void
		{
			_tabStops = TabArray;
			var format:TextFormat = dtfCopy();
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			_regen = true;
			calcFrame();
		}
		
		override protected function dtfCopy():TextFormat
		{
			var defaultTextFormat:TextFormat = _textField.defaultTextFormat;
			defaultTextFormat = new TextFormat(defaultTextFormat.font,defaultTextFormat.size,defaultTextFormat.color,defaultTextFormat.bold,defaultTextFormat.italic,defaultTextFormat.underline,defaultTextFormat.url,defaultTextFormat.target,defaultTextFormat.align);
			defaultTextFormat.tabStops = tabStops;
			return defaultTextFormat;
		}
	}
}
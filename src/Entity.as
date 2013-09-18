package
{
	import flash.display.Graphics;
	
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{		
		public static const NONE:uint = 0x00000000;
		public static const UP:uint = 0x10000000;
		public static const DOWN:uint = 0x01000000;
		public static const LEFT:uint = 0x00100000;
		public static const RIGHT:uint = 0x00010000;
		public static const SELECT:uint = 0x00001000;
		public static const START:uint = 0x00000100;
		public static const BUTTON_A:uint = 0x00000010;
		public static const BUTTON_B:uint = 0x00000001;
		public static const DPAD:uint = UP | DOWN | LEFT | RIGHT;
		public static const INPUTS:Array = [UP, DOWN, LEFT, RIGHT, SELECT, START, BUTTON_A, BUTTON_B];
		
		//public static const GRAVITY:uint = 400;
		
		public var input:Entity;
		public var inputs:Array;
		public var game:VideoGame;
		public var shotSpeed:Number;
		protected var _speed:Number;
		public var diagonalSpeed:Number;
		public var acceptInput:Boolean = false;
		public var controls:uint = 0x00000000;
		public var lastControls:uint = 0x00000000;
		public var target:FlxPoint;
		
		public var z:Number = 0;
		public var lastZ:Number = 0;
		public var zVelocity:Number = 0;
		
		[Embed(source="assets/sounds/ActivateShields01.mp3")] public static var sfxActivateShields01:Class;
		[Embed(source="assets/sounds/ActivateShields02.mp3")] public static var sfxActivateShields02:Class;
		[Embed(source="assets/sounds/ActivateShields03.mp3")] public static var sfxActivateShields03:Class;
		[Embed(source="assets/sounds/ActivateShields04.mp3")] public static var sfxActivateShields04:Class;
		[Embed(source="assets/sounds/ActivateShields04.mp3")] public static var sfxActivateShields05:Class;
		public static var sfxActivateShields:Array = [sfxActivateShields01, sfxActivateShields02, sfxActivateShields03, sfxActivateShields04, sfxActivateShields05];
		
		[Embed(source="assets/sounds/Explosion01.mp3")] public static var sfxExplosion01:Class;
		[Embed(source="assets/sounds/Explosion02.mp3")] public static var sfxExplosion02:Class;
		[Embed(source="assets/sounds/Explosion03.mp3")] public static var sfxExplosion03:Class;
		[Embed(source="assets/sounds/Explosion04.mp3")] public static var sfxExplosion04:Class;
		public static var sfxExplosion:Array = [sfxExplosion01, sfxExplosion02, sfxExplosion03, sfxExplosion04];
		
		[Embed(source="assets/sounds/HighScore01.mp3")] public static var sfxHighScore01:Class;
		public static var sfxHighScore:Array = [sfxHighScore01];
		
		[Embed(source="assets/sounds/Laser01.mp3")] public static var sfxLaser01:Class;
		[Embed(source="assets/sounds/Laser02.mp3")] public static var sfxLaser02:Class;
		[Embed(source="assets/sounds/Laser03.mp3")] public static var sfxLaser03:Class;
		[Embed(source="assets/sounds/Laser04.mp3")] public static var sfxLaser04:Class;
		[Embed(source="assets/sounds/Laser05.mp3")] public static var sfxLaser05:Class;
		[Embed(source="assets/sounds/Laser06.mp3")] public static var sfxLaser06:Class;
		[Embed(source="assets/sounds/Laser07.mp3")] public static var sfxLaser07:Class;
		[Embed(source="assets/sounds/Laser08.mp3")] public static var sfxLaser08:Class;
		public static var sfxLaser:Array = [sfxLaser01, sfxLaser02, sfxLaser03, sfxLaser04, sfxLaser05, sfxLaser06, sfxLaser07, sfxLaser08];
		
		//Pickup_Coin
		//Powerup
		
		[Embed(source="assets/sounds/ShieldsReady01.mp3")] public static var sfxShieldsReady01:Class;
		[Embed(source="assets/sounds/ShieldsReady02.mp3")] public static var sfxShieldsReady02:Class;
		[Embed(source="assets/sounds/ShieldsReady03.mp3")] public static var sfxShieldsReady03:Class;
		[Embed(source="assets/sounds/ShieldsReady04.mp3")] public static var sfxShieldsReady04:Class;
		[Embed(source="assets/sounds/ShieldsReady05.mp3")] public static var sfxShieldsReady05:Class;
		[Embed(source="assets/sounds/ShieldsReady06.mp3")] public static var sfxShieldsReady06:Class;
		public static var sfxShieldsReady:Array = [sfxShieldsReady01, sfxShieldsReady02, sfxShieldsReady03, sfxShieldsReady04, sfxShieldsReady05, sfxShieldsReady06];
		
		public function Entity(X:Number = 0, Y:Number = 0, Game:VideoGame = null)
		{
			super(X, Y);
			
			inputs = new Array(0);
			
			if (Game) game = Game;
		}
		
		override public function update():void
		{
			super.update();
			
			lastControls = controls;
			controls = 0x00000000;
			if (inputs.length > 0 && acceptInput)
			{
				for each (input in inputs)
				{
					controls |= input.controls;
				}
			}
			else controls = defaultInput();
			
			translateInput();
		}
		
		override public function draw():void
		{
			if (game)
			{
				if (game.gamePixels) 
				{
					drawOntoSprite(game.gamePixels);
				}
				else super.draw();
			}
			else super.draw();
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
		
		public function drawLineOntoSprite(Sprite:FlxSprite, StartX:Number,StartY:Number,EndX:Number,EndY:Number,Color:uint,Thickness:uint=1):void
		{
			//Draw line
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			gfx.moveTo(StartX,StartY);
			var alphaComponent:Number = Number((Color >> 24) & 0xFF) / 255;
			if(alphaComponent <= 0)
				alphaComponent = 1;
			gfx.lineStyle(Thickness,Color,alphaComponent);
			gfx.lineTo(EndX,EndY);
			
			//Cache line to bitmap
			Sprite.framePixels.draw(FlxG.flashGfxSprite);
			dirty = true;
		}
		
		public function moveTowardTarget(Centered:Boolean = false, SpeedMultiplier:Number = 1):void
		{
			if (!Centered && x == target.x && y == target.y) return;
			if (Centered && x == target.x - width / 2 && y == target.y - height / 2) return;
			
			var _dist:Number;
			var _ratio:Number;
			_point.x = x;
			_point.y = y;
			if (Centered)
			{
				_point.x += width / 2;
				_point.y += height / 2;
			}
			_dist = FlxU.getDistance(_point, target);
			_ratio = (speed * FlxG.elapsed * SpeedMultiplier) / _dist;
			if (_ratio >= 1)
			{
				x = target.x;
				y = target.y;
				if (Centered)
				{
					x -=  width / 2;
					y -= height / 2;
				}
			}
			else
			{
				if (Centered)
				{
					x = (1 - _ratio) * x + _ratio * (target.x - width / 2);
					y = (1 - _ratio) * y + _ratio * (target.y - height / 2);
				}
				else
				{
					x = (1 - _ratio) * x + _ratio * (target.x);
					y = (1 - _ratio) * y + _ratio * (target.y);
				}
			}
			
		}
		
		public function get speed():Number
		{
			return _speed;
		}
		
		public function set speed(Value:Number):void
		{
			_speed = Value;
			diagonalSpeed = Value * Math.sqrt(2)/2;
		}
		
		public function removeFromPlay():void
		{
			alive = false;
			exists = false;
		}
		
		public static function playRandomSound(Sounds:Array, VolumeMultiplier:Number = 1.0):void
		{
			var _seed:Number = Math.floor(Sounds.length * Math.random());
			FlxG.play(Sounds[_seed], VolumeMultiplier, false, false);
		}
		
		public function defaultInput():uint
		{
			return 0x00000000;
		}
		
		public function translateInput():void
		{
			
		}
		
		public function onHitGround():void
		{
			z = 0;
			zVelocity = 0;
		}
	}
}
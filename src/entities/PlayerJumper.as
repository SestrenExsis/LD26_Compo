package entities
{
	import games.*;
	
	import org.flixel.*;
	
	public class PlayerJumper extends Entity
	{
		[Embed(source="../assets/images/jungles.png")] protected static var imgJungles:Class;
		
		private static var kUp:String = "W";
		private static var kDown:String = "S";
		private static var kLeft:String = "A";
		private static var kRight:String = "D";
		private static var kJump:String = "SPACE";
		
		private var alreadyMoving:Boolean = false;
		private var deathTimer:FlxTimer;
		
		public var shotsInPlay:uint = 0;
		public var lifeString:String = "^^^";
		private var jumpHeight:Number = 24;
		private var jumpSpeed:Number;
		public var object:JungleBlock;		
		public var floor:Number = 0;
		
		protected var _lives:uint = 4;
		public var onGround:Boolean = false;
		public var wasOnGround:Boolean = false;
		public var onLadder:Boolean = false;
		
		public function PlayerJumper(Game:GamePitJumper)
		{
			super(6, 32);
			
			//inputs.push(Game);
			game = Game;
			loadGraphic(imgJungles, true, true, 16, 16);
			addAnimation("none", [9]);
			addAnimation("idle", [4]);
			addAnimation("lookup", [5]);
			addAnimation("run", [2, 1, 0, 1], 8, true);
			addAnimation("jump", [0]);
			addAnimation("swing", [3]);
			
			width = 8;
			height = 14;
			offset.x = 4;
			offset.y = 2;
			x -= width / 2;
			y -= frameHeight;
			color = 0xcd853f;
			speed = 50;
			play("idle");
			jumpSpeed = Math.sqrt(2 * game.gravity * jumpHeight);
			deathTimer = new FlxTimer();
			target = new FlxPoint();
			FlxG.watch(this, "onLadder");
			FlxG.watch(this, "object");
		}
		
		override public function update():void
		{
			super.update();

			if (alive) if (game)
			{
				if (x + width < 0) game.level -= 1;
				else if (x > game.gamePixels.width) game.level += 1;
				//if (y < game.height - height - 4) y = game.height - height - 4;
				//else 
				acceleration.y = game.gravity;
				
				if (object) object.actUpon(this);
				//else if (onLadder && y > last.y) y = last.y;
			}
			if (!alive) alpha -= 0.02;
			wasOnGround = onGround;
			onGround = false;
		}
		
		override public function draw():void
		{	
			drawOntoSprite(game.gamePixels);
		}
		
		override public function kill():void
		{
			play("die");
			if (alive) 
			{
				deathTimer.stop();
				deathTimer.start(1, 1, onTimerDestroy);
				alive = false;
				Entity.playRandomSound(sfxExplosion, 0.8);
			}
		}
		
		public function onTimerDestroy(Timer:FlxTimer):void
		{
			if (!alive)
			{
				x = -1000;
				y = -1000;
				play("none");
			}
		}
		
		override public function defaultInput():uint
		{
			return game.controls;
		}
		
		override public function translateInput():void
		{
			//velocity.x = 0;//velocity.y = 0;
			if (!alive)
			{
				if ((controls & Entity.START) > 0 && (lastControls & Entity.START) == 0)
				{
					respawn();
				}
			}
			alreadyMoving = false;
			if (!alive) return;
			if ((controls & Entity.BUTTON_B) > 0 && (lastControls & Entity.BUTTON_B) == 0) jump();
			if (object) if ((object as JungleBlock).type == JungleBlock.VINE) return;
			if ((controls & Entity.UP) > 0) move("up");
			if ((controls & Entity.DOWN) > 0) move("down");
			if ((controls & Entity.LEFT) > 0) move("left");
			if ((controls & Entity.RIGHT) > 0) move("right");
			if ((controls & Entity.BUTTON_A) > 0 && (lastControls & Entity.BUTTON_A) == 0) attack();
			
			if (!alreadyMoving)
			{
				if ((controls & Entity.UP) > 0) play("lookup");
				else play("idle");
				velocity.x = 0;//velocity.y = 0;
			}
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			FlxG.log("Lives remaining: " + lives);
			if (lives == 0) return;
			object = null;
			super.reset(X, Y);
			lives -= 1;
			alpha = 1;
			deathTimer.stop();
			play("idle");
		}
		
		public function get lives():int
		{
			return _lives;
		}
		
		public function set lives(Lives:int):void
		{
			_lives = Lives;
		}
		
		public function move(Direction:String):void
		{
			if (object) if (object.type == JungleBlock.LADDER || object.type == JungleBlock.LADDER_TOP)
			{
				if (Direction == "up" || Direction == "down")
				{
					if (alreadyMoving) velocity.y = diagonalSpeed;
					else velocity.y = speed;
					if (z <= 0) play("run");
					else play("jump");
				}
				else 
				{
					velocity.y = 0;
					acceleration.y = 0;
				}
				if (Direction == "up") velocity.y *= -1;
				alreadyMoving = true;
			}
			if (Direction == "left" || Direction == "right")
			{
				facing = FlxObject.RIGHT;
				if (alreadyMoving) velocity.x = diagonalSpeed;
				else velocity.x = speed;
				if (!alreadyMoving) 
				{
					if (z <= 0) play("run");
					else play("jump");
				}
				alreadyMoving = true;
			}
			else velocity.x = 0;
			
			if (Direction == "left") 
			{
				facing = FlxObject.LEFT;
				velocity.x *= -1;
			}			
		}
		
		public function attack():void
		{
			
		}
		
		public function jump():void
		{
			//FlxG.log("Jump!");
			if (onGround) velocity.y = -jumpSpeed;
			else if (onLadder) move("up");
			if (object) if (object.type == JungleBlock.VINE)
			{
				object.timer.start(0.35);
				object = null;
			}
		}
		
		public function respawn():void
		{
			reset(6, 32);
		}
	}
}
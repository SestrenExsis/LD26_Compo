package entities
{
	import org.flixel.*;
	import games.*;
	
	public class PlayerShip extends Entity
	{
		[Embed(source="../assets/images/spaceships.png")] protected static var imgSpaceships:Class;
		
		private static var kUp:String = "W";
		private static var kDown:String = "S";
		private static var kLeft:String = "A";
		private static var kRight:String = "D";
		private static var kJump:String = "SPACE";
		
		private var alreadyMoving:Boolean = false;
		private var deathTimer:FlxTimer;
		private var shieldTimer:FlxTimer;
		
		public var shotsInPlay:uint = 0;
		//public var screen:Entity;
		public var lifeString:String = "^^^";
		public var shields:Boolean = false;
		public var shieldsReady:Boolean = true;
		public var autoPilot:Boolean = false;
		
		protected var _lives:uint = 4;
		
		public function PlayerShip(Game:GameInvade)
		{
			super(Game.gamePixels.width / 2, Game.gamePixels.height - 4);
			
			//inputs.push(Game);
			game = Game;
			loadGraphic(imgSpaceships, true, false, 16, 16);
			addAnimation("none",[9]);
			addAnimation("idle",[0]);
			addAnimation("die",[3, 4, 5, 6], 6, false);
			addAnimation("shield",[1,2], 2, true);
			addAnimation("shieldsReady",[7, 8, 0], 3, false);
			
			width = 8;
			height = 8;
			offset.x = offset.y = 4;
			x -= width / 2;
			y -= height;
			color = 0x00ffff;
			shotSpeed = 60;
			speed = 50;
			play("idle");
			//alive = false;
			deathTimer = new FlxTimer();
			shieldTimer = new FlxTimer();
		}
		
		override public function update():void
		{
			super.update();
			
			if (alive) if (game)
			{
				if (x - 4 < 0) x = 4;
				else if (x + width + 4 > game.gamePixels.width) x = game.gamePixels.width - width - 4;
				if (y < game.gamePixels.height - 24) y = game.gamePixels.height - 24;
				else if (y + height + 4 > game.gamePixels.height) y = game.gamePixels.height - height - 4;
			}
			if (!alive)
			{
				alpha -= 0.02;
			}
			
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
				if (autoPilot) reset(game.gamePixels.width / 2 - width / 2, game.gamePixels.height - height - 4);
			}
		}
		
		override public function defaultInput():uint
		{
			if (autoPilot)
			{
				controls = lastControls;
				var _seed:Number = FlxG.random();
				if (_seed < 0.95) controls &= Entity.DPAD;
				else
				{
					controls = Entity.NONE;
					_seed = Math.floor(FlxG.random() * 6);
					switch (_seed) {
						case 0: controls |= Entity.LEFT; break;
						case 1: controls |= Entity.RIGHT; break;
					}
					_seed = Math.floor(FlxG.random() * 60);
					switch (_seed) {
						case 0: controls |= Entity.UP; break;
						case 1: controls |= Entity.DOWN; break;
					}
				}
				_seed = FlxG.random();
				if (_seed <= 1/900) controls |= Entity.BUTTON_B;
				else if (_seed <= 1/60) controls |= Entity.BUTTON_A;
				//FlxG.log(controls);
				return controls;
			}
			else return game.controls;
		}
		
		override public function translateInput():void
		{
			velocity.x = velocity.y = 0;
			if (!alive)
			{
				if ((controls & Entity.START) > 0 && (lastControls & Entity.START) == 0)
				{
					reset(game.width / 2 - width / 2, game.height - height - 4);
				}
			}
			alreadyMoving = false;
			if (!alive) return;
			if ((controls & Entity.BUTTON_B) > 0 && z == 0 && (lastControls & Entity.BUTTON_B) == 0) shield();
			if ((controls & Entity.UP) > 0) move("up");
			if ((controls & Entity.DOWN) > 0) move("down");
			if ((controls & Entity.LEFT) > 0) move("left");
			if ((controls & Entity.RIGHT) > 0) move("right");
			if ((controls & Entity.BUTTON_A) > 0 && (lastControls & Entity.BUTTON_A) == 0) attack();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			if (lives == 0) return;
			
			super.reset(X, Y);
			lives -= 1;
			alpha = 1;
			deathTimer.stop();
			shieldsReady = true;
			shields = false;
			play("idle");
			shield(true);
			FlxG.log(lives);
		}
		
		public function get lives():int
		{
			return _lives;
		}
		
		public function set lives(Lives:int):void
		{
			_lives = Lives;
			if (lives > 2) lifeString = "^^^";
			else if (lives == 2) lifeString = "^^";
			else if (lives == 1) lifeString = "^";
			else lifeString = "";
		}
		
		private function shield(FreeShield:Boolean = false):void
		{
			if ((shieldsReady || FreeShield) && !shields)
			{
				color = 0x00ff00;
				shields = true;
				shieldsReady = FreeShield;
				play("shield");
				shieldTimer.stop();
				shieldTimer.start(2, 1, onShieldUpdate);
				Entity.playRandomSound(sfxActivateShields, 0.8);
			}
		}
		
		private function onShieldUpdate(Timer:FlxTimer):void
		{
			if (alive)
			{
				if (!shields && !shieldsReady) //ready the shields
				{
					shieldsReady = true;
					play("shieldsReady");
					Entity.playRandomSound(sfxShieldsReady, 0.8);
				}
				else if (shields && !shieldsReady) //deactivate shield
				{
					play("idle");
					color = 0x00ffff;
					shields = false;
					shieldTimer.stop();
					shieldTimer.start(15, 1, onShieldUpdate);
				}
				else if (shields && shieldsReady) //deactivate "free" shield
				{
					play("shieldsReady");
					color = 0x00ffff;
					shields = false;
					Entity.playRandomSound(sfxShieldsReady, 0.8);
				}
			}
		}
		
		private function move(Direction:String):void
		{
			if (Direction == "up" || Direction == "down")
			{
				if (alreadyMoving) velocity.y = diagonalSpeed;
				else velocity.y = speed;
			}
			if (Direction == "up") velocity.y *= -1;
			if (Direction == "left" || Direction == "right")
			{
				if (alreadyMoving) velocity.x = diagonalSpeed;
				else velocity.x = speed;
			}
			if (Direction == "left") velocity.x *= -1;
			
			alreadyMoving = true;
		}
		
		public function attack():void
		{
			if (shotsInPlay < 3) if (GameInvade(game).spawnLaser(this)) 
			{
				shotsInPlay += 1;
				Entity.playRandomSound(sfxLaser, 0.5);
			}
		}
	}
}
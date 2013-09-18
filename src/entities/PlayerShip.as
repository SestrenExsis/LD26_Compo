package entities
{
	import org.flixel.*;
	
	public class PlayerShip extends Entity
	{
		[Embed(source="../assets/images/spaceships.png")] protected static var imgSpaceships:Class;
		
		private static var kUp:String = "W";
		private static var kDown:String = "S";
		private static var kLeft:String = "A";
		private static var kRight:String = "D";
		private static var kJump:String = "SPACE";
		
		private var alreadyMoving:Boolean = false;
		private var speed:Number = 50;
		private var diagonalSpeed:Number = speed * Math.sqrt(2)/2;
		private var deathTimer:FlxTimer;
		private var shieldTimer:FlxTimer;
		
		public static var shotsInPlay:uint = 0;
		//public var screen:Entity;
		public var ammo:FlxGroup;
		public var lives:uint = 3;
		public var lifeString:String = "^^^";
		public var shields:Boolean = false;
		public var shieldsReady:Boolean = true;
		
		public function PlayerShip(Screen:TVScreen)
		{
			super(Screen.x + Screen.width / 2, Screen.y + Screen.height - 4);
			
			inputs.push(Screen);
			input = Screen;
			loadGraphic(imgSpaceships, true, false, 16, 16);
			addAnimation("idle",[0]);
			addAnimation("die",[3, 4, 5, 6], 6, false);
			addAnimation("shield",[1,2], 2, true);
			addAnimation("shieldsReady",[7, 8, 0], 6, false);
			
			width = 8;
			height = 8;
			offset.x = offset.y = 4;
			x -= width / 2;
			y -= height;
			color = 0x00ffff;
			play("idle");
			//alive = false;
			deathTimer = new FlxTimer();
			shieldTimer = new FlxTimer();
		}
		
		override public function update():void
		{
			super.update();
			
			if (alive) if (input) if (input is TVScreen)
			{
				if (x - 4 < input.x) x = input.x + 4;
				else if (x + width + 4 > input.x + input.width) x = input.x + input.width - width - 4;
				if (y < input.y + input.height - 24) y = input.y + input.height - 24;
				else if (y + height + 4> input.y + input.height) y = input.y + input.height - height - 4;
			}
			if (!alive)
			{
				alpha -= 0.02;
			}
			
			//FlxG.log("pos= " + alive + " " + x + " " + y);
		}
		
		override public function kill():void
		{
			play("die");
			if (alive) 
			{
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
			}
		}
		
		override public function translateInput():void
		{
			velocity.x = velocity.y = 0;
			if (!alive)
			{
				if ((controls & Entity.START) > 0 && (lastControls & Entity.START) == 0)
				{
					reset(input.x + input.width / 2 - width / 2, input.y + input.height - height - 4);
				}
			}
			alreadyMoving = false;
			if (!alive || !TVScreen.gameStarted) return;
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
			FlxG.log(x + " " + y);
			lives -= 1;
			alpha = 1;
			shields = true;
			shieldsReady = true;
			shieldTimer.start(2, 1, onFreeShield);
			Entity.playRandomSound(sfxActivateShields, 0.8);
			color = 0x00ff00;
			play("shield");
			if (lives > 2) lifeString = "^^^";
			else if (lives == 2) lifeString = "^^";
			else if (lives == 1) lifeString = "^";
			else lifeString = "";
		}
		
		private function shield():void
		{
			if (shieldsReady && !shields)
			{
				color = 0x00ff00;
				shields = true;
				shieldsReady = false;
				play("shield");
				shieldTimer.start(2, 1, onShieldDeactivate);
				Entity.playRandomSound(sfxActivateShields, 0.8);
			}
		}
		
		private function onFreeShield(Timer:FlxTimer):void
		{
			if (alive) 
			{
				play("shieldsReady");
				color = 0x00ffff;
				shields = false;
				Entity.playRandomSound(sfxShieldsReady, 0.8);
			}
			//shieldTimer.start(10, 1, onShieldActivate);
		}
		
		private function onShieldDeactivate(Timer:FlxTimer):void
		{
			if (alive) 
			{
				play("idle");
				color = 0x00ffff;
				shields = false;
			}
			shieldTimer.start(15, 1, onShieldActivate);
		}
		
		private function onShieldActivate(Timer:FlxTimer):void
		{
			shieldsReady = true;
			play("shieldsReady");
			Entity.playRandomSound(sfxShieldsReady, 0.8);
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
			if (ammo) if (shotsInPlay < 3)
			{
				Laser.shoot(x + width / 2, y + height / 2, 60, true);
				Entity.playRandomSound(sfxLaser, 0.5);
			}
		}
	}
}
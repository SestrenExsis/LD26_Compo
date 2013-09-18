package entities
{
	import org.flixel.*;
	import screens.GameState;
	
	public class Player extends Entity
	{
		[Embed(source="../assets/images/player.png")] protected static var imgPlayer:Class;
		
		private static var kUp:String = "W";
		private static var kDown:String = "S";
		private static var kLeft:String = "A";
		private static var kRight:String = "D";
		private static var kJump:String = "SPACE";
		
		private var alreadyMoving:Boolean = false;
		private var jumpHeight:Number = 9;
		private var jumpSpeed:Number = Math.sqrt(2 * GameState.GRAVITY * jumpHeight);
		private var upAndDownMultiplier:Number = 0.75;
		private var jumpVelocityMultiplier:Number = 2;
				
		public var ammo:FlxGroup;
		
		public function Player(X:Number = -1000, Y:Number = -1000)
		{
			super(X, Y);
			
			loadGraphic(imgPlayer, true, true, 16, 24);
			addAnimation("none",[0]);
			addAnimation("idle_side",[1]);
			addAnimation("idle_down",[11]);
			addAnimation("idle_up",[21]);
			addAnimation("walk_side",[2, 3, 4, 3], 10, true);
			addAnimation("walk_down",[12, 13, 14, 13], 10, true);
			addAnimation("walk_up",[22, 23, 24, 23], 10, true);
			addAnimation("jump_side",[4]);
			addAnimation("jump_down",[14]);
			addAnimation("jump_up",[24]);
			
			width = 8;
			height = 8;
			offset.y = 16;
			offset.x = 4;
			speed = 150;
			play("idle_down");
		}
		
		override public function update():void
		{
			super.update();
			if (z > 0) velocity.x *= jumpVelocityMultiplier;
			
			if (input) if (input is Gamepad)
			{
				if (x - 8 < input.x) x = input.x + 8;
				else if (x + width + 8 > input.x + input.width) x = input.x + input.width - width - 8;
				if (y < input.y) y = input.y;
				else if (y + height > input.y + 0.9 * input.height) y = input.y + 0.9 * input.height - height;
			}
		}
		
		private function move(Direction:String):void
		{
			if (Direction == "up" || Direction == "down")
			{
				if (alreadyMoving) velocity.y = diagonalSpeed;
				else velocity.y = speed * upAndDownMultiplier;
				if (Direction == "down") 
				{
					if (z <= 0) play("walk_down");
					else play("jump_down");
				}
			}
			if (Direction == "up") 
			{
				velocity.y *= -1;
				play("walk_up");
			}
			if (Direction == "left" || Direction == "right")
			{
				if (alreadyMoving) velocity.x = diagonalSpeed;
				else velocity.x = speed;
				if (!alreadyMoving) 
				{
					if (z <= 0) play("walk_side");
					else play("jump_side");
				}
			}
			if (Direction == "left") 
			{
				velocity.x *= -1;
				facing = FlxObject.LEFT;
				//play("walk_side");
			}
			else facing = FlxObject.RIGHT;
			alreadyMoving = true;
		}
		
		public function attack(X:Number, Y:Number):void
		{
			if (ammo) if (X > input.x && Y > input.y)
			{
				Baseball.throwAt(x + width / 2, y + height / 2, z + 8, X, Y);
			}
		}
		
		public function jump():void
		{
			zVelocity = jumpSpeed;
		}
		
		override public function defaultInput():uint
		{
			controls = Entity.NONE;
			
			if (FlxG.keys[kUp] && !FlxG.keys[kDown]) controls |= Entity.UP;
			else if (!FlxG.keys[kUp] && FlxG.keys[kDown]) controls |= Entity.DOWN;
			if (FlxG.keys[kLeft] && !FlxG.keys[kRight]) controls |= Entity.LEFT;
			else if (!FlxG.keys[kLeft] && FlxG.keys[kRight]) controls |= Entity.RIGHT;
			
			if (FlxG.mouse.justPressed()) controls |= Entity.BUTTON_A;
			if (FlxG.keys[kJump]) controls |= Entity.BUTTON_B;

			return controls;
		}
		
		override public function translateInput():void
		{
			velocity.x = velocity.y = 0;
			alreadyMoving = false;
			if ((controls & Entity.BUTTON_B) > 0 && z == 0 && (lastControls & Entity.BUTTON_B) == 0) jump();
			if ((controls & Entity.UP) > 0) move("up");
			if ((controls & Entity.DOWN) > 0) move("down");
			if ((controls & Entity.LEFT) > 0) move("left");
			if ((controls & Entity.RIGHT) > 0) move("right");
			
			if (alreadyMoving == false)
			{
				if (_curAnim.name == "walk_up") play("idle_up");
				else if (_curAnim.name == "walk_down") play("idle_down");
				else if (_curAnim.name == "walk_side") play("idle_side");
			}
			
			if ((controls & Entity.BUTTON_A) > 0 && (lastControls & Entity.BUTTON_A) == 0) attack(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		override protected function updateMotion():void
		{
			super.updateMotion();
			
			if (z > 0 || (z == 0 && zVelocity > 0))
			{
				var delta:Number;
				var velocityDelta:Number;
				velocityDelta = (FlxU.computeVelocity(zVelocity,-GameState.GRAVITY,0) - zVelocity) / 2;
				zVelocity += velocityDelta;
				delta = zVelocity*FlxG.elapsed;
				zVelocity += velocityDelta;
				z += delta;
				z = Math.max(0, z);
			}
			//(z >= World.TILESIZE) ? solid = false : solid = true;
			offset.y = z*1.5 + (24 - height);
			offset.x = 4;//(16 - width)/2;
			//scale.x = scale.y = (1.0 + 0.015*z);
			
			if (lastZ > 0 && z <= 0) onHitGround();
			lastZ = z;
		}
	}
}
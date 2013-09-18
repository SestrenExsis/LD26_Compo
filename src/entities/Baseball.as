package entities
{
	import org.flixel.*;
	import screens.GameState;
	
	public class Baseball extends Entity
	{
		[Embed(source="../assets/images/baseball.png")] protected static var imgBaseball:Class;
				
		public static var selected:Baseball;
		public static var group:FlxGroup;
		public var bounced:Boolean = false;
		
		public function Baseball(X:Number = -1000, Y:Number = -1000)
		{
			super(X, Y);
			
			loadGraphic(imgBaseball, true, false, 4, 4);
			addAnimation("idle", [0]);
			addAnimation("spin", [0,1], 8, true);
			
			width = 4;
			height = 4;
			kill();
			drag.x = drag.y = 10;
			play("spin");
		}
		
		override public function update():void
		{
			super.update();
			if (x + width < 0 || x > FlxG.width || y + height < 0 || y > FlxG.height) kill();
		}
		
		override protected function updateMotion():void
		{
			super.updateMotion();
			
			if (z > 0 || (z == 0 && zVelocity > 0))
			{
				if (bounced)
				{
					var delta:Number;
					var velocityDelta:Number;
					velocityDelta = (FlxU.computeVelocity(zVelocity,-GameState.GRAVITY,0) - zVelocity) / 2;
					zVelocity += velocityDelta;
					delta = zVelocity*FlxG.elapsed;
					zVelocity += velocityDelta;
					z += delta;
				}
				else
				{
					z += zVelocity * FlxG.elapsed;
					//z = Math.max(0, z);
				}

			}
			//(z >= World.TILESIZE) ? solid = false : solid = true;
			offset.y = z*1.5 + (4 - height);
			offset.x = 0;//(16 - width)/2;
			//scale.x = scale.y = (1.0 + 0.015*z);
			
			if (lastZ > 0 && z <= 0 && !bounced) onHitGround();
			lastZ = z;
		}
		
		override public function onHitGround():void
		{
			z = 0;
			zVelocity = 150;//*= -0.75;
			if (velocity.x > 0) velocity.x = 25;
			else velocity.x = -25;
			velocity.y = 100;//velocity.y *= 0.5;
			bounced = true;
		}
		
		public static function throwAt(X1:Number, Y1:Number, Z1:Number, X2:Number, Y2:Number):void
		{
			selected = Baseball(group.getFirstAvailable(Baseball));
			
			if (selected)
			{
				var _dist:Number = Math.sqrt(Math.pow(X1 - X2, 2) + Math.pow(Y1 - Y2, 2) + Math.pow(Z1, 2));
				var _time:Number = 0;
				if (_dist > 150) _time = 0.15;
				else if (_dist > 75) _time = 0.075;
				else if (_dist > 25) _time = 0.0375;
				else
				{
					selected.reset(X2 - selected.width / 2, Y2 - selected.height / 2);
					selected.velocity.x = selected.velocity.y = 0;
					selected.z = 0;
					_time = 0;
					selected.play("idle");
				}
				if (_time > 0)
				{
					selected.bounced = false;
					selected.reset(X1 - selected.width / 2, Y1 - selected.height / 2);
					selected.z = Z1;
					selected.zVelocity = -Z1 / _time;
					selected.velocity.x = (X2 - X1) / _time;
					selected.velocity.y = (Y2 - Y1) / _time;
					selected.play("spin");
				}
			}
		}
	}
}
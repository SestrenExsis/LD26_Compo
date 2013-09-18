package entities
{
	import org.flixel.*;
	import games.*;
	
	public class EnemyShip extends Entity
	{
		[Embed(source="../assets/images/spaceships.png")] protected static var imgSpaceships:Class;
		
		private var alreadyMoving:Boolean = false;
		private var timer:FlxTimer;
		private var slotX:uint = 0;
		private var slotY:uint = 0;
		public var type:String = "";
		public var behavior:String = "";
		
		public function EnemyShip(Game:GameInvade)
		{
			super(Game.gamePixels.width / 2, 10);
			
			//inputs.push(Game);
			game = Game;
			loadGraphic(imgSpaceships, true, true, 16, 16);
			addAnimation("shooter", [10, 11], 2, true);
			addAnimation("bomber_down", [20, 21], 2, true);
			addAnimation("bomber_up", [22, 23], 2, true);
			addAnimation("bomber_side", [24, 25], 2, true);
			addAnimation("die", [12, 13, 14, 15], 8, false);
			
			width = 8;
			height = 8;
			offset.x = offset.y = 4;
			x -= width / 2;
			y -= height;
			color = 0xff00ff;
			shotSpeed = 25;
			speed = 30;
			type = "shooter";
			play("shooter");
			timer = new FlxTimer();
			target = new FlxPoint();
			removeFromPlay();
		}
		
		override public function update():void
		{
			/*if (game) if (game.paused)
			{
				x = last.x;
				y = last.y;
				timer.paused = true;
			}
			else timer.paused = false;*/
			super.update();
			
			if (game)
			{
				checkBehavior();
				//if (x - 4 < input.x) x = input.x + 4;
				//else if (x + width + 4 > input.x + input.width) x = input.x + input.width - width - 4;
				if (y + height < 0) visible = false; //y = input.y - height;
				else if (y > game.gamePixels.height) visible = false;//y = input.y + input.height - height - 4;
				else visible = true;
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
			behavior = "dead";
			if (alive) 
			{
				timer.stop();
				timer.start(1, 1, onTimerDestroy);
				alive = false;
				GameInvade(game).slots[slotY][slotX] = 0;
				GameInvade(game).slotsFilled = Math.max(0,GameInvade(game).slotsFilled - 1);
				if (GameInvade(game).gameHasStarted) Entity.playRandomSound(sfxExplosion, 0.8);
			}
		}
		
		public function checkBehavior():void
		{
			if (behavior == "spawn")
			{
				var _randomSlot:uint = Math.ceil(FlxG.random()*(GameInvade(game).maxSlots - GameInvade(game).slotsFilled));
				var _index:uint = 0;
				for (var _y:uint = 0; _y < 2; _y++)
				{
					for (var _x:uint = 0; _x < 6; _x++)
					{
						if (GameInvade(game).slots[_y][_x] == 0) _index++;
						if (_index == _randomSlot)
						{
							GameInvade(game).slotsFilled += 1;
							GameInvade(game).slots[_y][_x] = 1;
							slotX = _x;
							slotY = _y;
							setTargetPosition();
							_x += 100;
							_y += 100;
						}
					}
				}
				behavior = "moveToPosition";
			}
			else if (behavior == "moveToPosition")
			{
				setTargetPosition();
				moveTowardTarget();
				if (x == target.x && y == target.y) behavior = "inPosition";
			}
			else if (behavior == "inPosition")
			{
				timer.stop();
				if (type == "shooter") timer.start(FlxG.random() * 4 + GameInvade(game).handicap * 0.5, 1, onTimerAttack);
				else if (type == "bomber") timer.start(FlxG.random() * 4 + GameInvade(game).handicap * 1, 1, onTimerAttack);
				setTargetPosition();
				moveTowardTarget();
				behavior = "idle";
			}
			else if (behavior == "idle")
			{
				setTargetPosition();
				moveTowardTarget();
				if (type == "bomber" && x == target.x && y == target.y) play("bomber_down");
			}
			else if (behavior == "special")
			{
				moveTowardTarget();
				//FlxG.log("x" + (target.x - x).toString() + " y" + (target.y - y).toString());
				if (x == target.x && y == target.y)
				{
					if (_curAnim.name == "bomber_down")
					{
						play("bomber_side");
						var _seed:Number = FlxG.random();
						if (_seed < 0.5) 
						{
							facing = FlxObject.RIGHT;
							target.x = 2;
						}
						else 
						{
							facing = FlxObject.LEFT;
							target.x = game.gamePixels.width - 10;
						}
					} 
					else if (_curAnim.name == "bomber_side")
					{
						play("bomber_up");
						facing = FlxObject.LEFT;
						target.y -= 50;
						behavior = "climb";
					}
				}
			}
			else if (behavior == "climb")
			{
				moveTowardTarget();
				if (x == target.x && y == target.y)
				{
					behavior = "idle";
				}
			}
		}
		
		public function setTargetPosition():void
		{
			target.x = 2 + GameInvade(game).formation.x + slotX * 10;
			target.y = 10 + GameInvade(game).formation.y + slotY * 10;
		}
		
		public function onTimerDestroy(Timer:FlxTimer):void
		{
			alive = false;
			exists = false;
			x = -1000;
			y = -1000;
			behavior = "dead";
			//FlxG.log("destroyed " + slotX + " " + slotY);
		}
		
		public function onTimerAttack(Timer:FlxTimer):void
		{
			if (!alive) return;
			attack();
			var _multi:Number;
			if (GameInvade(game).slotsFilled > 8) _multi *= 1.5;
			else if (GameInvade(game).slotsFilled > 4) _multi *= 1.25;
			else _multi = 1;
			if (type == "shooter") Timer.start((FlxG.random() * 24 + 6 * GameInvade(game).handicap) * _multi, 1, onTimerAttack);
			else if (type == "bomber") Timer.start(FlxG.random() * 24 + 12 * GameInvade(game).handicap, 1, onTimerAttack);
		}
		
		public function onTimerDrop(Timer:FlxTimer):void
		{
			if (!alive) return;
			attack();
		}
		
		override public function translateInput():void
		{
			
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			alpha = 1;
		}
		
		public function attack():void
		{
			if (type == "shooter")
			{
				if (GameInvade(game).lasers) GameInvade(game).spawnLaser(this);
			}
			else if (type == "bomber" && _curAnim.name == "bomber_down")
			{
				behavior = "special";
				target.y = game.gamePixels.height - 10;
			}
		}
		
		public function spawn(X:Number, Y:Number, Type:String):void
		{
			reset(X - width / 2, Y - height - 100);
			velocity.x = velocity.y = 0;
			type = Type;
			behavior = "spawn";
			if (Type == "shooter")
			{
				play("shooter");
			}
			else play("bomber_down");
		}
	}
}
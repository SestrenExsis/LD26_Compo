package entities
{
	import org.flixel.*;
	
	public class EnemyShip extends Entity
	{
		[Embed(source="../assets/images/spaceships.png")] protected static var imgSpaceships:Class;
		
		private var alreadyMoving:Boolean = false;
		private var speed:Number = 30;
		private var diagonalSpeed:Number = speed * Math.sqrt(2)/2;
		private var timer:FlxTimer;
		private var target:FlxPoint;
		private var slotX:uint = 0;
		private var slotY:uint = 0;
		public var type:String = "";
		public var behavior:String = "";
		
		private static var slots:Array = [[0, 0, 0, 0, 0, 0],
			                              [0, 0, 0, 0, 0, 0]];
		public static var formation:FlxPoint = new FlxPoint(0, 0);
		public static var formationMax:FlxPoint = new FlxPoint(48, 6);
		public static var formationNegativeDirection:Boolean = false;
		public static var formationSpeed:Number = 0.1;
		public static var maxSlots:uint = 12;
		public static var slotsFilled:uint = 0;
		public static var selected:EnemyShip;
		public static var group:FlxGroup;
		public static var ammo:FlxGroup;
		public static var handicap:Number = 5;
		
		public function EnemyShip(Screen:TVScreen)
		{
			super(Screen.x + Screen.width / 2, 10);
			
			inputs.push(Screen);
			input = Screen;
			loadGraphic(imgSpaceships, true, true, 16, 16);
			addAnimation("shooter",[10, 11], 2, true);
			addAnimation("bomber_down",[20, 21], 2, true);
			addAnimation("bomber_up",[22, 23], 2, true);
			addAnimation("bomber_side",[24, 25], 2, true);
			addAnimation("die",[12, 13, 14, 15], 8, false);
			
			width = 8;
			height = 8;
			offset.x = offset.y = 4;
			x -= width / 2;
			y -= height;
			color = 0xff00ff;
			type = "shooter";
			play("shooter");
			timer = new FlxTimer();
			target = new FlxPoint();
			kill();
		}
		
		override public function update():void
		{
			super.update();
			
			if (input) if (input is TVScreen)
			{
				checkBehavior();
				//if (x - 4 < input.x) x = input.x + 4;
				//else if (x + width + 4 > input.x + input.width) x = input.x + input.width - width - 4;
				if (y + height < input.y) visible = false; //y = input.y - height;
				else if (y > input.y + input.height) visible = false;//y = input.y + input.height - height - 4;
				else visible = true;
			}
			if (!alive)
			{
				alpha -= 0.02;
			}
		}
		
		override public function kill():void
		{
			play("die");
			behavior = "dead";
			if (alive) 
			{
				timer.start(1, 1, onTimerDestroy);
				alive = false;
				slots[slotY][slotX] = 0;
				slotsFilled = Math.max(0,slotsFilled - 1);
				if (TVScreen.gameStarted) Entity.playRandomSound(sfxExplosion, 0.8);
			}
		}
		
		public function checkBehavior():void
		{
			if (behavior == "spawn")
			{
				var _randomSlot:uint = Math.ceil(FlxG.random()*(maxSlots - slotsFilled));
				var _index:uint = 0;
				for (var _y:uint = 0; _y < 2; _y++)
				{
					for (var _x:uint = 0; _x < 6; _x++)
					{
						if (slots[_y][_x] == 0) _index++;
						if (_index == _randomSlot)
						{
							slotsFilled += 1;
							slots[_y][_x] = 1;
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
				if (type == "shooter") timer.start(FlxG.random() * 8 + handicap * 3, 1, onTimerAttack);
				else if (type == "bomber") timer.start(FlxG.random() * 4 + handicap * 1, 1, onTimerAttack);
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
							target.x = 2 + input.x;
						}
						else 
						{
							facing = FlxObject.LEFT;
							target.x = input.x + input.width - 10;
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
			target.x = 2 + input.x + formation.x + slotX * 10;
			target.y = 10 + input.y + formation.y + slotY * 10;
		}
		
		public function moveTowardTarget():void
		{
			var _dist:Number;
			var _ratio:Number;
			if (x != target.x || y != target.y)
			{
				_point.x = x;
				_point.y = y;
				_dist = FlxU.getDistance(_point, target);
				_ratio = (speed * FlxG.elapsed) / _dist;
				if (_ratio >= 1)
				{
					x = target.x;
					y = target.y;
				}
				else
				{
					x = (1 - _ratio) * x + _ratio * target.x;
					y = (1 - _ratio) * y + _ratio * target.y;
				}
			}
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
			var _multi:Number = 1;
			if (EnemyShip.slotsFilled > 8) _multi *= 1.5;
			else if (EnemyShip.slotsFilled > 4) _multi *= 2; 
			if (type == "shooter") Timer.start((FlxG.random() * 24 + 6 * handicap) * _multi, 1, onTimerAttack);
			else if (type == "bomber") Timer.start(FlxG.random() * 24 + 12 * handicap, 1, onTimerAttack);
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
				if (ammo) Laser.shoot(x + width / 2, y + height / 2, 50, false);
			}
			else if (type == "bomber" && _curAnim.name == "bomber_down")
			{
				behavior = "special";
				target.y = input.y + input.height - 10;
			}
		}
		
		public static function spawn(X:Number, Y:Number, Type:String):void
		{
			selected = EnemyShip(group.getFirstAvailable(EnemyShip));
			if (selected)
			{
				selected.reset(X - selected.width / 2, Y - selected.height / 2);
				selected.velocity.x = 0;
				selected.type = Type;
				selected.behavior = "spawn";
				if (Type == "shooter")
				{
					selected.play("shooter");
				}
				else selected.play("bomber_down");
			}
		}
	}
}
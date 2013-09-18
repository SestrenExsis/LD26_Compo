package entities
{
	import games.*;
	
	import org.flixel.*;
	
	public class JungleBlock extends Entity
	{
		[Embed(source="../assets/images/jungles.png")] protected static var imgJungles:Class;
		
		public static const AIR:uint = 0;
		public static const BLOCK:uint = 1;
		public static const SPIKES:uint = 2;
		public static const BRIDGE:uint = 3;
		public static const OLD_BRIDGE:uint = 4;
		public static const LOG:uint = 5;
		public static const WATER:uint = 6;
		public static const VINE:uint = 7;
		public static const STAIRS_LEFT:uint = 8;
		public static const STAIRS_RIGHT:uint = 9;
		public static const LADDER:uint = 10;
		public static const LADDER_TOP:uint = 11;
		public static const TREASURE:uint = 12;
		public static const ROLLING_LOG:uint = 13;
		public static const TURTLE:uint = 14;
		public static const WATER_LOG:uint = 15;
		public static const QUICKSAND:uint = 16;
		public static const blockTypes:Array = ["air", "block", "spikes", "bridge", "old_bridge", "log", "water", "vine", "stairs_left", "stairs_right", "ladder", "ladder_top", "treasure", "rolling_log", "turtle", "water_log", "quicksand"];
		
		public var slotX:uint = 0;
		public var slotY:uint = 0;
		public var slotZ:uint = 0;
		public var behavior:String = "";
		public var killsPlayer:Boolean = false;
		public var hurtsPlayer:Boolean = false;
		public var blocksMovement:Boolean = false;
		public var length:Number = 42;

		private var swingTime:Number = 0;
		private var swingOffset:Number = 0;
		private var swingAngle:Number = 0;
		private var maxAngle:Number = 45;
		private var gravityScale:Number = 0.4;
		private var anchorPoint:FlxPoint;
		private var endPoint:FlxPoint;
		
		protected var _type:uint = 0;
		public var subType:uint = 0;
		//protected var _swingVelocity:FlxPoint;
		public var timer:FlxTimer;
		
		public function JungleBlock(Game:GamePitJumper, SlotX:uint, SlotY:uint, Type:uint = 0)
		{
			slotX = SlotX;
			slotY = SlotY;
			
			super(slotX * 16 - 8, slotY * 16 - 8);
			
			game = Game;
			loadGraphic(imgJungles, true, true, 16, 16);
			addAnimation("air", [9]);
			addAnimation("block", [11]);
			addAnimation("spikes", [27]);
			addAnimation("spikes_attack", [27, 28, 29], 9, false);
			addAnimation("spikes_reset", [29, 28, 27], 9, false);
			addAnimation("bridge", [12]);
			addAnimation("old_bridge", [14]);
			addAnimation("log",[12]);
			addAnimation("rolling_log", [13, 14], 4, true);
			addAnimation("water", [20, 21, 22, 23, 24, 25, 26, 25, 24, 23, 22, 21], 4, true);
			addAnimation("vine", [9]);
			addAnimation("stairs_left", [15]);
			addAnimation("stairs_right", [16]);
			addAnimation("ladder", [17]);
			addAnimation("ladder_top", [17]);
			addAnimation("treasure", [31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 32, 33, 32], 6, true);
			addAnimation("turtle", [40]);
			addAnimation("turtle_hide", [41, 42, 43, 44], 4, false);
			addAnimation("turtle_show", [44, 43, 42, 41], 4, false);
			addAnimation("water_log", [12]);
			addAnimation("quicksand",[45]);
			
			width = 16;
			height = 16;
			speed = 50;
			timer = new FlxTimer();
			timer.start(0.001);
			alive = false;
			exists = false;
			//type = Type;
		}
		
		override public function update():void
		{
			super.update();
			
			if (game)
			{
				checkBehavior();
				if (y + height < 0) visible = false;
				else if (y > game.gamePixels.height) visible = false;
				else visible = true;
			}
			if (!alive) alpha -= 0.02;
		}
		
		override public function draw():void
		{	
			if (type == VINE)
			{
				if (FlxG.visualDebug && !ignoreDrawDebug) drawDebugOntoSprite(game.gamePixels);
				drawLineOntoSprite(game.gamePixels, anchorPoint.x, anchorPoint.y, endPoint.x, endPoint.y, 0x004400, 2);
			}
			else drawOntoSprite(game.gamePixels);
		}
		
		override public function kill():void
		{
			if (alive) 
			{
				timer.stop();
				timer.start(1, 1, onTimerDestroy);
				alive = false;
			}
		}
		
		public function checkBehavior():void
		{
			if (type == VINE)
			{
				var _grav:Number = Math.sqrt((game.gravity * gravityScale) / length);
				var _period:Number = (2 * Math.PI) / _grav;
				swingTime += FlxG.elapsed;
				if (swingTime > _period) swingTime -= _period;
				swingAngle = maxAngle * Math.sin(swingTime * _grav);
				endPoint.x = anchorPoint.x + length * Math.sin(swingAngle * Math.PI / 180);
				endPoint.y = anchorPoint.y + length * Math.cos(swingAngle * Math.PI / 180);
				width = height = 8;
				x = endPoint.x - width / 2;
				y = endPoint.y - height / 2;
				//FlxG.log(swingTime);
			}
			else if (type == ROLLING_LOG)
			{
				if (x + width < 0 || y > game.gamePixels.y + game.gamePixels.height) kill();
			}
		}
		
		public function actUpon(Obj:PlayerJumper):void
		{
			if (type == JungleBlock.VINE)
			{
				Obj.target.x = x + width / 2;
				Obj.target.y = y + height / 2;
				Obj.moveTowardTarget(true, 1.5);
				Obj.velocity.y = Obj.velocity.x = Obj.acceleration.x = Obj.acceleration.y = 0;
				Obj.play("swing");
				if (Obj.x > Obj.last.x) Obj.facing = FlxObject.RIGHT;
				else if (Obj.x < Obj.last.x) Obj.facing = FlxObject.LEFT;
			}
			else if (type == JungleBlock.LADDER || type == JungleBlock.LADDER_TOP)
			{
				if (overlaps(Obj) && Obj.onLadder)
				{
					Obj.target.x = x + width / 2;
					Obj.target.y = Obj.y + Obj.height / 2;
					Obj.moveTowardTarget(true, 1.5);
					//Subject.play("climb");
					Obj.velocity.x = 0;
					Obj.acceleration.y = 0;
					if ((Obj.controls & (Entity.UP | Entity.DOWN)) == 0) Obj.velocity.y = 0;
				}
				else 
				{
					if (type == JungleBlock.LADDER_TOP && (Obj.y < y)) Obj.onLadder = false;
					Obj.object = null;
				}
				
			}
		}
		
		/*public function get swingVelocity():FlxPoint
		{
			_swingVelocity.x = x - last.x;
			_swingVelocity.x /= FlxG.elapsed;
			_swingVelocity.y = y - last.y;
			_swingVelocity.y /= FlxG.elapsed;
			return _swingVelocity;
		}*/
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(Value:uint):void
		{
			alive = exists = true;
			alpha = 1;
			width = 16;
			height = 16;
			offset.x = offset.y = 0;
			x = slotX * width - 8;
			y = slotY * height - 8;
			slotZ = 0;
			anchorPoint = null;
			endPoint = null;
			solid = true;
			allowCollisions = FlxObject.ANY;
			visible = true;
			immovable = true;
			moves = false;
			blocksMovement = false;
			hurtsPlayer = false;
			killsPlayer = false;
			color = 0xffffff;
			
			switch (Value)
			{
				case AIR: 
					solid = false; 
					visible = false; 
					break;
				case BLOCK: 
					color = 0xb4a28f;
					blocksMovement = true;
					break;
				case SPIKES:
					height = 20;
					width = 12;
					y -= 4;
					x += 2;
					offset.y = -4;
					offset.x = 2;
					visible = true;
					killsPlayer = true;
					break;
				case BRIDGE: 
					color = 0x624a2e;
					blocksMovement = true;
					break;
				case OLD_BRIDGE: 
					color = 0x624a2e;
					blocksMovement = true;
					break;
				case LOG: 
					moves = false; 
					hurtsPlayer = true; 
					color = 0x624a2e;
					break;
				case WATER:
					height = 12;
					y += 4;
					offset.y = 4;
					slotZ = 1;
					killsPlayer = true;
					color = 0x89cffd;
					break;
				case VINE:
					swingOffset = slotX / 8;
					var _grav:Number = Math.sqrt((game.gravity * gravityScale) / length);
					var _period:Number = (2 * Math.PI) / _grav;
					swingTime = swingOffset * _period;
					visible = false;
					anchorPoint = new FlxPoint(x + width / 2, y);
					endPoint = new FlxPoint(0, 0);
					//makeGraphic(6, 6, 0xff000000);
					width = 8;
					height = 8;
					break;
				case STAIRS_LEFT:
					blocksMovement = true;
					color = 0xb4a28f;
					break;
				case STAIRS_RIGHT:
					blocksMovement = true;
					color = 0xb4a28f;
					break;
				case LADDER:
					color = 0xb3725f;
					break;
				case LADDER_TOP:
					color = 0xb3725f;
					break;
				case TREASURE:
					color = 0xffcc33;
					break;
				case ROLLING_LOG:
					moves = true;
					velocity.x = -speed;
					hurtsPlayer = true; 
					color = 0x624a2e;
					break;
				case TURTLE:
					blocksMovement = true;
					color = 0x00cc00;
					break;
				case WATER_LOG:
					color = 0x624a2e;
					blocksMovement = true;
					break;
			}
			_type = Value;
			play(blockTypes[Value]);
		}
		
		public function setPairedBlock():void
		{
			if (type == TURTLE || type == WATER_LOG) (game as GamePitJumper).setPairedBlock(WATER, slotX, slotY);
		}
		
		public function onTimerDestroy(Timer:FlxTimer):void
		{
			if (type == OLD_BRIDGE)
			{
				//solid = false;
				acceleration.y = 100;
				moves = true;
			}
			else if (type == ROLLING_LOG)
			{
				alpha = 1;
				alive = true;
				exists = true;
				visible = true;
				x = 160 - 1;
				y = slotY * 16 - 8;
				velocity.x = -speed;
				velocity.y = 0;
				play(blockTypes[type]);
			}
			else
			{
				alive = false;
				exists = false;
				x = -1000;
				y = -1000;
				behavior = "dead";
			}
			//FlxG.log("destroyed " + slotX + " " + slotY);
		}
		
		public function onTimerAttack(Timer:FlxTimer):void
		{
			
		}
		
		override public function translateInput():void
		{
			
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			alpha = 1;
		}
		
		public function collideWith(Player:PlayerJumper):void
		{
			if (blocksMovement) 
			{
				if (type == STAIRS_LEFT || type == STAIRS_RIGHT)
				{
					var _step:Number;
					if (type == STAIRS_LEFT)
					{
						_step = Player.x + Player.width / 2 + 1 - x;
						_step = Math.min(16, Math.ceil(_step / 4) * 4);
					}
					else
					{
						_step = x + width - Player.x - Player.width / 2 + 1;
						_step = Math.min(16, Math.ceil(_step / 4) * 4);
					}
					if (Player.y + Player.height >= y + height - _step)
					{
						Player.onGround = true;
						Player.y = y + height - _step - Player.height;
					}
				}
				else
				{
					FlxObject.separateX(this, Player);
					if (FlxObject.separateY(this, Player) && Player.y >= Player.last.y)
					{
						Player.onGround = true;
					}
				}
			}
			if (killsPlayer) 
			{
				if (type == SPIKES)
				{
					if (_curAnim.name == "spikes" || _curAnim.name == "spikes_reset") play("spikes_attack");
					if (timer.finished)
					{
						timer.stop();
						timer.start(0.8, 1, onTimerAnimation);
					}
					var _spikeHeight:Number = 0;
					if (_curAnim.name == "spikes_attack") _spikeHeight = _curFrame * 4 + 2;
					else if (_curAnim.name == "spikes_reset") _spikeHeight = 10 - _curFrame * 4;
					var _distance:Number = y + height - _spikeHeight - (Player.y + Player.height);
					if (_distance <= 0) Player.kill();
				}
				else Player.kill();
			}
			else if (hurtsPlayer)
			{
				game.score -= 1;
			}
			
			if (type == VINE)
			{
				if (timer.finished) if (!Player.object) if (!Player.wasOnGround) if (!Player.onLadder)
				{
					Player.object = this;
				}
			}
			else if (type == OLD_BRIDGE)
			{
				if (timer.finished) timer.start(0.4, 1, onTimerDestroy);
			}
			else if (type == LADDER || type == LADDER_TOP)
			{
				if (Player.wasOnGround)
				{
					if (Player.object && (Player.controls & Entity.DOWN) > 0) getOffLadder(Player);
					else if (!Player.object && (Player.controls & Entity.UP) > 0) getOnLadder(Player);
				}
				else if (Player.onLadder)
				{
					if (!Player.object) getOnLadder(Player);
				}
				else if (type == LADDER_TOP)
				{
					if ((Player.controls & Entity.DOWN) > 0) getOnLadder(Player);
					else 
					{
						Player.object = null;
						FlxObject.separateY(this, Player);
					}
				}
			}
			else if (type == TREASURE)
			{
				game.score += 200;
				solid = false;
				kill();
			}
		}
		
		public function getOnLadder(Player:PlayerJumper):void
		{
			FlxG.log("getOn " + blockTypes[type]);
			Player.object = this;
			Player.onLadder = true;
		}
		
		public function getOffLadder(Player:PlayerJumper):void
		{
			Player.object = null;
			Player.onLadder = false;
		}
		
		public function onTimerAnimation(Timer:FlxTimer):void
		{
			if (type == SPIKES) play("spikes_reset");
		}
		
		public function attack():void
		{
			
		}
		
		public function spawn(X:Number, Y:Number, Type:uint):void
		{
			reset(X - width / 2, Y - height - 100);
			velocity.x = velocity.y = 0;
			type = Type;
			//behavior = "spawn";
			play(blockTypes[type]);
		}
	}
}
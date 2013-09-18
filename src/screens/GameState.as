package screens
{
	import entities.*;
	
	import games.*;
	
	import org.flixel.*;
	
	public class GameState extends ScreenState
	{
		[Embed(source="../assets/images/table.png")] protected static var imgTable:Class;

		private var videoGame:VideoGame;
		//private var videoGame2:VideoGame;
		private var television:Television;
		//private var television2:Television;
		private var table:FlxSprite;
		private var gamepad:Gamepad;
		private var player:Player;
		private var buttons:FlxGroup;
		private var meta:FlxGroup;
		private var tableOffset:uint = 198;
		
		public static const GRAVITY:Number = 400;
		
		public function GameState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
						
			table = new FlxSprite(-80, 151 + tableOffset);
			table.loadGraphic(imgTable, false, false, 640, 89);
			table.scale.x = table.scale.y = 2;
			television = new Television(0.5 * (FlxG.width - 429), -37);
			//if (FlxG.random() > 0.9) videoGame = new GameInvade(television);
			//else videoGame = new GamePitJumper(television);
			videoGame = new GameInvade(television);
			
			gamepad = new Gamepad();
			player = new Player(gamepad.x + 24, gamepad.y + 8 + tableOffset);
			buttons = new FlxGroup(8);
			
			var _button:GamepadButton;
			for (var i:uint = 0; i < 8; i++)
			{
				_button = new GamepadButton(gamepad, i);
				buttons.add(_button);
				gamepad.inputs.push(_button);
			}
			gamepad.acceptInput = true;
			Baseball.group = new FlxGroup(10);
			for (i = 0; i < 10; i++)
			{
				Baseball.group.add(new Baseball());
			}
			player.ammo = Baseball.group;
			player.input = gamepad;

			add(videoGame);
			add(television);
			add(table);
			add(gamepad);
			add(buttons);
			add(player);
			add(Baseball.group);
			
			meta = new FlxGroup();
			meta.add(Baseball.group);
			meta.add(player);
		}
		
		override public function update():void
		{	
			super.update();
			if (videoGame) if (gamepad) 
			{
				videoGame.acceptInput(gamepad.controls);
			}
			FlxG.overlap(meta, buttons, pressButton);
			FlxG.overlap(meta, meta, pickupBall);
		}
		
		public function pressButton(Obj1:FlxObject, Obj2:FlxObject):void
		{
			if (Obj1 is GamepadButton && Obj2 is Player) 
			{
				if ((Obj2 as Player).z <= 0) (Obj1 as GamepadButton).pressFrames = 1;
			}
			else if (Obj2 is GamepadButton && Obj1 is Player)
			{
				if ((Obj1 as Player).z <= 0) (Obj2 as GamepadButton).pressFrames = 1;
			}
			else if (Obj1 is GamepadButton && Obj2 is Baseball) 
			{
				if ((Obj2 as Baseball).z <= 0) (Obj1 as GamepadButton).pressFrames = 3;
			}
			else if (Obj2 is GamepadButton && Obj1 is Baseball)
			{
				if ((Obj1 as Baseball).z <= 0) (Obj2 as GamepadButton).pressFrames = 3;
			}
		}
		
		public function pickupBall(Obj1:FlxObject, Obj2:FlxObject):void
		{
			if (Obj1 is Baseball && Obj2 is Player) 
			{
				if ((Obj1 as Baseball).z <= 0 && (Obj2 as Player).z <= 0) (Obj1 as Baseball).kill();
			}
			else if (Obj2 is Baseball && Obj1 is Player)
			{
				if ((Obj2 as Baseball).z <= 0 && (Obj1 as Player).z <= 0) (Obj2 as Baseball).kill();
			}
			else if (Obj1 is Baseball && Obj2 is Baseball)
			{
				if ((Obj1 as Baseball).z <= 0 && (Obj2 as Baseball).z <= 0)
				{
					(Obj1 as Baseball).onHitGround();
					(Obj2 as Baseball).onHitGround();
				}
			}
		}
	}
}
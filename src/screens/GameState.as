package screens
{
	import entities.*;
	
	import org.flixel.*;
	
	public class GameState extends ScreenState
	{
		[Embed(source="../assets/images/table.png")] protected static var imgTable:Class;

		private var screen:TVScreen;
		private var television:Television;
		private var table:FlxSprite;
		private var gamepad:Gamepad;
		private var player:Player;
		private var playerShip:PlayerShip;
		private var buttons:FlxGroup;
		private var meta:FlxGroup;
		private var inGame:FlxGroup;
		private var lifeText:FlxText;
		private var spawnTimer:FlxTimer;
		private var newHighScore:Boolean = false;
		public static var restartGame:Boolean = false;
		
		public function GameState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			FlxG.scores.push(49);
			spawnTimer = new FlxTimer();
			spawnTimer.start(0.01);
			
			table = new FlxSprite(-80, 151);
			table.loadGraphic(imgTable, false, false, 640, 89);
			television = new Television(87, 18);
			screen = new TVScreen(television.x + 15, television.y + 28);
			playerShip = new PlayerShip(screen);
			score = new FlxText(screen.x + 4, screen.y + 2, screen.width - 8, "");
			info = new FlxText(screen.x + 6, screen.y + 32, screen.width - 12, "PRESS START");
			info.alignment = "center";
			infoTimer = new FlxTimer();
			infoTimer.start(1, 1, onTimerInfo);
			lifeText = new FlxText(screen.x + 6, screen.y + screen.height - 10, screen.width - 12, "");
			lifeText.alignment = "right";
			
			gamepad = new Gamepad(13, 148);
			player = new Player(gamepad.x + 24, gamepad.y + 8);
			buttons = new FlxGroup(8);
			
			var _button:GamepadButton;
			for (var i:uint = 0; i < 8; i++)
			{
				_button = new GamepadButton(gamepad, i);
				buttons.add(_button);
				gamepad.inputs.push(_button);
			}
			Baseball.group = new FlxGroup(10);
			for (i = 0; i < 10; i++)
			{
				Baseball.group.add(new Baseball());
			}
			player.ammo = Baseball.group;
			
			var _laser:Laser;
			Laser.group = new FlxGroup(10);
			for (i = 0; i < 10; i++)
			{
				_laser = new Laser();
				_laser.input = screen;
				Laser.group.add(_laser);
			}
			playerShip.ammo = Laser.group;
			
			var _enemy:EnemyShip;
			EnemyShip.group = new FlxGroup(40);
			for (i = 0; i < 40; i++)
			{
				_enemy = new EnemyShip(screen);
				EnemyShip.group.add(_enemy);
			}
			EnemyShip.ammo = Laser.group;
			
			screen.inputs.push(gamepad);
			player.input = gamepad;
			playerShip.input = screen;
			
			screen.acceptInput = true;
			gamepad.acceptInput = true;
			playerShip.acceptInput = true;
			
			add(screen);
			add(EnemyShip.group);
			add(playerShip);
			add(Laser.group);
			add(score);
			add(info);
			add(lifeText);
			add(television);
			add(table);
			add(gamepad);
			add(buttons);
			add(player);
			add(Baseball.group);
			
			meta = new FlxGroup();
			meta.add(Baseball.group);
			meta.add(player);
			
			inGame = new FlxGroup();
			inGame.add(playerShip);
			inGame.add(EnemyShip.group);
			inGame.add(Laser.group);
		}
		
		override public function update():void
		{	
			super.update();
			FlxG.overlap(meta, buttons, pressButton);
			FlxG.overlap(meta, meta, pickupBall);
			FlxG.overlap(inGame, inGame, gameCollisions);
			
			if (FlxG.score > FlxG.scores[0] && !newHighScore) 
			{
				newHighScore = true;
				Entity.playRandomSound(Entity.sfxHighScore, 0.6);
			}
			if (newHighScore)
			{
				FlxG.scores[0] = FlxG.score;
				score.text = "  NEW HI-SCORE " + formatScore(FlxG.score, 3);
			}
			else score.text = "HI " + formatScore(FlxG.scores[0], 3) + "            P1 " + formatScore(FlxG.score, 3);
			//if (screen.gameStarted) info.text = "";
			lifeText.text = playerShip.lifeString;
			
			var _seed:Number;
			with (EnemyShip) {
				if (formation.x <= 0 && formation.y <= 0)
				{
					formation.x = formation.y = 0;
					_seed = FlxG.random();
					if (_seed < 0.5) formation.x += EnemyShip.formationSpeed;
					else formation.y += EnemyShip.formationSpeed;
					formationNegativeDirection = false;
				}
				else if (formation.x <= 0 && formation.y >= formationMax.y)
				{
					formation.x = 0;
					formation.y = formationMax.y;
					_seed = FlxG.random();
					if (_seed < 0.5) 
					{
						formation.x += EnemyShip.formationSpeed;
						formationNegativeDirection = false;
					}
					else 
					{
						formation.y -= EnemyShip.formationSpeed;
						formationNegativeDirection = true;
					}
				}
				else if (formation.x >= formationMax.x && formation.y <= 0)
				{
					formation.x = formationMax.x;
					formation.y = 0;
					_seed = FlxG.random();
					if (_seed < 0.5) 
					{
						formation.x -= EnemyShip.formationSpeed;
						formationNegativeDirection = true;
					}
					else 
					{
						formation.y += EnemyShip.formationSpeed;
						formationNegativeDirection = false;
					}
				}
				else if (formation.x >= formationMax.x && formation.y >= formationMax.y)
				{
					formation.x = formationMax.x;
					formation.y = formationMax.y;
					_seed = FlxG.random();
					if (_seed < 0.5) 
					{
						formation.x -= EnemyShip.formationSpeed;
						formationNegativeDirection = true;
					}
					else 
					{
						formation.y -= EnemyShip.formationSpeed;
						formationNegativeDirection = true;
					}
				}
				else
				{
					if (formationNegativeDirection)
					{
						if (formation.x <= 0 || formation.x >= formationMax.x) formation.y -= EnemyShip.formationSpeed;
						else if (formation.y <= 0 || formation.y >= formationMax.y) formation.x -= EnemyShip.formationSpeed;
					}	
					else
					{
						if (formation.x <= 0 || formation.x >= formationMax.x) formation.y += EnemyShip.formationSpeed;
						else if (formation.y <= 0 || formation.y >= formationMax.y) formation.x += EnemyShip.formationSpeed;
					}
				}
			}
			
			if (spawnTimer.finished) if (TVScreen.gameStarted) if (EnemyShip.slotsFilled < EnemyShip.maxSlots)
			{
				var _multi:Number = EnemyShip.handicap;
				if (EnemyShip.slotsFilled < 2) _multi /= 3;
				else if (EnemyShip.slotsFilled < 4) _multi /= 1.5;
				else if (EnemyShip.slotsFilled >= 8) _multi *= 1.5; 
				if (EnemyShip.slotsFilled < EnemyShip.maxSlots) spawnTimer.start(FlxG.random() * _multi + _multi / 2, 1, onTimerSpawn);
			}
			//if (FlxG.keys["P"]) playerShip.kill();
			//if (FlxG.keys["O"]) restartGame();
		}
		
		public function restartGame():void
		{
			inGame.callAll("kill", true);
			EnemyShip.handicap = 3.5;
			playerShip.lives = 4;
			playerShip.reset(screen.x + screen.width / 2 - playerShip.width / 2, screen.y + screen.height - playerShip.height - 4);
			FlxG.score = 0;
		}
		
		private function onTimerSpawn(Timer:FlxTimer):void
		{
			var _seed:Number = FlxG.random();
			if (_seed < 1/4)
			{
				EnemyShip.spawn(FlxG.width / 2, 0, "bomber");
			}
			else EnemyShip.spawn(FlxG.width / 2, 0, "shooter");
		}
		
		private function onTimerInfo(Timer:FlxTimer):void
		{
			if (TVScreen.gameStarted)
			{
				//FlxG.log("start game");
				if (playerShip.lives == 0 && !playerShip.alive)
				{
					if (GameState.restartGame)
					{
						GameState.restartGame = false;
						restartGame();
					}
					if (newHighScore) 
					{
						StoryState.playEnding = true;
						goToStory();
					}
					else if (info.text == "") 
					{
						info.text = "GAME OVER";
						infoTimer.start(0.75, 1, onTimerInfo);
					}
					else
					{
						info.text = "";
						infoTimer.start(0.5, 1, onTimerInfo);
					}
				}
				else 
				{
					GameState.restartGame = false;
					info.text = "";
					infoTimer.start(0.25, 1, onTimerInfo);
				}
			}
			else 
			{
				if (info.text == "") 
				{
					info.text = "PRESS START";
					infoTimer.start(0.75, 1, onTimerInfo);
				}
				else
				{
					info.text = "";
					infoTimer.start(0.5, 1, onTimerInfo);
				}
			}
		}
		
		public function gameCollisions(Obj1:FlxObject, Obj2:FlxObject):void
		{
			if (Obj1 is Laser && Obj2 is EnemyShip) 
			{
				if ((Obj1 as Laser).belongsToPlayer && Obj2.alive) 
				{
					(Obj1 as Laser).kill();
					(Obj2 as EnemyShip).kill();
					FlxG.score += 1;
					if (FlxG.score < 4) EnemyShip.handicap == 3.5;
					else if (FlxG.score < 8) EnemyShip.handicap = 3;
					else if (FlxG.score < 16) EnemyShip.handicap = 2.5;
					else if (FlxG.score < 32) EnemyShip.handicap = 2;
					else if (FlxG.score < 64) EnemyShip.handicap = 1.5;
					else if (FlxG.score < 128) EnemyShip.handicap = 1.25;
					else if (FlxG.score < 256) EnemyShip.handicap = 1;
					else if (FlxG.score < 512) EnemyShip.handicap = 0.75;
					else EnemyShip.handicap = 0.5;
				}
			}
			else if (Obj2 is Laser && Obj1 is EnemyShip)
			{
				if ((Obj2 as Laser).belongsToPlayer && Obj1.alive) 
				{
					(Obj2 as Laser).kill();
					(Obj1 as EnemyShip).kill();
					FlxG.score += 1;
					if (FlxG.score < 4) EnemyShip.handicap == 3.5;
					else if (FlxG.score < 8) EnemyShip.handicap = 3;
					else if (FlxG.score < 16) EnemyShip.handicap = 2.5;
					else if (FlxG.score < 32) EnemyShip.handicap = 2;
					else if (FlxG.score < 64) EnemyShip.handicap = 1.5;
					else if (FlxG.score < 128) EnemyShip.handicap = 1.25;
					else if (FlxG.score < 256) EnemyShip.handicap = 1;
					else if (FlxG.score < 512) EnemyShip.handicap = 0.75;
					else EnemyShip.handicap = 0.5;
				}
			}
			else if (Obj1 is Laser && Obj2 is PlayerShip) 
			{
				if (!(Obj1 as Laser).belongsToPlayer) 
				{
					if ((Obj2 as PlayerShip).shields) (Obj1 as Laser).kill();
					else (Obj2 as PlayerShip).kill();
				}
			}
			else if (Obj2 is Laser && Obj1 is PlayerShip)
			{
				if (!(Obj2 as Laser).belongsToPlayer) 
				{
					if ((Obj1 as PlayerShip).shields) (Obj2 as Laser).kill();
					else (Obj1 as PlayerShip).kill();
				}
			}
			else if (Obj1 is EnemyShip && Obj2 is PlayerShip)
			{
				if (Obj1.alive) 
				{
					(Obj1 as EnemyShip).kill();
					if (!(Obj2 as PlayerShip).shields) (Obj2 as PlayerShip).kill();
				}
			}
			else if (Obj2 is EnemyShip && Obj1 is PlayerShip)
			{
				if (Obj2.alive) 
				{
					(Obj2 as EnemyShip).kill();
					if (!(Obj1 as PlayerShip).shields) (Obj1 as PlayerShip).kill();
				}
			}
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
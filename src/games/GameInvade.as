package games
{
	import entities.*;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import screens.*;
	
	public class GameInvade extends VideoGame
	{
		[Embed(source="../assets/images/titleInvade.png")] protected static var imgTitleCards:Class;
		
		public var particle:Particle;
		public var particles:FlxGroup;
		public var playerShip:PlayerShip;
		public var enemyShip:EnemyShip;
		public var enemyShips:FlxGroup;
		public var laser:Laser;
		public var lasers:FlxGroup;
		
		public var slots:Array = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		public var formation:FlxPoint = new FlxPoint(0, 0);
		public var formationMax:FlxPoint = new FlxPoint(48, 6);
		public var formationNegativeDirection:Boolean = false;
		public var formationSpeed:Number = 0.1;
		public var maxSlots:uint = 12;
		public var slotsFilled:uint = 0;
		public var group:FlxGroup;
		public var handicap:Number = 5;
		
		public function GameInvade(TV:Television)
		{
			super(TV);
			
			titleCard = new Entity(0, 0, this);
			titleCard.loadGraphic(imgTitleCards, true, false, 111, 80);
			titleCard.addAnimation("none",[0]);
			titleCard.addAnimation("invade",[1]);
			titleCard.play("invade");
			titleCard.color = 0xff0000;
			
			offsetOverlay = new FlxPoint(0, -90);
			
			timerSpawn = new FlxTimer();
			timerSpawn.start(0.01);
			
			//screen = new TVScreen(television.x + 15, television.y + 28);
			playerShip = new PlayerShip(this);
			
			textScore = new GameText(this, 2, 2, "");
			textScore.tabStops = [20, 66];
			textInfo = new GameText(this, 4, 2, "\n\n\n\n      PRESS START");
			textInfo.alignment = "left";
			timerInfo = new FlxTimer();
			timerInfo.start(1, 1, onTimerInfo);
			textLives = new GameText(this, 6, gamePixels.height - 10, "");
			textLives.alignment = "right";
			
			highScores = [99, 65, 59, 55, 49];
			topPlayers = ["LD48","MEGABOZ","IDKFA","ABACABB","JUSTINB"];
			score = 0;
			
			particles = new FlxGroup(60);
			for (var i:uint = 0; i < 60; i++)
			{
				particle = new Particle(this, true);
				particles.add(particle);
			}
			
			lasers = new FlxGroup(20);
			for (i = 0; i < 20; i++)
			{
				laser = new Laser(this);
				lasers.add(laser);
			}
			
			enemyShips = new FlxGroup(15);
			for (i = 0; i < 15; i++)
			{
				enemyShip = new EnemyShip(this);
				enemyShips.add(enemyShip);
			}
			//playerShip.screen = this;
			
			playerShip.acceptInput = true;			
			
			add(particles);
			add(enemyShips);
			add(playerShip);
			add(lasers);
			add(textScore);
			add(textLives);
			add(textInfo);
			add(titleCard);
			add(gamePixels);
			
			inGame = new FlxGroup();
			inGame.add(playerShip);
			inGame.add(enemyShips);
			inGame.add(lasers);
			//add(inGame);
			
			timerSwitchState = new FlxTimer();
			gameState = TITLE_SCREEN;
		}
		
		override public function update():void
		{	
			super.update();
			
			textLives.text = playerShip.lifeString;
			
			updateFormation();
			updateStarField();
			
			if (timerSpawn.finished) if (spawnEnemies) if (slotsFilled < maxSlots)
			{
				var _multi:Number = handicap;
				if (slotsFilled < 2) _multi /= 3;
				else if (slotsFilled < 4) _multi /= 1.5;
				else if (slotsFilled >= 8) _multi *= 1.5; 
				if (slotsFilled < maxSlots) timerSpawn.start(FlxG.random() * _multi + _multi / 2, 1, onTimerSpawn);
			}
			if (gameState == PLAY_GAME && playerShip.lives == 0 && !playerShip.alive) 
			{
				if (newHighScore) gameState = NAME_ENTRY;
				else gameState = GAME_OVER;
			}
			if (offsetOverlay.y > 0) offsetOverlay.y = Math.max(0, offsetOverlay.y - 0.5);
			else if (offsetOverlay.y < 0) offsetOverlay.y = Math.min(0, offsetOverlay.y + 0.5);
			titleCard.offset.y = offsetOverlay.y;
			textInfo.offset.y = offsetOverlay.y;
			textLives.offset.y = offsetOverlay.y;
			textScore.offset.y = offsetOverlay.y;
			
			//if (FlxG.keys.justPressed("P")) playerShip.kill();
			//if (FlxG.keys.justPressed("O")) score += 10;
			//if (FlxG.keys.justPressed("I")) playerAutoPilot = !playerAutoPilot;
		}
		
		private function updateStarField():void
		{
			var _count:int = particles.countLiving();
			var _seed:Number = Math.floor(FlxG.random() * 50);
			if (_count < 5 + _seed) 
			{
				spawnStar();
				particles.sort("ID");
			}
		}
		
		override protected function startButton():void
		{
			switch (gameState) {
				case TITLE_SCREEN: gameState = PLAY_GAME; break;
				case ATTRACT_MODE: gameState = TITLE_SCREEN; break;
				case HIGH_SCORES: gameState = TITLE_SCREEN; break;
				//case PLAY_GAME: gameState = PAUSED; break;
				//case PAUSED: gameState = PLAY_GAME; break;
				case GAME_OVER: gameState = TITLE_SCREEN; break;
				case NAME_ENTRY:
					timerInfo.stop();
					//FlxG.log("name = \"" + name + "\" and rank = " + currentScoreRanking);
					topPlayers[_scoreRank] = name;
					if (name == "HELPME ") 
					{
						StoryState.playEnding = true;
						ScreenState.fadeToStory();
					}
					else gameState = HIGH_SCORES;
					break;
			}
			offsetOverlay.y = 0;
		}
		
		override protected function restartGame():void
		{
			inGame.callAll("removeFromPlay", true);
			handicap = 3.5;
			playerShip.lives = 4;
			playerShip.reset(gamePixels.width / 2 - playerShip.width / 2, gamePixels.height - playerShip.height - 4);
			newHighScore = false;
			score = 0;
			textInfo.text = "";
			textInfo.visible = false;
			timerInfo.stop();
		}
		
		private function onTimerSpawn(Timer:FlxTimer):void
		{
			var _seed:Number = FlxG.random();
			if (_seed < 1/4)
			{
				spawnEnemy(gamePixels.width / 2, gamePixels.height / 2, "bomber");
			}
			else spawnEnemy(gamePixels.width / 2, gamePixels.height / 2, "shooter");
		}
		
		public function spawnStar():void
		{
			particle = Particle(particles.getFirstAvailable(Particle));
			if (particle) particle.spawnStar();
		}
		
		public function spawnEnemy(X:Number, Y:Number, Type:String):void
		{
			enemyShip = EnemyShip(enemyShips.getFirstAvailable(EnemyShip));
			if (enemyShip) enemyShip.spawn(X, Y, Type);
		}
		
		public function spawnLaser(Attacker:Entity):Boolean
		{
			laser = Laser(lasers.getFirstAvailable(Laser));
			if (laser) 
			{
				laser.spawn(Attacker);
				return true;
			}
			else return false;
		}
		
		override public function set score(Score:int):void
		{
			_score = Score;
			if (_score < 4) handicap = 3.5;
			else if (_score < 8) handicap = 3;
			else if (_score < 16) handicap = 2.5;
			else if (_score < 32) handicap = 2;
			else if (_score < 64) handicap = 1.5;
			else if (_score < 128) handicap = 1.25;
			else if (_score < 256) handicap = 1;
			else if (_score < 512) handicap = 0.75;
			else handicap = 0.5;
			
			//handicap = BUNNY_SPAWN * (Math.log(_score) / Math.log(2));
			
			if (gameState == HIGH_SCORES) 
			{
				textScore.color = 0xff0000;
				textScore.text = "      TOP PLAYERS";
			}
			else
			{
				textScore.color = 0xffffff;
				if (newHighScore)
				{
					//highScores[0] = _score;
					var _rank:uint = scoreRank;
					if (_rank == 0) textScore.text = ordinalStrings[0] + " " + formatScore(_score, 3);
					else textScore.text = ordinalStrings[_rank - 1] + " " + formatScore(highScores[_rank - 1], 3);
					if (showPlayerScore) textScore.text += "\tP1 " + formatScore(_score, 3);
				}
				else
				{
					textScore.text = "5TH " + formatScore(highScores[4], 3);
					if (showPlayerScore) textScore.text += "\tP1 " + formatScore(_score, 3);
					if (_score > highScores[4]) 
					{
						newHighScore = true;
						Entity.playRandomSound(Entity.sfxHighScore, 0.6);
					}
				}
			}
		}
		
		override public function onTimerSwitchState(Timer:FlxTimer):void
		{
			timerSwitchState.stop();
			if (gameState == TITLE_SCREEN) gameState = ATTRACT_MODE;
			else if (gameState == ATTRACT_MODE) gameState = HIGH_SCORES;
			else if (gameState == HIGH_SCORES) gameState = TITLE_SCREEN;
			else if (gameState == PLAY_GAME) gameState = GAME_OVER;
			else if (gameState == GAME_OVER) gameState = TITLE_SCREEN;
		}
		
		override public function set gameState(GameState:int):void
		{
			super.gameState = GameState;
			
			FlxG.log(gameStateNames[_gameState]);
			
			//default settings
			spawnEnemies = false;
			startButtonOnly = false;
			playerShip.autoPilot = false;
			playerShip.acceptInput = true;
			gameHasStarted = false;
			paused = false;
			flashInfoText = false;
			textInfo.color = 0xffffff;
			showPlayerScore = false;
			titleCard.visible = false;
			offsetOverlay.y = 0;
			timerSwitchState.stop();
			
			//gamestate-specific settings
			switch (_gameState) {
				case TITLE_SCREEN:
					inGame.callAll("removeFromPlay", true);
					startButtonOnly = true;
					flashInfoText = true;
					titleCard.visible = true;
					textInfo.text = "\n\n\n\n      PRESS START";
					textInfo.visible = true;
					onTimerInfo(timerInfo);
					offsetOverlay.y = -90;
					titleCard.visible = true;
					timerSwitchState.start(8, 1, onTimerSwitchState)
					break;
				case ATTRACT_MODE:
					restartGame();
					spawnEnemies = true;
					playerShip.autoPilot = true;
					playerShip.acceptInput = false;
					startButtonOnly = true;
					flashInfoText = true;
					textInfo.text = "\n\n\n\n       DEMO MODE";
					textInfo.visible = true;
					onTimerInfo(timerInfo);
					timerSwitchState.start(15, 1, onTimerSwitchState)
					break;
				case HIGH_SCORES:
					inGame.callAll("removeFromPlay", true);
					startButtonOnly = true;
					offsetOverlay.y = -90;
					//textInfo.color = 0xff0000;
					textInfo.text = highScoresList();
					textInfo.visible = true;
					timerSwitchState.start(10, 1, onTimerSwitchState)
					break;
				case PLAY_GAME:
					spawnEnemies = true;
					gameHasStarted = true;
					showPlayerScore = true;
					restartGame();
					break;
				case PAUSED:
					startButtonOnly = true;
					gameHasStarted = true;
					showPlayerScore = true;
					paused = true;
					break;
				case GAME_OVER:
					startButtonOnly = true;
					showPlayerScore = true;
					textInfo.text = "\n\n\n\n        GAME OVER";
					textInfo.visible = true;
					onTimerInfo(timerInfo);
					timerSwitchState.start(6, 1, onTimerSwitchState);
					break;
				case NAME_ENTRY:
					inGame.callAll("removeFromPlay", true);
					gameHasStarted = true;
					//textInfo.color = 0xff0000;
					insertNewScore();
					textScore.text = "   ENTER YOUR NAME";
					textInfo.text = highScoresList();
					textInfo.visible = true;
					onTimerNameEntry(timerInfo);
					break;
			}
			score = score;
		}
		
		override public function checkForCollisions(Obj1:FlxObject, Obj2:FlxObject):void
		{
			if (Obj1 is Laser && Obj2 is Laser) return;
			else if (Obj1 is EnemyShip && Obj2 is EnemyShip) return;
			else if (Obj1 is PlayerShip && Obj2 is PlayerShip) return;
			
			if (Obj2 is PlayerShip) checkForCollisions(Obj2, Obj1);
			else if (Obj2 is EnemyShip && !(Obj1 is PlayerShip)) checkForCollisions(Obj2, Obj1);
			
			if (Obj1 is EnemyShip && Obj2 is Laser)
			{
				if ((Obj2 as Laser).belongsToPlayer && Obj1.alive) 
				{
					(Obj2 as Laser).kill();
					(Obj1 as EnemyShip).kill();
					if (gameState == PLAY_GAME) score += 1;
				}
			}
			else if (Obj1 is PlayerShip && Obj2 is Laser)
			{
				if (!(Obj2 as Laser).belongsToPlayer) 
				{
					if ((Obj1 as PlayerShip).shields) (Obj2 as Laser).kill();
					else (Obj1 as PlayerShip).kill();
				}
			}
			else if (Obj1 is PlayerShip && Obj2 is EnemyShip)
			{
				if (Obj2.alive) 
				{
					(Obj2 as EnemyShip).kill();
					if (!(Obj1 as PlayerShip).shields) (Obj1 as PlayerShip).kill();
				}
			}
		}
		
		private function updateFormation():void
		{
			//if (paused) return;
			var _seed:Number;
			with (enemyShips) {
				if (formation.x <= 0 && formation.y <= 0)
				{
					formation.x = formation.y = 0;
					_seed = FlxG.random();
					if (_seed < 0.5) formation.x += formationSpeed;
					else formation.y += formationSpeed;
					formationNegativeDirection = false;
				}
				else if (formation.x <= 0 && formation.y >= formationMax.y)
				{
					formation.x = 0;
					formation.y = formationMax.y;
					_seed = FlxG.random();
					if (_seed < 0.5)
					{
						formation.x += formationSpeed;
						formationNegativeDirection = false;
					}
					else 
					{
						formation.y -= formationSpeed;
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
						formation.x -= formationSpeed;
						formationNegativeDirection = true;
					}
					else
					{
						formation.y += formationSpeed;
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
						formation.x -= formationSpeed;
						formationNegativeDirection = true;
					}
					else 
					{
						formation.y -= formationSpeed;
						formationNegativeDirection = true;
					}
				}
				else
				{
					if (formationNegativeDirection)
					{
						if (formation.x <= 0 || formation.x >= formationMax.x) formation.y -= formationSpeed;
						else if (formation.y <= 0 || formation.y >= formationMax.y) formation.x -= formationSpeed;
					}	
					else
					{
						if (formation.x <= 0 || formation.x >= formationMax.x) formation.y += formationSpeed;
						else if (formation.y <= 0 || formation.y >= formationMax.y) formation.x += formationSpeed;
					}
				}
			}
		}
		
	}
}
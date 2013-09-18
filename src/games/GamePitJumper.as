package games
{
	import entities.*;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	import screens.*;
	
	public class GamePitJumper extends VideoGame
	{
		[Embed(source="../assets/images/titleJungle.png")] protected static var imgTitleCards:Class;
		[Embed(source="../assets/images/jungle_backdrops.png")] protected static var imgBackdrops:Class;
		
		public var playerJumper:PlayerJumper;
		public var block:JungleBlock;
		public var blocks:FlxGroup;
		public var maxSlotsX:uint = 11;
		public var maxSlotsY:uint = 8;
		//public var spareBlock:JungleBlock;
				
		private static var blockMap0:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 13,
												01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01	];
		
		private static var blockMap1:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 02, 00, 00, 02, 00, 00, 00, 00,
												01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01	];
		
		private static var blockMap2:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 07, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 01, 01, 01, 00, 00, 00, 01, 01, 01, 00,
												01, 01, 01, 01, 06, 06, 06, 01, 01, 01, 01	];
		
		private static var blockMap3:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 01, 12, 00, 00, 00, 00, 00, 00, 00, 01,
												00, 01, 01, 04, 04, 01, 01, 01, 01, 11, 01,
												00, 00, 00, 00, 00, 07, 00, 00, 00, 10, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 10, 00,
												00, 00, 12, 00, 00, 00, 00, 00, 00, 10, 00,
												00, 01, 01, 01, 02, 02, 02, 01, 01, 01, 00,
												01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01	];
		
		private static var blockMap4:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 01, 00, 00, 00, 01, 00, 00, 00,
												00, 00, 00, 07, 00, 00, 00, 07, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												01, 01, 00, 00, 00, 00, 00, 00, 00, 01, 01	];
		
		private static var blockMap5:Array = [	01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00,
												01, 01, 06, 14, 06, 14, 06, 14, 06, 01, 01	];
		
		private static var blockMaps:Array = [blockMap0, blockMap1, blockMap2, blockMap3, blockMap4, blockMap5];
		
		public function GamePitJumper(TV:Television)
		{
			super(TV);
			
			_uniqueKey = FlxG.random().toString();
			gamePixels.makeGraphic(160, 120, 0xff000000, true, _uniqueKey);
			
			//TV.screen.width = 320;
			//TV.screen.height = 240;
			
			backdrop = new Entity(0, 0, this);
			backdrop.loadGraphic(imgBackdrops, true, false, 160, 120);
			backdrop.addAnimation("none",[1]);
			backdrop.addAnimation("jungle",[0]);
			backdrop.play("jungle");
			
			titleCard = new Entity(0, 0, this);
			titleCard.loadGraphic(imgTitleCards, true, false, 160, 120);
			titleCard.addAnimation("none",[0]);
			titleCard.addAnimation("jungle",[1]);
			titleCard.play("jungle");
			titleCard.color = 0x119900;
			
			offsetOverlay = new FlxPoint(0, -90);
			
			timerSpawn = new FlxTimer();
			timerSpawn.start(0.01);
			
			playerJumper = new PlayerJumper(this);
			
			textScore = new GameText(this, 2, 2, "");
			textScore.color = 0x000000;
			textScore.tabStops = [20, 66];
			textInfo = new GameText(this, 4, 2, "\n\n\n\n      PRESS START");
			textInfo.alignment = "left";
			timerInfo = new FlxTimer();
			timerInfo.start(1, 1, onTimerInfo);
			textLives = new GameText(this, 6, height - 10, "");
			textLives.alignment = "right";
			
			highScores = [99, 65, 59, 55, 49];
			topPlayers = ["HARRY","LARRY","GARY","JERRY","BARRY"];
			score = 0;
			
			var _type:uint = JungleBlock.AIR;
			blocks = new FlxGroup(88);
			for (var _y:uint = 0; _y < maxSlotsY; _y++)
			{
				for (var _x:uint = 0; _x < maxSlotsX; _x++)
				{
					block = new JungleBlock(this, _x, _y, _type);
					blocks.add(block);
				}
			}
			
			add(backdrop);
			add(blocks);
			add(playerJumper);
			add(textScore);
			add(textLives);
			add(textInfo);
			add(titleCard);
			add(gamePixels);
			
			inGame = new FlxGroup();
			inGame.add(playerJumper);
			inGame.add(blocks);
			//add(inGame);
			
			timerSwitchState = new FlxTimer();
			gameState = TITLE_SCREEN;
		}
		
		override public function update():void
		{	
			super.update();
			
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
		
		public function setPairedBlock(Type:uint, SlotX:uint, SlotY:uint):void
		{
			var i:uint = 0;
			while (block.type != JungleBlock.AIR && i < blocks.length)
			{
				block = blocks.members[i++];
			}
			
			if (block.type == JungleBlock.AIR)
			{
				block.slotX = SlotX;
				block.slotY = SlotY;
				block.type = Type;
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
			var _index:uint;
			level = 0;
			//inGame.callAll("removeFromPlay", true);
			playerJumper.respawn();
			newHighScore = false;
			score = 0;
			textInfo.text = "";
			textInfo.visible = false;
			timerInfo.stop();
		}
		
		override public function set score(Score:int):void
		{
			_score = Score;
						
			if (gameState == HIGH_SCORES) 
			{
				textScore.color = 0xff0000;
				textScore.text = "      TOP PLAYERS";
			}
			else
			{
				textScore.color = 0x000000;
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
		
		override public function set level(Value:int):void
		{
			var _nextLevel:Boolean = false;
			if (Value > _level) _nextLevel = true;
			_level = Value;
			if (_level == blockMaps.length) _level = 0;
			else if (_level < 0) _level = blockMaps.length - 1;
			
			var _index:uint;
			for (var _y:uint = 0; _y < maxSlotsY; _y++)
			{
				for (var _x:uint = 0; _x < maxSlotsX; _x++)
				{
					_index = _y * maxSlotsX + _x;
					block = blocks.members[_index];
					block.slotX = _x;
					block.slotY = _y;
					block.type = blockMaps[_level][_index];
				}
			}
			
			for (_y = 0; _y < maxSlotsY; _y++)
			{
				for (_x = 0; _x < maxSlotsX; _x++)
				{
					_index = _y * maxSlotsX + _x;
					block = blocks.members[_index];
					block.setPairedBlock();
				}
			}
			
			blocks.sort("slotZ");
			
			if (_nextLevel) playerJumper.x = playerJumper.last.x = - playerJumper.width / 2;
			else playerJumper.x = playerJumper.last.x = gamePixels.width - playerJumper.width / 2;
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
			
			//FlxG.log(gameStateNames[_gameState]);
			
			//default settings
			spawnEnemies = false;
			startButtonOnly = false;
			gameHasStarted = false;
			paused = false;
			flashInfoText = false;
			textInfo.color = 0x000000;
			showPlayerScore = false;
			titleCard.visible = false;
			backdrop.visible = false;
			offsetOverlay.y = 0;
			timerSwitchState.stop();
			
			//gamestate-specific settings
			switch (_gameState) {
				case TITLE_SCREEN:
					//inGame.callAll("removeFromPlay", true);
					startButtonOnly = true;
					flashInfoText = true;
					titleCard.visible = true;
					textInfo.text = "\n\n\n\n      PRESS START";
					textInfo.visible = true;
					onTimerInfo(timerInfo);
					offsetOverlay.y = -115;
					titleCard.color = 0x119900;
					titleCard.play("jungle");
					titleCard.visible = true;
					timerSwitchState.start(8, 1, onTimerSwitchState)
					break;
				case ATTRACT_MODE:
					restartGame();
					spawnEnemies = true;
					startButtonOnly = true;
					flashInfoText = true;
					textInfo.text = "\n\n\n\n       DEMO MODE";
					textInfo.visible = true;
					backdrop.play("jungle");
					backdrop.visible = true;
					onTimerInfo(timerInfo);
					timerSwitchState.start(15, 1, onTimerSwitchState)
					break;
				case HIGH_SCORES:
					//inGame.callAll("removeFromPlay", true);
					startButtonOnly = true;
					offsetOverlay.y = -90;
					textInfo.text = highScoresList();
					textInfo.visible = true;
					timerSwitchState.start(10, 1, onTimerSwitchState)
					break;
				case PLAY_GAME:
					spawnEnemies = true;
					gameHasStarted = true;
					showPlayerScore = true;
					offsetOverlay.y = 0;
					backdrop.play("jungle");
					backdrop.visible = true;
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
					//inGame.callAll("removeFromPlay", true);
					gameHasStarted = true;
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
			if (Obj2 is PlayerJumper) checkForCollisions(Obj2, Obj1);
			//else if (Obj2 is EnemyShip && !(Obj1 is PlayerShip)) checkForCollisions(Obj2, Obj1);
			if (Obj1 is PlayerJumper && Obj2 is JungleBlock)
			{
				if (Obj1.alive) (Obj2 as JungleBlock).collideWith(Obj1 as PlayerJumper);
			}
		}
	}
}
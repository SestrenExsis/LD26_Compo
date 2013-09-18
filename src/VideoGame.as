package
{
	import entities.*;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	import screens.*;
	
	public class VideoGame extends FlxGroup
	{
		//[Embed(source="../assets/images/titleCards.png")] protected static var imgTitleCards:Class;
		
		public static const TITLE_SCREEN:uint = 0;
		public static const ATTRACT_MODE:uint = 1;
		public static const HIGH_SCORES:uint = 2;
		public static const PLAY_GAME:uint = 3;
		public static const PAUSED:uint = 4;
		public static const GAME_OVER:uint = 5;
		public static const NAME_ENTRY:uint = 6;
		public static const gameStateNames:Array = ["TITLE_SCREEN","ATTRACT_MODE","HIGH_SCORES","PLAY_GAME","PAUSED","GAME_OVER","NAME_ENTRY"];
		public static const nameChars:Array = [" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"];
		public static const ordinalStrings:Array = ["1ST","2ND","3RD","4TH","5TH"];
		public static var kUp:String = "W";
		public static var kDown:String = "S";
		public static var kLeft:String = "A";
		public static var kRight:String = "D";
		public static var kJump:String = "SPACE";
		public static var kStart:String = "SHIFT";
		
		public var titleCard:Entity;
		public var backdrop:Entity;
		public var inGame:FlxGroup;
		public var textLives:GameText;
		public var textScore:GameText;
		public var textInfo:GameText;
		public var timerSpawn:FlxTimer;
		public var timerInfo:FlxTimer;
		public var newHighScore:Boolean = false;
		public var shouldRestartGame:Boolean = false;
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var scale:FlxPoint;
		public var controls:uint = 0x00000000;
		public var lastControls:uint = 0x00000000;
		public var gravity:Number = 400;
		protected var _level:int = 0;
		
		public var highScores:Array;
		public var topPlayers:Array;
		public var nameArray:Array;
		public var selectedCharacter:int = 0;
		public var charPosition:int = 0;
		public var blinking:Boolean = false;
		
		public var spawnEnemies:Boolean = false;
		public var startButtonOnly:Boolean = true;
		public var flashInfoText:Boolean = true;
		public var paused:Boolean = false;
		public var gameHasStarted:Boolean = false;
		public var showPlayerScore:Boolean = false;
		public var gameStateTimer:FlxTimer;
		public var offsetOverlay:FlxPoint;
		public var timerSwitchState:FlxTimer;
		
		public var gamePixels:FlxSprite;
		private var _tvScreen:FlxRect;
		private var _television:Television;
		protected var _name:String = "";
		protected var _score:int;
		protected var _scoreRank:uint = 0;
		protected var _gameState:uint = 99;
		public var _uniqueKey:String;
		
		public function VideoGame(TV:Television)
		{
			super();
			_tvScreen = TV.screen;
			_television = TV;
			x = TV.x + _tvScreen.x;
			y = TV.y + _tvScreen.y;
			width = _tvScreen.width;
			height = _tvScreen.height;
			
			gamePixels = new FlxSprite(x, y);
			_uniqueKey = FlxG.random().toString();
			gamePixels.makeGraphic(111, 80, 0xff000000, true, _uniqueKey);
			//scale = new FlxPoint();
		}
		
		override public function update():void
		{	
			super.update();
			
			//x = _tvScreen.x;
			//y = _tvScreen.y;
			gamePixels.scale.x = _tvScreen.width / gamePixels.width;
			gamePixels.scale.y = _tvScreen.height / gamePixels.height;
			gamePixels.x = _television.x + _tvScreen.x + 0.5 * (gamePixels.width * (gamePixels.scale.x - 1));//(width - gamePixels.width) / 2;
			gamePixels.y = _television.y + _tvScreen.y + 0.5 * (gamePixels.height * (gamePixels.scale.y - 1));//(height - gamePixels.height) / 2;
			
			lastControls = controls;
			FlxG.overlap(inGame, inGame, checkForCollisions);
		}
		
		override public function draw():void
		{
			gamePixels.makeGraphic(gamePixels.width, gamePixels.height, 0xff000000, true, _uniqueKey);
			var basic:FlxBasic;
			var i:uint = 0;
			while(i < length)
			{
				basic = members[i++] as FlxBasic;
				if((basic != null) && basic.exists && basic.visible)
					basic.draw();
			}
		}
		
		public function acceptInput(InputBytes:int = -1):void
		{
			if (InputBytes >= 0)
			{
				controls = InputBytes;
				if (startButtonOnly) controls &= Entity.START;
			}
			else
			{
				controls = Entity.NONE;
				if (FlxG.keys[kUp] && !FlxG.keys[kDown]) controls |= Entity.UP;
				else if (!FlxG.keys[kUp] && FlxG.keys[kDown]) controls |= Entity.DOWN;
				if (FlxG.keys[kLeft] && !FlxG.keys[kRight]) controls |= Entity.LEFT;
				else if (!FlxG.keys[kLeft] && FlxG.keys[kRight]) controls |= Entity.RIGHT;
				if (FlxG.mouse.justPressed()) controls |= Entity.BUTTON_A;
				if (FlxG.keys[kJump]) controls |= Entity.BUTTON_B;
				if (FlxG.keys[kStart]) controls |= Entity.START;
				if (startButtonOnly) controls &= Entity.START;
			}
			if (gameState == NAME_ENTRY)
			{
				if ((controls & Entity.LEFT) > 0 && (lastControls & Entity.LEFT) == 0) charPosition -= 1;
				else if ((controls & Entity.RIGHT) > 0 && (lastControls & Entity.RIGHT) == 0) charPosition += 1;
				if (charPosition >= nameArray.length) charPosition = nameArray.length - 1;
				else if (charPosition < 0) charPosition = 0;
				selectedCharacter = nameArray[charPosition];
				
				if ((controls & Entity.UP) > 0 && (lastControls & Entity.UP) == 0) selectedCharacter += 1;
				else if ((controls & Entity.DOWN) > 0 && (lastControls & Entity.DOWN) == 0) selectedCharacter -= 1;
				if (selectedCharacter == nameChars.length || ((controls & Entity.BUTTON_B) > 0 && (lastControls & Entity.BUTTON_B) == 0)) 
					selectedCharacter = 0;
				else if (selectedCharacter == -1) selectedCharacter = nameChars.length - 1;				
				nameArray[charPosition] = selectedCharacter;
			}
			if ((controls & Entity.START) > 0 && (lastControls & Entity.START) == 0) startButton();
		}
		
		protected function startButton():void
		{
			
		}
		
		protected function restartGame():void
		{
			
		}
		
		protected function onTimerInfo(Timer:FlxTimer):void
		{
			timerInfo.stop();
			if (textInfo.visible) timerInfo.start(0.75, 1, onTimerInfo);
			else timerInfo.start(0.5, 1, onTimerInfo);
			if (flashInfoText) textInfo.visible = !textInfo.visible;
		}
		
		protected function onTimerNameEntry(Timer:FlxTimer):void
		{
			timerInfo.stop();
			timerInfo.start(0.2, 1, onTimerNameEntry);
			var _name:String = "";
			for (var i:uint = 0; i < nameArray.length; i++)
			{
				if (i == charPosition && blinking) _name += "_";
				else _name += nameChars[nameArray[i]];
			}
			
			i = nameArray.length - 1;
			var _spaceFound:Boolean = true;
			while (_spaceFound)
			{
				if (_name.charAt(i) == " ")
				{
					_spaceFound = true;
					_name = _name.substring(0, i--);
				}
				else _spaceFound = false;
			}
			textInfo.text = highScoresList(_name);
			blinking = !blinking;
		}
		
		public static function formatScore(Num:Number, Digits:uint = 10):String
		{
			var output:String = "";
			for (var i:Number = 0; i < Digits; i++)
			{
				if (Num < Math.pow(10,i)) output += "0";
			}
			if (Num > 0) output += "" + Num;
			return output;
		}
		
		public function get score():int
		{
			return _score;
		}
		
		public function highScoresList(CurrentNameState:String = null):String
		{
			var _string:String = "\n\n";
			var _currentName:String = "";
			var _ordinal:String = "";
			for (var i:uint = 0; i < 5; i++)
			{
				_currentName = topPlayers[i];
				if (CurrentNameState) if (i == _scoreRank) _currentName = CurrentNameState;
				_string += ordinalStrings[i] + "\t" + _currentName + "\t" + formatScore(highScores[i], 3) + "\n";
			}			
			return _string;
		}
		
		public function set score(Score:int):void
		{
			_score = Score;
		}
		
		public function get level():int
		{
			return _level;
		}
		
		public function set level(Value:int):void
		{
			_level = Value;
		}
		
		public function onTimerSwitchState(Timer:FlxTimer):void
		{
			
		}
		
		public function get gameState():int
		{
			return _gameState;
		}
		
		public function set gameState(GameState:int):void
		{
			var _wasPaused:Boolean = paused;
			if (_gameState == GameState) return;
			else _gameState = GameState;
		}
		
		public function get name():String
		{
			var _tempName:String = "";
			for (var i:uint = 0; i < nameArray.length; i++)
			{
				_tempName += nameChars[nameArray[i]];
			}
			var _spaceFound:Boolean = true;
			while (_spaceFound)
			{
				if (_tempName.charAt(i) == " ")
				{
					_spaceFound = true;
					_tempName = _tempName.substring(0, i--);
				}
				else _spaceFound = false;
			}
			return _tempName;
		}
		
		public function get scoreRank():uint
		{
			var _scoreRank:uint = highScores.length;
			var _scoreValue:uint = score;
			for (var i:int = highScores.length - 1; i >= 0; i--)
			{
				if (_scoreValue > highScores[i]) _scoreRank -= 1;
			}
			return _scoreRank;
		}
		
		public function insertNewScore():void
		{
			//name = "MYNAME";
			var _tempName:String = "";
			nameArray = [1, 0, 0, 0, 0, 0, 0];
			_scoreRank = 5;
			charPosition = 0;
			
			highScores.push(score);
			topPlayers.push(name);
			for (var i:int = highScores.length - 2; i >= 0; i--)
			{
				if (highScores[i + 1] > highScores[i])
				{
					score = highScores[i];
					highScores[i] = highScores[i + 1];
					highScores[i + 1] = score;
					
					_tempName = topPlayers[i];
					topPlayers[i] = topPlayers[i + 1];
					topPlayers[i + 1] = _tempName;
					
					_scoreRank -= 1;
				}
			}
			score = highScores[_scoreRank];
			highScores.pop();
			topPlayers.pop();
		}
		
		public function checkForCollisions(Obj1:FlxObject, Obj2:FlxObject):void
		{
			
		}
		
	}
}
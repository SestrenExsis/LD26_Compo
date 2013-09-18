package
{
	import org.flixel.*;
	
	import screens.*;
	
	public class ScreenState extends FlxState
	{
		
		public static var overlay:FlxSprite;
		public static var infoBackdrop:FlxSprite;
		public static var info:FlxText;
		public static var info2:FlxText;
		public static var infoTimer:FlxTimer;
		public static var score:FlxText;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			FlxG.flash(0xff000000, 0.5);
		}
		
		override public function update():void
		{	
			super.update();
		}
		
		public function onButtonMenu():void
		{
			fadeToMenu();
		}
		
		public function fadeToMenu(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToMenu);
		}
		
		public function goToMenu():void
		{
			FlxG.switchState(new MenuState);
		}
		
		public function onButtonGame():void
		{
			fadeToGame();
		}
		
		public function fadeToGame(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToGame);
		}
		
		public function goToGame():void
		{
			FlxG.switchState(new GameState);
		}
		
		public function onButtonStory():void
		{
			fadeToStory();
		}
		
		public function fadeToStory(Timer:FlxTimer = null):void
		{
			FlxG.fade(0xff000000, 0.5, goToStory);
		}
		
		public function goToStory():void
		{
			FlxG.switchState(new StoryState);
		}
		
		public function formatScore(Num:Number, Digits:uint = 10):String
		{
			var output:String = "";
			for (var i:Number = 0; i < Digits; i++)
			{
				if (Num < Math.pow(10,i)) output += "0";
			}
			if (Num > 0) output += "" + Num;
			return output;
		}
	}
}
package screens
{
	import org.flixel.*;
	
	public class StoryState extends ScreenState
	{
		[Embed(source="../assets/images/story.png")] protected static var imgStory:Class;
		
		public static var playEnding:Boolean = false;
		
		private var storyIndex:uint = 0;
		
		public function StoryState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			overlay = new FlxSprite(0, 0);
			overlay.loadGraphic(imgStory, true, false, 320, 240);
			overlay.addAnimation("none",[0]);
			overlay.addAnimation("intro",[1]);
			overlay.addAnimation("ending",[2,2,3,3], 3);
			//overlay.addAnimation("title",[4,4,5,5], 3);
			
			//overlay.play("final");
			
			infoTimer = new FlxTimer();
			infoTimer.start(0.01, 1, onTimerNextSlide);
			
			info = new FlxText(16, FlxG.height - 32, FlxG.width - 16, "");
			info.alignment = "left";
			
			info2 = new FlxText(16, FlxG.height - 16, FlxG.width - 16, "");
			info2.alignment = "left";
			
			add(overlay);
			add(info);
			add(info2);
		}
		
		override public function update():void
		{	
			super.update();
			
			if (storyIndex >= 2 && FlxG.mouse.justPressed()) 
			{
				FlxG.log("skip");
				if (playEnding) onButtonMenu();
				else onButtonGame();
			}
		}
		
		public function onTimerNextSlide(Timer:FlxTimer):void
		{
			FlxG.log("storyIndex = " + storyIndex);
			if (playEnding)
			{
				if (storyIndex == 0)
				{
					overlay.play("ending");
					info.text = "After being prompted to enter your name";
					info2.text = "for the high score, ...";
					infoTimer.start(7, 1, onTimerNextSlide);
				}
				else if (storyIndex == 1)
				{
					info.text = "... you use the failsafe phrase 'HELPME' to trigger";
					info2.text = "the emergency alert system.";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 2)
				{
					info.text = "Right at this very moment, robo-calls are being sent out";
					info2.text = "to fellow lab technicians, ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 3)
				{
					info.text = "... and government officials close to the project. All";
					info2.text = "of them will be alerted to your lab immediately, ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 4)
				{
					info.text = "... ready to bring you back to normal.";
					info2.text = "";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 5)
				{
					info.text = "But, just as you start to feel that soon everything";
					info2.text = "will be alright, a creeping suspicion overtakes you ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 6)
				{
					info.text = "\"What if the emergency system isn't working, either?\"";
					info2.text = "";
					infoTimer.start(8, 1, onTimerNextSlide);
				}
				else if (storyIndex == 7)
				{
					info.text = "";
					info2.text = "";
					infoTimer.start(8, 1, onTimerNextSlide);
				}
				else goToMenu();
			}
			else
			{
				FlxG.log("intro");
				if (storyIndex == 0)
				{
					overlay.play("intro");
					info.text = "\"Success ...";
					info2.text = "... the experiment worked!\"";
					infoTimer.start(5, 1, onTimerNextSlide);
				}
				else if (storyIndex == 1)
				{
					info.text = "\"Wait a minute ...";
					info2.text = "... something is very wrong.\"";
					infoTimer.start(5, 1, onTimerNextSlide);
				}
				else if (storyIndex == 2)
				{
					info.text = "Instead of shrinking JUST the cache of baseballs";
					info2.text = "set aside for the experiment ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 3)
				{
					info.text = "... it appears YOU have also been shrunk down in size.";
					info2.text = "";
					infoTimer.start(5, 1, onTimerNextSlide);
				}
				else if (storyIndex == 4)
				{
					info.text = "There's no time to waste. You need to activate the";
					info2.text = "emergency contact system you had hidden away as an ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 5)
				{
					info.text = "... easter egg in one of your modded game cartridges.";
					info2.text = "All you have to do is get a high score on 'Invasion' and ...";
					infoTimer.start(6, 1, onTimerNextSlide);
				}
				else if (storyIndex == 6)
				{
					info.text = "... enter \"HELPME\" as your name for the High Scores.";
					info2.text = "But, at your current size, handling the game controller ...";
					infoTimer.start(8, 1, onTimerNextSlide);
				}
				else if (storyIndex == 7)
				{
					info.text = "... is going to be tricky. Luckily, you have a near endless";
					info2.text = "supply of pre-shrunk baseballs as ammo.";
					infoTimer.start(8, 1, onTimerNextSlide);
				}
				else goToGame();
			}
			storyIndex++;
		}
	}
}
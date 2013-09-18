package screens
{
	import org.flixel.*;
	
	public class MenuState extends ScreenState
	{
		[Embed(source="../assets/images/story.png")] protected static var imgStory:Class;
		
		public function MenuState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			overlay = new FlxSprite(0, 0);
			overlay.loadGraphic(imgStory, true, false, 320, 240);
			overlay.addAnimation("none",[0]);
			overlay.addAnimation("title",[4,4,5,5], 3);
			add(overlay);
			overlay.play("title");
		}
		
		override public function update():void
		{	
			super.update();
			
			if (FlxG.mouse.justPressed()) 
			{
				StoryState.playEnding = false;
				onButtonStory();
			}
		}
	}
}
package
{
	import org.flixel.FlxGame;
	import org.flixel.FlxG;
	import screens.MenuState;
	import screens.GameState;
	[SWF(width="480", height="480", backgroundColor="#222222")]
	
	public class LD26_Compo extends FlxGame
	{
		public function LD26_Compo()
		{
			super(480, 480, MenuState, 1.0, 60, 60, true);
			forceDebugger = true;
		}
	}
}
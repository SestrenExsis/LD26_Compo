package
{
	import org.flixel.FlxGame;
	import screens.MenuState
	[SWF(width="640", height="480", backgroundColor="#222222")]
	
	public class LD26_Compo extends FlxGame
	{
		public function LD26_Compo()
		{
			super(320, 240, MenuState, 2.0, 60, 60, true);
			//forceDebugger = true;
		}
	}
}
package entities
{
	import org.flixel.*;
	import screens.GameState;
	
	public class TVScreen extends Entity
	{
		//[Embed(source="../assets/images/television.png")] protected static var imgScreen:Class;
		public static var gameStarted:Boolean = false;
				
		public function TVScreen(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			//loadGraphic(imgScreen, false, false, 111, 80);
			makeGraphic(111, 80, 0xff000000);
			
			width = 111;
			height = 80;
		}
		
		override public function update():void
		{
			super.update();
		}
		
		override public function translateInput():void
		{
			if ((controls & Entity.START) > 0) 
			{
				if (gameStarted) GameState.restartGame = true;
				gameStarted = true;
			}
		}
	}
}
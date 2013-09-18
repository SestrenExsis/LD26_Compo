package entities
{
	import org.flixel.*;
	
	public class Television extends Entity
	{
		[Embed(source="../assets/images/console_tv.png")] protected static var imgTelevision:Class;
		public var screen:FlxRect;
				
		public function Television(X:Number = 0, Y:Number = 0, Width:Number = 580, Height:Number = 375)
		{
			super(X, Y);
			
			loadGraphic(imgTelevision, false, false, 580, 375);
			
			width = Width;
			height = Height;
			screen = new FlxRect(68, 64, 333, 240);
		}
		
		override public function update():void
		{
			super.update();
			
			//screen.x = 0.5 * (width - screen.width)
			//screen.y = 0.5 * (height - screen.height)
			//screen.x = x + 45;
			//screen.y = y + 84;
		}
		
		override public function translateInput():void
		{
			
		}
	}
}
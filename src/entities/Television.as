package entities
{
	import org.flixel.*;
	
	public class Television extends Entity
	{
		[Embed(source="../assets/images/television.png")] protected static var imgTelevision:Class;
				
		public function Television(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			loadGraphic(imgTelevision, false, false, 143, 125);
			
			width = 143;
			height = 125;
		}
		
		override public function update():void
		{
			super.update();
		}
		
		override public function translateInput():void
		{
			
		}
	}
}
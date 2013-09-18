package entities
{
	import org.flixel.*;
	
	public class Laser extends Entity
	{
		//[Embed(source="../assets/images/player.png")] protected static var imgPlayer:Class;
				
		public static var selected:Laser;
		public static var group:FlxGroup;
		
		public var belongsToPlayer:Boolean = true;
		
		public function Laser(X:Number = -1000, Y:Number = -1000)
		{
			super(X, Y);
			
			//loadGraphic(imgPlayer, true, true, 16, 24);
			makeGraphic(4, 4, 0xffffff00);
			
			width = 4;
			height = 4;
			kill();
			//drag.x = drag.y = 10;
		}
		
		override public function update():void
		{
			super.update();
			
			if (input)
			{
				if (x + width < input.x || x > input.x + input.width || y + height < input.y || y > input.y + input.height) 
				{
					kill();
				}
			}
		}
		
		override public function kill():void
		{
			super.kill();
			if (belongsToPlayer) PlayerShip.shotsInPlay = Math.max(0,PlayerShip.shotsInPlay - 1);
		}
		
		public static function shoot(X:Number, Y:Number, Speed:Number, BelongsToPlayer:Boolean = false):void
		{
			selected = Laser(group.getFirstAvailable(Laser));
			if (selected)
			{
				selected.reset(X - selected.width / 2, Y - selected.height / 2);
				selected.belongsToPlayer = BelongsToPlayer;
				if (BelongsToPlayer) PlayerShip.shotsInPlay += 1;
				selected.velocity.x = 0;
				if (BelongsToPlayer) 
				{
					selected.velocity.y = -Speed;
					selected.color = 0x00ffff;
				}
				else 
				{
					selected.velocity.y = Speed / 2;
					selected.color = 0xff0000;
				}
			}
		}
	}
}
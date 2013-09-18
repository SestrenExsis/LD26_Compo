package entities
{
	import org.flixel.*;
	
	public class Laser extends Entity
	{
		//[Embed(source="../assets/images/player.png")] protected static var imgPlayer:Class;
				
		public var owner:Entity;
		public var belongsToPlayer:Boolean = true;
		
		public function Laser(Game:VideoGame)
		{
			super(-1000, -1000);
			
			game = Game;
			//loadGraphic(imgPlayer, true, true, 16, 24);
			makeGraphic(4, 4, 0xffffff00);
			
			width = 4;
			height = 4;
			kill();
			//drag.x = drag.y = 10;
		}
		
		override public function update():void
		{
			/*if (game) if (game.paused)
			{
				x = last.x;
				y = last.y;
			}*/
			super.update();
			
			if (game)
			{
				if (x + width < 0 || x > game.gamePixels.width || y + height < 0 || y > game.gamePixels.height) 
				{
					kill();
				}
			}
		}
		
		override public function draw():void
		{	
			drawOntoSprite(game.gamePixels);
		}
		
		override public function kill():void
		{
			super.kill();
			if (owner is PlayerShip) (owner as PlayerShip).shotsInPlay = Math.max(0,(owner as PlayerShip).shotsInPlay - 1);
		}
		
		public function spawn(Owner:Entity):void
		{
			owner = Owner;
			var _speed:Number = owner.shotSpeed;
			var _heightOffset:Number = owner.height / 2;
			if (Owner is PlayerShip) _heightOffset *= -1;
			reset(owner.x + owner.width / 2 - width / 2, owner.y + owner.height / 2 - height / 2 + _heightOffset);
			velocity.x = 0;
			velocity.y = owner.shotSpeed;
			if (owner is PlayerShip) 
			{
				velocity.y *= -1;
				color = 0x00ffff;
				belongsToPlayer = true;
			}
			else 
			{
				color = 0xff0000;
				belongsToPlayer = false;
			}
		}
	}
}
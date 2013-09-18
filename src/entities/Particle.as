package entities
{
	import org.flixel.*;
	
	public class Particle extends Entity
	{
		public function Particle(Game:VideoGame, SpawnInTransit:Boolean = false)
		{
			super(-1000, -1000);
			
			game = Game;
			//loadGraphic(imgPlayer, true, true, 16, 24);
			makeGraphic(1, 1);
			
			width = 1;
			height = 1;
			
			if (SpawnInTransit) 
			{
				var _seed:Number = FlxG.random();
				if (_seed < 0.4) spawnStar(true);
				else kill();
			}
			else kill();
			//drag.x = drag.y = 10;
		}
		
		override public function update():void
		{
			super.update();
			
			if (game)
			{
				if (x + width < 0 || x > game.width || y + height < 0 || y > game.height) 
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
		}
		
		public function spawnStar(RandomY:Boolean = false):void
		{
			var _layer:Number = FlxG.random();
			if (_layer < 0.30) _layer = 0;
			else if (_layer < 0.57) _layer = 1;
			else if (_layer < 0.80) _layer = 2;
			else _layer = 3;
			
			ID = _layer;
			
			var _seed:Number = Math.floor(FlxG.random() * game.width);
			var _seed2:Number;
			if (RandomY) _seed2 = Math.floor(FlxG.random() * game.height);
			else _seed2 = 0;
			
			var _seed3:Number = FlxG.random();
			if (_seed3 < 0.025) makeGraphic(2, 2);
			else if (frameWidth == 2) makeGraphic(1, 1);
			
			reset(_seed - width / 2, _seed2 - height / 2);
			velocity.x = 0;
			velocity.y = 20 + _layer * 30;
			if (_layer == 0) color = 0x445555;
			else if (_layer == 1) color = 0x556666;
			else if (_layer == 2) color = 0x667777;
			else color = 0x778888;
		}
	}
}
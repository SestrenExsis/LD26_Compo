package entities
{
	import org.flixel.*;
	
	public class GamepadButton extends Entity
	{
		//[Embed(source="../assets/images/player.png")] protected static var imgPlayer:Class;
		public var pressFrames:uint = 0;
		
		public function GamepadButton(Controller:Gamepad, Index:uint)
		{
			var _x:Number = Controller.x + FlxRect(Gamepad.buttonRects[Index]).x;
			var _y:Number = Controller.y + FlxRect(Gamepad.buttonRects[Index]).y;
			var _w:Number = FlxRect(Gamepad.buttonRects[Index]).width;
			var _h:Number = FlxRect(Gamepad.buttonRects[Index]).height;
			
			super(_x, _y);
			
			//loadGraphic(imgPlayer, true, true, 16, 24);
			makeGraphic(_w, _h, 0xff00ffff);
			
			width = _w;
			height = _h;
			ID = Index;
			blend = "screen";
		}
		
		override public function update():void
		{
			super.update();
			if (pressFrames > 0)
			{
				alpha = 0.25;
				color = 0x00ffff;
			}
			else
			{
				alpha = 0;
			}
			pressFrames = Math.max(0, pressFrames - 1);
		}
		
		override public function defaultInput():uint
		{
			var _controls:uint = 0x00000000;
			if (pressFrames > 0) _controls |= Entity.INPUTS[ID];
			return _controls;
		}
	}
}
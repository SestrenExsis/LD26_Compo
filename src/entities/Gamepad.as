package entities
{
	import org.flixel.*;
	
	public class Gamepad extends Entity
	{
		//keyboard and mouse
		[Embed(source="../assets/images/gamepad.png")] protected static var imgGamepad:Class;
		
		public static var bUp:FlxRect = new FlxRect(62, 22, 40, 38);
		public static var bDown:FlxRect = new FlxRect(62, 100, 40, 44);
		public static var bLeft:FlxRect = new FlxRect(24, 60, 38, 46);
		public static var bRight:FlxRect = new FlxRect(102, 60, 38, 46);
		public static var bSelect:FlxRect = new FlxRect(164, 99, 53, 17);
		public static var bStart:FlxRect = new FlxRect(223, 99, 53, 17);
		public static var bAttack:FlxRect = new FlxRect(305, 64, 57, 60);
		public static var bSpecial:FlxRect = new FlxRect(389, 64, 57, 60);
		
		public static var buttonRects:Array = [bUp, bDown, bLeft, bRight, bSelect, bStart, bAttack, bSpecial];
		public static var button:FlxRect;
				
		public function Gamepad()
		{
			var _x:Number = 0.5 * (FlxG.width - 477);
			var _y:Number = FlxG.height - 171 + 10;
			
			super(_x, _y);
			
			loadGraphic(imgGamepad, false, false, 477, 171);
			
			width = 477;
			height = 171;
		}
		
		override public function update():void
		{
			super.update();
			
		}
		
		override public function defaultInput():uint
		{
			//FlxG.log(_input);
			return 0x00000000;
		}
		
		override public function translateInput():void
		{
			//if (controls != lastControls) FlxG.log("Gamepad: " + controls);
		}
	}
}
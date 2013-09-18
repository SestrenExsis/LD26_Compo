package entities
{
	import org.flixel.*;
	
	public class Gamepad extends Entity
	{
		[Embed(source="../assets/images/gamepad.png")] protected static var imgGamepad:Class;
		
		public static var bUp:FlxRect = new FlxRect(48, 10, 14, 14);
		public static var bDown:FlxRect = new FlxRect(42, 29, 14, 14);
		public static var bLeft:FlxRect = new FlxRect(25, 20, 14, 14);
		public static var bRight:FlxRect = new FlxRect(66, 20, 14, 14);
		public static var bSelect:FlxRect = new FlxRect(101, 21, 28, 14);
		public static var bStart:FlxRect = new FlxRect(139, 21, 28, 14);
		public static var bAttack:FlxRect = new FlxRect(182, 17, 29, 21);
		public static var bSpecial:FlxRect = new FlxRect(221, 15, 29, 21);
		
		public static var buttonRects:Array = [bUp, bDown, bLeft, bRight, bSelect, bStart, bAttack, bSpecial];
		public static var button:FlxRect;
				
		public function Gamepad(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			loadGraphic(imgGamepad, false, false, 287, 86);
			
			width = 287;
			height = 86;
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
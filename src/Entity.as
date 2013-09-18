package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{		
		public static const NONE:uint = 0x00000000;
		public static const UP:uint = 0x10000000;
		public static const DOWN:uint = 0x01000000;
		public static const LEFT:uint = 0x00100000;
		public static const RIGHT:uint = 0x00010000;
		public static const SELECT:uint = 0x00001000;
		public static const START:uint = 0x00000100;
		public static const BUTTON_A:uint = 0x00000010;
		public static const BUTTON_B:uint = 0x00000001;
		public static const INPUTS:Array = [UP, DOWN, LEFT, RIGHT, SELECT, START, BUTTON_A, BUTTON_B];
		
		public static const GRAVITY:uint = 400;
		
		public var input:Entity;
		public var inputs:Array;
		public var acceptInput:Boolean = false;
		public var controls:uint = 0x00000000;
		public var lastControls:uint = 0x00000000;
		
		public var z:Number = 0;
		public var lastZ:Number = 0;
		public var zVelocity:Number = 0;
		
		[Embed(source="assets/sounds/ActivateShields01.mp3")] public static var sfxActivateShields01:Class;
		[Embed(source="assets/sounds/ActivateShields02.mp3")] public static var sfxActivateShields02:Class;
		[Embed(source="assets/sounds/ActivateShields03.mp3")] public static var sfxActivateShields03:Class;
		[Embed(source="assets/sounds/ActivateShields04.mp3")] public static var sfxActivateShields04:Class;
		[Embed(source="assets/sounds/ActivateShields04.mp3")] public static var sfxActivateShields05:Class;
		public static var sfxActivateShields:Array = [sfxActivateShields01, sfxActivateShields02, sfxActivateShields03, sfxActivateShields04, sfxActivateShields05];
		
		[Embed(source="assets/sounds/Explosion01.mp3")] public static var sfxExplosion01:Class;
		[Embed(source="assets/sounds/Explosion02.mp3")] public static var sfxExplosion02:Class;
		[Embed(source="assets/sounds/Explosion03.mp3")] public static var sfxExplosion03:Class;
		[Embed(source="assets/sounds/Explosion04.mp3")] public static var sfxExplosion04:Class;
		public static var sfxExplosion:Array = [sfxExplosion01, sfxExplosion02, sfxExplosion03, sfxExplosion04];
		
		[Embed(source="assets/sounds/HighScore01.mp3")] public static var sfxHighScore01:Class;
		public static var sfxHighScore:Array = [sfxHighScore01];
		
		[Embed(source="assets/sounds/Laser01.mp3")] public static var sfxLaser01:Class;
		[Embed(source="assets/sounds/Laser02.mp3")] public static var sfxLaser02:Class;
		[Embed(source="assets/sounds/Laser03.mp3")] public static var sfxLaser03:Class;
		[Embed(source="assets/sounds/Laser04.mp3")] public static var sfxLaser04:Class;
		[Embed(source="assets/sounds/Laser05.mp3")] public static var sfxLaser05:Class;
		[Embed(source="assets/sounds/Laser06.mp3")] public static var sfxLaser06:Class;
		[Embed(source="assets/sounds/Laser07.mp3")] public static var sfxLaser07:Class;
		[Embed(source="assets/sounds/Laser08.mp3")] public static var sfxLaser08:Class;
		public static var sfxLaser:Array = [sfxLaser01, sfxLaser02, sfxLaser03, sfxLaser04, sfxLaser05, sfxLaser06, sfxLaser07, sfxLaser08];
		
		//Pickup_Coin
		//Powerup
		
		[Embed(source="assets/sounds/ShieldsReady01.mp3")] public static var sfxShieldsReady01:Class;
		[Embed(source="assets/sounds/ShieldsReady02.mp3")] public static var sfxShieldsReady02:Class;
		[Embed(source="assets/sounds/ShieldsReady03.mp3")] public static var sfxShieldsReady03:Class;
		[Embed(source="assets/sounds/ShieldsReady04.mp3")] public static var sfxShieldsReady04:Class;
		[Embed(source="assets/sounds/ShieldsReady05.mp3")] public static var sfxShieldsReady05:Class;
		[Embed(source="assets/sounds/ShieldsReady06.mp3")] public static var sfxShieldsReady06:Class;
		public static var sfxShieldsReady:Array = [sfxShieldsReady01, sfxShieldsReady02, sfxShieldsReady03, sfxShieldsReady04, sfxShieldsReady05, sfxShieldsReady06];
		
		public function Entity(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			
			inputs = new Array(0);
		}
		
		override public function update():void
		{
			super.update();
			
			lastControls = controls;
			controls = 0x00000000;
			if (inputs.length > 0 && acceptInput)
			{
				for each (input in inputs)
				{
					controls |= input.controls;
				}
			}
			else controls = defaultInput();
			
			translateInput();
		}
		
		public static function playRandomSound(Sounds:Array, VolumeMultiplier:Number = 1.0):void
		{
			var _seed:Number = Math.floor(Sounds.length * Math.random());
			FlxG.play(Sounds[_seed], VolumeMultiplier, false, false);
		}
		
		public function defaultInput():uint
		{
			return 0x00000000;
		}
		
		public function translateInput():void
		{
			
		}
		
		public function onHitGround():void
		{
			z = 0;
			zVelocity = 0;
		}
	}
}
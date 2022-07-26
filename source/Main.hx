package;

import flixel.graphics.FlxGraphic;
import openfl.display.Bitmap;
import lime.app.Application;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets as OpenFlAssets;

class Main extends Sprite
{
	public static var bitmapFPS:Bitmap;
	public static var instance:Main;

	var fpsCounter:FPS;

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if FEATURE_MODCORE
		// Gotta run this before any assets get loaded.
		ModCore.reload();
		#end

		#if FEATURE_DISCORD
		Discord.DiscordClient.initialize();
		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		addChild(new FlxGame(0, 0, TitleState, 1, 60, 60, true, false));

		fpsCounter = new FPS(10, 10, 0xFFFFFF);
		bitmapFPS = ImageOutline.renderImage(fpsCounter, 1, 0x000000, true);
		addChild(fpsCounter);

		// Finish up loading debug tools.
		Debug.onGameStart();
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		Lib.current.stage.frameRate = cap;
	}

	public static function getFPSCap():Float
	{
		return Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	// lov u tails
	// https://github.com/nebulazorua/tails-gets-trolled-v3/blob/master/source/Main.hx
	public static function adjustFPS(num:Float):Float
	{
		return num * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS());
	}
}

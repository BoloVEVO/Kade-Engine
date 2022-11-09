import openfl.system.System;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display3D.Context3D;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end
#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class KadeEngineFPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	public var memoryMegas:Float = 0;

	public var memoryTotal:Float = 0;

	public var memoryUsage:String;

	public var gpuMemory:Float = 0;

	public var bitmap:Bitmap;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	static var engineName = "Kade Engine ";

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(openfl.utils.Assets.getFont("assets/fonts/vcr.ttf").fontName, 14, color);
		text = "FPS: ";
		width += 800;

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	public static var currentColor = 0;

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		if (MusicBeatState.initSave)
			if (FlxG.save.data.fpsRain)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				currentColor = Math.round(FlxMath.lerp(0, array.length, skippedFrames / (FlxG.save.data.fpsCap / 3)));
				(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames++;
				if (skippedFrames > (FlxG.save.data.fpsCap / 3))
					skippedFrames = 0;
			}

		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));

			/* This shit gets the gpu usage of every program of ur pc and not from the game. The gpu usage will be very innacurate.*/
			// gpuMemory = Math.abs(FlxMath.roundDecimal(FlxG.stage.context3D.totalGPUMemory / 1000000, 1));
			// var gpuInfo:String = FlxG.stage.context3D.driverInfo.substr(FlxG.stage.context3D.driverInfo.indexOf('Renderer=') + 9);

			if (memoryMegas > memoryTotal)
				memoryTotal = memoryMegas;

			/*if (FlxG.save.data.gpuRender)
					memoryUsage = (FlxG.save.data.memoryDisplay?"Memory Usage: " + memoryMegas + " MB / " + memoryTotal + " MB" + "\nGPU Usage: " + gpuMemory
						+ " MB" #if debug
						+ gpuInfo #end : "");
				else */
			memoryUsage = (FlxG.save.data.memoryDisplay ? "Memory Usage: " + memoryMegas + " MB / " + memoryTotal + " MB" : "");

			text = (FlxG.save.data.fps ? "FPS: "
				+ '$currentFPS\n'
				+ '$memoryUsage\n'
				+ "FNF v"
				+ MainMenuState.gameVer
				+ (Main.watermarks?'\n$engineName ' + "v" + MainMenuState.kadeEngineVer #if debug + "\nDEBUG MODE" #end : "") : memoryUsage
				+ '\nFNF v'
				+ MainMenuState.gameVer
				+ (Main.watermarks?'\n$engineName ' + "v" + MainMenuState.kadeEngineVer #if debug + "\nDEBUG MODE" #end : ""));

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();

			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end
		}

		/*if (FlxG.save.data.fpsBorder)
			{
				visible = true;
				Main.instance.removeChild(bitmap);

				bitmap = ImageOutline.renderImage(this, 2, 0x000000, 1);

				Main.instance.addChild(bitmap);
				visible = false;
			}
			else
			{
				visible = true;
				if (Main.instance.contains(bitmap))
					Main.instance.removeChild(bitmap);
		}*/

		cacheCount = currentCount;
	}

	public static function updateEngineName()
	{
		if (FlxG.random.bool(5))
		{
			switch (FlxG.random.int(0, 14))
			{
				case 0:
					engineName = "Dake Engine ";
				case 1:
					engineName = "Rudy Engine ";
				case 2:
					engineName = "Faid Engine ";
				case 3:
					engineName = "Jigsaw Engine ";
				case 4:
					engineName = "Sora Engine ";
				case 5:
					engineName = "Kade Engine ";
				case 6:
					engineName = "Awoo Engine";
				case 7:
					engineName = "Gara Engine";
				case 8:
					engineName = "Amber Engine";
				case 9:
					engineName = "Jack Engine";
				case 10:
					engineName = "Codex Engine";
				case 11:
					engineName = "Foxy Engine";
				case 12:
					engineName = "Kev Engine";
				case 13:
					engineName = "Gabi Engine";
				case 14:
					engineName = "Dreamy Engine";
			}
		}
	}
}

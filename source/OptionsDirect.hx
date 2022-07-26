import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class OptionsDirect extends MusicBeatState
{
	var menuBG:FlxSprite;

	var colorArray:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	override function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(FlxG.width * 1.1), FlxG.height);
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);
		openSubState(new OptionsMenu());
		tweenColorShit();
	}

	function tweenColorShit()
	{
		var beforeInt = FlxG.random.int(0, 6);
		var randomInt = FlxG.random.int(0, 6);

		FlxTween.color(menuBG, 4, menuBG.color, colorArray[beforeInt], {
			onComplete: function(twn)
			{
				if (beforeInt != randomInt)
					beforeInt = randomInt;

				tweenColorShit();
			}
		});
	}
}

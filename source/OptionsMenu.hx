package;

import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import PlayState;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;

class OptionCata extends FlxSprite
{
	public var title:String;

	public static var instance:OptionCata;

	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<FlxText>;

	public var titleObject:FlxText;

	public var middle:Bool = false;

	public var text:FlxText;

	public function new(x:Float, y:Float, _title:String, _options:Array<Option>, middleType:Bool = false)
	{
		super(x, y);
		title = _title;
		middle = middleType;
		if (!middleType)
			makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;

		options = _options;

		optionObjects = new FlxTypedGroup();

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
		titleObject.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.borderSize = 3;

		if (middleType)
		{
			titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		}
		else
			titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);

		titleObject.scrollFactor.set();

		scrollFactor.set();

		for (i in 0...options.length)
		{
			var opt = options[i];
			text = new FlxText((middleType ? 1180 / 2 : 72), 120 + 54 + (46 * i), 0, opt.getValue());
			if (middleType)
			{
				text.screenCenter(X);
			}
			text.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();

			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor)
	{
		makeGraphic(295, 64, color);
	}
}

class OptionsMenu extends FlxSubState
{
	public static var instance:OptionsMenu;

	public var background:FlxSprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public static var visibleRange = [164, 640];

	var changedOption = false;

	public function new(pauseMenu:Bool = false)
	{
		super();

		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;

	override function create()
	{
		options = [
			new OptionCata(50, 40, "Gameplay", [
				new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
				new OffsetThing("Change the note visual offset (how many milliseconds a note looks like it is offset in a chart)"),
				new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
				new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
				new DownscrollOption("Toggle making the notes scroll down rather than up."),
				new BotPlay("A bot plays for you!"),
				new FPSCapOption("Change your FPS Cap."),

				new ResetButtonOption("Toggle pressing R to gameover. (Use it with caution!)"),
				new InstantRespawn("Toggle if you instantly respawn after dying."),
				new CamZoomOption("Toggle the camera zoom in-game."),
				// new OffsetMenu("Get a note offset based off of your inputs!"),
				new DFJKOption(),
				new Judgement("Create a custom judgement preset"),
				new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
			]),
			new OptionCata(345, 40, "Appearance", [
				new NoteskinOption("Change your current noteskin"),
				new RotateSpritesOption("Rotate the sprites to do color quantization (turn off for bar skins)"),
				new EditorRes("Not showing the editor grid will greatly increase editor performance"),
				new ScoreSmoothing("Toggle smoother poping score for Score Text (High CPU usage)."),
				new MiddleScrollOption("Put your lane in the center or on the right."),
				new HealthBarOption("Toggles health bar visibility"),
				new JudgementCounter("Show your judgements that you've gotten in the song"),
				new LaneUnderlayOption("How transparent your lane is, higher = more visible."),
				new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
				new AccuracyOption("Display accuracy information on the info bar."),
				new RoundAccuracy("Round your accuracy to the nearest whole number for the score text (cosmetic only)."),
				new SongPositionOption("Show the song's current position as a scrolling bar."),
				new Colour("The color behind icons now fit with their theme. (e.g. Pico = green)"),
				new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
				new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
				new BorderFps("Draw a border around the FPS Text (Consumes a lot of CPU Resources)"),
				new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
				new NoteCocks("Toggle The NoteSplashes! (notecocks)")
			]),
			new OptionCata(640, 40, "Misc", [

				new FPSOption("Toggle the FPS Counter"),
				new DisplayMemory("Toggle the Memory Usage"),
				#if FEATURE_DISCORD new DiscordOption("Change your Discord Rich Presence update interval."),
				#end
				new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
				new WatermarkOption("Enable and disable all watermarks from the engine."),
				new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
				new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
				new ScoreScreen("Show the score screen after the end of a song"),
				new ShowInput("Display every single input on the score screen."),
			]),
			new OptionCata(935, 40, "Performance", [
				new OptimizeOption("Disable Background and Characters to save memory. Useful to low-end computers."),
				new Background("Disable Stage Background to save memory (Only characters are visible)."),
				new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay and save memory.")
			]),
			new OptionCata(50, 104, "Saves", [
				#if desktop // new ReplayOption("View saved song replays."),
				#end
				new ResetModifiersOption("Reset your Gameplay modifiers. This is irreversible!"),
				new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
				new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
				new ResetSettings("Reset ALL your settings. This is irreversible!")
			]),
			new OptionCata(-1, 125, "Editing Keybinds", [
				new LeftKeybind("The left note's keybind"),
				new DownKeybind("The down note's keybind"),
				new UpKeybind("The up note's keybind"),
				new RightKeybind("The right note's keybind"),
				new PauseKeybind("The keybind used to pause the game"),
				new ResetBind("The keybind used to die instantly"),
				new MuteBind("The keybind used to mute game audio"),
				new VolUpBind("The keybind used to turn the volume up"),
				new VolDownBind("The keybind used to turn the volume down"),
				new FullscreenBind("The keybind used to fullscreen the game")
			], true),
			new OptionCata(-1, 125, "Editing Judgements", [
				new SickMSOption("How many milliseconds are in the SICK hit window"),
				new GoodMsOption("How many milliseconds are in the GOOD hit window"),
				new BadMsOption("How many milliseconds are in the BAD hit window"),
				new ShitMsOption("How many milliseconds are in the SHIT hit window")
			], true)
		];

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();

		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		descBack = new FlxSprite(50, 642).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		if (isInPause)
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			menu.add(bg);

			descBack.alpha = 0.3;
			background.alpha = 0.5;
			bg.alpha = 0.6;

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		selectedCat = options[0];

		selectedOption = selectedCat.options[0];

		add(menu);

		add(shownStuff);

		for (i in 0...options.length - 1)
		{
			if (i >= 5)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject);
		}

		descText = new FlxText(62, 648);
		descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;

		add(descBack);
		add(descText);

		isInCat = true;

		switchCat(selectedCat);

		selectedOption = selectedCat.options[0];

		super.create();
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try
		{
			visibleRange = [164, 640];
			/*if (cat.middle)
				visibleRange = [Std.int(cat.titleObject.y), 640]; */
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - 3 && checkForOutOfBounds)
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = options[4].titleObject.y + 54 + (46 * i);
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			for (i in selectedCat.optionObjects)
				shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = options[4].titleObject.y + 54 + (46 * i);
				}
			}

			selectedOptionIndex = 0;

			if (!isInCat)
				selectOption(selectedOption);

			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
		catch (e)
		{
			Debug.logError("oops\n" + e);
			selectedCatIndex = 0;
		}

		Debug.logTrace("Changed cat: " + selectedCatIndex);

		for (i in 0...selectedCat.optionObjects.length)
		{
			selectedCat.optionObjects.members[i].color = FlxColor.WHITE;
		}
		#if html5
		if (selectedCatIndex == 0)
			selectedCat.optionObjects.members[6].color = FlxColor.YELLOW;
		#end
		if (FlxG.save.data.optimize && selectedCatIndex == 0)
			selectedCat.optionObjects.members[9].color = FlxColor.YELLOW;
		if (FlxG.save.data.optimize && selectedCatIndex == 3)
		{
			selectedCat.optionObjects.members[1].color = FlxColor.YELLOW;
			selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
		}
		if (!FlxG.save.data.background && selectedCatIndex == 3)
		{
			selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
		}
		if (!FlxG.save.data.healthBar && selectedCatIndex == 1)
			selectedCat.optionObjects.members[12].color = FlxColor.YELLOW;
		if (isInPause)
		{
			switch (selectedCatIndex)
			{
				case 0:
					selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
					#if html5
					selectedCat.optionObjects.members[6].color = FlxColor.YELLOW;
					#end
					selectedCat.optionObjects.members[12].color = FlxColor.YELLOW;
					if (PlayState.isStoryMode)
						selectedCat.optionObjects.members[5].color = FlxColor.YELLOW;
				case 3:
					for (i in 0...3)
						selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
				case 4:
					for (i in 0...4)
						selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
			}
		}
	}

	public function selectOption(option:Option)
	{
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInCat)
		{
			object.text = "> " + option.getValue();

			descText.text = option.getDescription();
			descText.color = FlxColor.WHITE;

			// FOR SOME REASON DESCRIPTION TEXT DOESN'T UPDATE INSIDE THE STATE AND I'M LAZY TO REWORK THIS FUCKING CODE IN OPTIONS SO I'M PUTTING MY CONDITIONS HERE INSTEAD OF OPTIONS.HX

			if (selectedOptionIndex == 12 && !FlxG.save.data.healthBar && selectedCatIndex == 1)
			{
				descText.text = "HEALTH BAR IS DISABLED! Colored health bar are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 1 && FlxG.save.data.optimize && selectedCatIndex == 3)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Distracions are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 2 && FlxG.save.data.optimize && selectedCatIndex == 3)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Backgrounds are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 2 && !FlxG.save.data.background && selectedCatIndex == 3)
			{
				descText.text = "BACKGROUNDS ARE DISABLED! Distracions are disabled.";
				descText.color = FlxColor.YELLOW;
			}
			if (selectedOptionIndex == 9 && FlxG.save.data.optimize && selectedCatIndex == 0)
			{
				descText.text = "OPTIMIZATION IS ENABLED! Cam Zooming is disabled.";
				descText.color = FlxColor.YELLOW;
			}
			#if html5
			if (selectedOptionIndex == 6 && selectedCatIndex == 0)
			{
				descText.text = "FPS cap setting is disabled in browser build.";
				descText.color = FlxColor.YELLOW;
			}
			#end
			if (descText.text == "BOTPLAY is disabled on Story Mode.")
			{
				descText.color = FlxColor.YELLOW;
			}
			if (descText.text == "This option cannot be toggled in the pause menu.")
				descText.color = FlxColor.YELLOW;
		}
		Debug.logTrace("Changed opt: " + selectedOptionIndex);

		Debug.logTrace("Bounds: " + visibleRange[0] + "," + visibleRange[1]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var accept = false;
		var right = false;
		var left = false;
		var up = false;
		var down = false;
		var any = false;
		var escape = false;

		changedOption = false;

		accept = FlxG.keys.justPressed.ENTER || (gamepad != null ? gamepad.justPressed.A : false);
		right = FlxG.keys.justPressed.RIGHT || (gamepad != null ? gamepad.justPressed.DPAD_RIGHT : false);
		left = FlxG.keys.justPressed.LEFT || (gamepad != null ? gamepad.justPressed.DPAD_LEFT : false);
		up = FlxG.keys.justPressed.UP || (gamepad != null ? gamepad.justPressed.DPAD_UP : false);
		down = FlxG.keys.justPressed.DOWN || (gamepad != null ? gamepad.justPressed.DPAD_DOWN : false);

		any = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		escape = FlxG.keys.justPressed.ESCAPE || (gamepad != null ? gamepad.justPressed.B : false);

		if (selectedCat != null && !isInCat)
		{
			for (i in selectedCat.optionObjects.members)
			{
				if (selectedCat.middle)
				{
					i.screenCenter(X);
				}

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}

		try
		{
			if (isInCat)
			{
				descText.text = "Please select a category";
				descText.color = FlxColor.WHITE;
				if (right)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex++;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - 3)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 3;

					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[0]);
				}

				if (escape)
				{
					if (!isInPause)
					{
						if (!FlxG.save.data.optimize)
						{
							FlxTween.tween(background, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
							for (i in 0...selectedCat.optionObjects.length)
							{
								FlxTween.tween(selectedCat.optionObjects.members[i], {alpha: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
							}
							for (i in 0...options.length - 1)
							{
								FlxTween.tween(options[i].titleObject, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
								FlxTween.tween(options[i], {alpha: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
							}
							FlxTween.tween(descText, {alpha: 0}, 0.5, {ease: FlxEase.smootherStepInOut});
							FlxTween.tween(descBack, {alpha: 0}, 0.5, {
								ease: FlxEase.smootherStepInOut,
								onComplete: function(twn:FlxTween)
								{
									MusicBeatState.switchState(new MainMenuState());
								}
							});
						}
						else
							MusicBeatState.switchState(new MainMenuState());
					}
					else
					{
						PauseSubState.goBack = true;
						PlayState.instance.updateSettings();
						close();
					}
				}
			}
			else
			{
				if (selectedOption != null)
					if (selectedOption.acceptType)
					{
						if (escape && selectedOption.waitingType)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'));
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
							return;
						}
						else if (any)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
							Debug.logTrace("New text: " + object.text);
						}
					}
				if (selectedOption.acceptType || !selectedOption.acceptType)
				{
					if (accept)
					{
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();

						if (selectedOptionIndex == prev)
						{
							FlxG.save.flush();

							object.text = "> " + selectedOption.getValue();
						}
					}

					if (down)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex++;

						// just kinda ignore this math lol

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = options[4].titleObject.y + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= 46;
								}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}
					else if (up)
					{
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'));
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						// just kinda ignore this math lol

						if (selectedOptionIndex < 0)
						{
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6)
								for (i in selectedCat.optionObjects.members)
								{
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2));
								}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6)
						{
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2)
								for (i in selectedCat.optionObjects.members)
								{
									i.y += 46;
								}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2)
						{
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = options[4].titleObject.y + 54 + (46 * i);
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}

					if (right)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();
						changedOption = true;

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
					}
					else if (left)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();
						changedOption = true;

						FlxG.save.flush();

						object.text = "> " + selectedOption.getValue();
						Debug.logTrace("New text: " + object.text);
					}
					if (changedOption)
					{
						for (i in 0...selectedCat.optionObjects.length)
						{
							selectedCat.optionObjects.members[i].color = FlxColor.WHITE;
						}
						if (selectedCatIndex == 0)
						{
							#if html5
							selectedCat.optionObjects.members[6].color = FlxColor.YELLOW;
							#end
							if (FlxG.save.data.optimize)
								selectedCat.optionObjects.members[9].color = FlxColor.YELLOW;
						}
						if (FlxG.save.data.optimize && selectedCatIndex == 3)
						{
							selectedCat.optionObjects.members[1].color = FlxColor.YELLOW;
							selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
						}
						if (!FlxG.save.data.background && selectedCatIndex == 3)
						{
							selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
						}
						if (!FlxG.save.data.healthBar && selectedCatIndex == 1)
							selectedCat.optionObjects.members[12].color = FlxColor.YELLOW;
						if (isInPause) // DUPLICATED CUZ MEMORY LEAK OR SMTH IDK
						{
							switch (selectedCatIndex)
							{
								case 0:
									selectedCat.optionObjects.members[2].color = FlxColor.YELLOW;
									selectedCat.optionObjects.members[12].color = FlxColor.YELLOW;
									if (PlayState.isStoryMode)
										selectedCat.optionObjects.members[5].color = FlxColor.YELLOW;
								case 3:
									for (i in 0...3)
										selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
								case 4:
									for (i in 0...4)
										selectedCat.optionObjects.members[i].color = FlxColor.YELLOW;
							}
						}
					}
					if (escape)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));

						if (selectedCatIndex >= 4)
							selectedCatIndex = 0;

						PlayerSettings.player1.controls.loadKeyBinds();

						Ratings.timingWindows = [
							FlxG.save.data.shitMs,
							FlxG.save.data.badMs,
							FlxG.save.data.goodMs,
							FlxG.save.data.sickMs
						];

						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = options[4].titleObject.y + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						isInCat = true;
						if (selectedCat.optionObjects != null)
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
							}
						if (selectedCat.middle)
							switchCat(options[0]);
					}
				}
			}
		}
		catch (e)
		{
			Debug.logError("wtf we actually did something wrong, but we dont crash bois.\n" + e);
			selectedCatIndex = 0;
			selectedOptionIndex = 0;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (selectedCat != null)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = options[4].titleObject.y + 54 + (46 * i);
				}
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				isInCat = true;
			}
		}
	}
}

package;

import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import Song.SongData;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import FreeplaySubState;
import Modifiers;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var helpText:FlxText;
	var opponentText:FlxText;
	var lerpScore:Int = 0;
	var intendedaccuracy:Float = 0.00;
	var intendedScore:Int = 0;
	var letter:String;
	var combo:String = 'N/A';
	var lerpaccuracy:Float = 0.00;

	var intendedColor:Int;
	var colorTween:FlxTween;

	var bg:FlxSprite;

	var Inst:FlxSound;

	public static var openMod:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private static var curPlaying:Bool = false;

	public static var songText:Alphabet;

	private var iconArray:Array<HealthIcon> = [];

	public static var icon:HealthIcon;

	public static var songData:Map<String, Array<SongData>> = [];

	public static var instance:FreeplayState;

	public static function loadDiff(diff:Int, songId:String, array:Array<SongData>)
	{
		var diffName:String = "";

		switch (diff)
		{
			case 0:
				diffName = "-easy";
			case 2:
				diffName = "-hard";
		}

		array.push(Song.conversionChecks(Song.loadFromJson(songId, diffName)));
	}

	public static var list:Array<String> = [];

	override function create()
	{Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.mouse.visible = true;
		instance = this;

		PlayState.wentToChartEditor = false;
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music(FlxG.save.data.watermark ? "ke_freakyMenu" : "freakyMenu"));
			MainMenuState.freakyPlaying = true;
		}

		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		cached = false;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		/*for (i in 0...songs.length - 1)
			songs[i].diffs.reverse(); */

		populateSongData();
		PlayState.inDaPlay = false;
		PlayState.currentSong = "bruh";

		#if !FEATURE_STEPMANIA
		trace("FEATURE_STEPMANIA was not specified during build, sm file loading is disabled.");
		#elseif FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		trace("tryin to load sm files");
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			trace(i);
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song, song, song]);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						trace("got content lol");
						songData.set(file.header.TITLE, [song, song, song]);
					}
				}
			}
		}
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD CHARACTERS
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songFixedName = StringTools.replace(songs[i].songName, "-", " ");
			songText = new Alphabet(0, (70 * i) + 30, songFixedName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			icon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.65, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var bottomBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(Std.int(FlxG.width), 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var bottomText:String = #if !mobile #if PRELOAD_ALL "  Press SPACE to listen to the Song Instrumental / Click and scroll through the songs with your MOUSE /"
			+ #else "  Click and scroll through the songs with your MOUSE /"
			+ #end #end
		" Your offset is "
		+ FlxG.save.data.offset
		+ "ms "
		+ (FlxG.save.data.optimize ? "/ Optimized" : "");

		var downText:FlxText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, bottomText, 16);
		downText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		downText.scrollFactor.set();
		add(downText);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 337, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		comboText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		comboText.font = scoreText.font;
		add(comboText);

		opponentText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		opponentText.font = scoreText.font;
		add(opponentText);

		diffText = new FlxText(scoreText.x, scoreText.y + 106, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 136, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 166, 0, "Rate: < " + FlxMath.roundDecimal(rate, 2) + "x >", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		helpText = new FlxText(scoreText.x, scoreText.y + 211, 0, "", 20);
		helpText.text = "LEFT-RIGHT to change Difficulty\n\n" + "SHIFT + LEFT-RIGHT to change Rate\n" + "if it's possible\n\n"
			+ "CTRL to open Gameplay Modifiers\n" + "";
		helpText.font = scoreText.font;
		helpText.color = 0xFFfaff96;
		add(helpText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if (!openMod)
		{
			changeSelection();
			changeDiff();
		}

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		PlayStateChangeables.modchart = FlxG.save.data.modcharts;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.opponentMode = FlxG.save.data.opponent;
		PlayStateChangeables.mirrorMode = FlxG.save.data.mirror;
		PlayStateChangeables.holds = FlxG.save.data.sustains;
		PlayStateChangeables.healthDrain = FlxG.save.data.hdrain;
		PlayStateChangeables.healthGain = FlxG.save.data.hgain;
		PlayStateChangeables.healthLoss = FlxG.save.data.hloss;
		PlayStateChangeables.practiceMode = FlxG.save.data.practice;
		PlayStateChangeables.skillIssue = FlxG.save.data.noMisses;

		super.create();
	}

	public static var cached:Bool = false;

	/**
	 * Load song data from the data files.
	 */
	static function populateSongData()
	{
		cached = false;
		list = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...list.length)
		{
			var data:Array<String> = list[i].split(':');
			var songId = data[0];
			var color = data[3];

			if (color == null)
			{
				color = "#9271fd";
			}

			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1], FlxColor.fromString(color));

			var diffs = [];
			var diffsThatExist = [];

			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-easy')))
				diffsThatExist.push("Easy");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId')))
				diffsThatExist.push("Normal");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-hard')))
				diffsThatExist.push("Hard");

			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
			}

			if (diffsThatExist.contains("Easy"))
				FreeplayState.loadDiff(0, songId, diffs);
			if (diffsThatExist.contains("Normal"))
				FreeplayState.loadDiff(1, songId, diffs);
			if (diffsThatExist.contains("Hard"))
				FreeplayState.loadDiff(2, songId, diffs);

			meta.diffs = diffsThatExist;

			if (diffsThatExist.length < 3)
				trace("I ONLY FOUND " + diffsThatExist);

			FreeplayState.songData.set(songId, diffs);
			trace('loaded diffs for ' + songId);
			FreeplayState.songs.push(meta);

			/*#if FFEATURE_FILESYSTEM
				sys.thread.Thread.create(() ->
				{
					FlxG.sound.cache(Paths.inst(songId));
				});
				#else
				FlxG.sound.cache(Paths.inst(songId));
				#end */
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:String)
	{
		var meta = new FreeplaySongMetadata(songName, weekNum, songCharacter, FlxColor.fromString(color));

		var diffs = [];
		var diffsThatExist = [];

		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-easy')))
			diffsThatExist.push("Easy");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName')))
			diffsThatExist.push("Normal");
		if (Paths.doesTextAssetExist(Paths.json('songs/$songName/$songName-hard')))
			diffsThatExist.push("Hard");
		if (diffsThatExist.length == 0)
		{
			if (FlxG.fullscreen)
				FlxG.fullscreen = !FlxG.fullscreen;
			Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
		}

		if (diffsThatExist.contains("Easy"))
			FreeplayState.loadDiff(0, songName, diffs);
		if (diffsThatExist.contains("Normal"))
			FreeplayState.loadDiff(1, songName, diffs);
		if (diffsThatExist.contains("Hard"))
			FreeplayState.loadDiff(2, songName, diffs);

		meta.diffs = diffsThatExist;

		if (diffsThatExist.length < 3)
			trace("I ONLY FOUND " + diffsThatExist);

		songData.set(songName, diffs);

		songs.push(meta);
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?color:String)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], color);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpaccuracy = FlxMath.lerp(lerpaccuracy, intendedaccuracy, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1) / (openfl.Lib.current.stage.frameRate / 60));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (Math.abs(lerpaccuracy - intendedaccuracy) <= 0.001)
			lerpaccuracy = intendedaccuracy;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		if (combo == "")
		{
			comboText.text = "RANK: N/A";
			comboText.alpha = 0.5;
		}
		else
		{
			comboText.text = "RANK: " + letter + " | " + combo + " (" + HelperFunctions.truncateFloat(lerpaccuracy, 2) + "%)\n";
			comboText.alpha = 1;
		}
		opponentText.text = "OPPONENT MODE: " + (FlxG.save.data.opponent ? "ON" : "OFF");

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER && !FlxG.keys.pressed.ALT;
		var dadDebug = FlxG.keys.justPressed.SIX;
		var charting = FlxG.keys.justPressed.SEVEN;
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!openMod && !MusicBeatState.switchingState)
		{
			if (FlxG.mouse.wheel != 0)
			{
				#if desktop
				changeSelection(-FlxG.mouse.wheel);
				#else
				if (FlxG.mouse.wheel < 0) // HTML5 BRAIN'T
					changeSelection(1);
				else if (FlxG.mouse.wheel > 0)
					changeSelection(-1);
				#end
			}

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					changeSelection(1);
				}
				if (gamepad.justPressed.DPAD_LEFT)
				{
					changeDiff(-1);
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					changeDiff(1);
				}
			}

			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}
		previewtext.text = "Rate: " + FlxMath.roundDecimal(rate, 2) + "x";

		previewtext.alpha = 1;

		if (FlxG.keys.justPressed.CONTROL && !openMod && !MusicBeatState.switchingState)
		{
			openMod = true;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			openSubState(new FreeplaySubState.ModMenu());
		}

		if (!openMod && !MusicBeatState.switchingState)
		{
			if (FlxG.keys.pressed.SHIFT) // && songs[curSelected].songName.toLowerCase() != "tutorial")
			{
				var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
				if (FlxG.keys.justPressed.LEFT)
				{
					rate -= 0.05;
					updateDiffCalc();
				}
				if (FlxG.keys.justPressed.RIGHT)
				{
					rate += 0.05;
					updateDiffCalc();
				}

				if (FlxG.keys.justPressed.R)
				{
					rate = 1;
					updateDiffCalc();
				}

				if (rate > 3)
				{
					rate = 3;
					updateDiffCalc();
				}
				else if (rate < 0.5)
				{
					rate = 0.5;
					updateDiffCalc();
				}

				previewtext.text = "Rate: < " + FlxMath.roundDecimal(rate, 2) + "x >";
			}
			else
			{
				if (FlxG.keys.justPressed.LEFT)
					changeDiff(-1);
				if (FlxG.keys.justPressed.RIGHT)
					changeDiff(1);
			}

			#if desktop
			if (FlxG.keys.justPressed.SPACE)
			{
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0.7, true);
				MainMenuState.freakyPlaying = false;
			}
			#end
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing && !MainMenuState.freakyPlaying)
			{
				#if (lime >= "8.0.0")
				FlxG.sound.music._channel.__source.__backend.setPitch(rate);
				#else
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
				#end
			}
		}
		#elseif html5
		@:privateAccess
		{
			if (FlxG.sound.music.playing && !MainMenuState.freakyPlaying)
			{
				#if (lime >= "8.0.0" && lime_howlerjs)
				FlxG.sound.music._channel.__source.__backend.setPitch(rate);
				#else
				FlxG.sound.music._channel.__source.__backend.parent.buffer.__srcHowl.rate(rate);
				#end
			}
		}
		#end

		#if html5
		diffCalcText.text = "RATING: N/A";
		diffCalcText.alpha = 0.5;
		#end

		if (!openMod && !MusicBeatState.switchingState)
		{
			if (controls.BACK)
			{
				MusicBeatState.switchState(new MainMenuState());
				clean();
				if (colorTween != null)
				{
					colorTween.cancel();
				}
			}

			for (item in grpSongs.members)
				if (accepted
					|| (((FlxG.mouse.overlaps(item) && item.targetY == 0) || (FlxG.mouse.overlaps(iconArray[curSelected])))
						&& FlxG.mouse.pressed))
				{
					loadSong();
					break;
				}
			#if debug
			// Going to charting state via Freeplay is only enable in debug builds.
			else if (charting)
				loadSong(true);

			// AnimationDebug and StageDebug are only enabled in debug builds.

			if (dadDebug)
			{
				loadAnimDebug(true);
			}
			if (bfDebug)
			{
				loadAnimDebug(false);
			}
			#end
		}

		if (openMod)
		{
			for (i in 0...iconArray.length)
				iconArray[i].alpha = 0;

			for (item in grpSongs.members)
				item.alpha = 0;
		}
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = hmm;

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		MusicBeatState.switchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);
	}

	/**
	 * Load into a song in free play, by name.
	 * This is a static function, so you can call it anywhere.
	 * @param songName The name of the song to load. Use the human readable name, with spaces.
	 * @param isCharting If true, load into the Chart Editor instead.
	 */
	public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			if (songData.get(songName) == null)
				return;

			currentSongData = songData.get(songName)[difficulty];

			if (songData.get(songName)[difficulty] == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		// 3% chance for loading Kade Engine's remix of test song.
		if (FlxG.random.bool(3))
		{
			PlayState.SONG = Song.loadFromJson('test', '');
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 0;
		}
		else
		{
			PlayState.SONG = currentSongData;
			PlayState.storyDifficulty = CoolUtil.difficultyArray.indexOf(songs[curSelected].diffs[difficulty]);
			PlayState.storyWeek = songs[curSelected].week;
		}
		PlayState.isStoryMode = false;

		Debug.logInfo('Loading song ${PlayState.SONG.songName} from week ${PlayState.storyWeek} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songCharacter == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end

		PlayState.songMultiplier = rate;

		if (isCharting)
			MusicBeatState.switchState(new ChartingState(reloadSong));
		else
			MusicBeatState.switchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = songs[curSelected].diffs.length - 1;
		if (curDifficulty > songs[curSelected].diffs.length - 1)
			curDifficulty = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		// adjusting the highscore song name to be compatible (changeDiff)
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		letter = Highscore.getLetter(songHighscore, curDifficulty);
		intendedaccuracy = Highscore.getAcc(songHighscore, curDifficulty);
		#end
		updateDiffCalc();
		diffText.text = 'DIFFICULTY: < ' + songs[curSelected].diffs[curDifficulty].toUpperCase() + ' >';
	}

	public function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		changeDiff();

		/*if (songs[curSelected].songName.toLowerCase() == "tutorial")
			{
				rate = 1.0;
		}*/

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 0.5, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}
		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		letter = Highscore.getLetter(songHighscore, curDifficulty);
		intendedaccuracy = Highscore.getAcc(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		/*diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			diffText.text = 'DIFFICULTY: < ' + CoolUtil.difficultyFromInt(curDifficulty).toUpperCase() + ' >'; */
		/*#if PRELOAD_ALL
			if (songs[curSelected].songCharacter == "sm")
			{
				var data = songs[curSelected];
				trace("Loading " + data.path + "/" + data.sm.header.MUSIC);
				var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
			{
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0.7);
			}
			#end */

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
			{
				if (FlxG.sound.music.playing && !MainMenuState.freakyPlaying)
					Conductor.changeBPM(hmm.bpm);
				GameplayCustomizeState.freeplayNoteStyle = hmm.noteStyle;
			}
		}
		catch (ex)
		{
		}

		var bullShit:Int = 0;

		if (!openMod && !MusicBeatState.switchingState)
		{
			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}

			iconArray[curSelected].alpha = 1;
		}

		for (item in grpSongs.members)
		{
			if (!openMod && !MusicBeatState.switchingState)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));
				}
			}
		}
	}

	public function updateDiffCalc():Void
	{
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
	}
}

class FreeplaySongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if FEATURE_STEPMANIA
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var diffs = [];

	#if FEATURE_STEPMANIA
	public function new(song:String, week:Int, songCharacter:String, ?color:FlxColor, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String, ?color:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
	}
	#end
}

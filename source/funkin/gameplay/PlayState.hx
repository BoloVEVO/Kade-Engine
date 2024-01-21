package funkin.gameplay;

import funkin._backend.utils.Ratings.RatingWindow;
import flixel.animation.FlxAnimationController;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import lime.media.openal.AL;
import openfl.media.Sound;
import openfl.events.KeyboardEvent;
import openfl.display.BitmapData;
import openfl.Lib;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;
import flixel.FlxSubState;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
#if FEATURE_DISCORD
import funkin._backend.utils.Discord.DiscordClient;
#end
#if FEATURE_LUAMODCHART
import funkin._backend.lua.LuaClass;
#end
#if FEATURE_STEPMANIA
import funkin._backend.utils.smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import sys.FileSystem;
#end
import funkin._backend.media.audio.AudioStream;
import lime.utils.Bytes;
import funkin._backend.MusicBeatState.subStates;
import flixel.addons.display.FlxRuntimeShader;
import funkin._backend.MusicBeatState.transSubstate;
import flixel.util.FlxPool;
import flixel.group.FlxSpriteGroup;
import funkin._backend.lua.ModchartState;
import funkin._backend.MusicBeatState;
import funkin.gameplay.objects.stage.*;
import funkin.gameplay.objects.Stage;
import funkin._backend.utils.WebmSprite;
import funkin._backend.system.Main;
import funkin.gameplay.objects.HitErrorBar;
import funkin._backend.utils.NoteskinHelpers;
import funkin.menus.OptionsMenu;
import funkin.menus.GitarooPause;
import funkin._backend.system.KeyBinds;
import funkin.editors.ChartingState;
import funkin._backend.utils.Highscore;
import funkin.menus.MainMenuState;
import funkin.menus.StoryMenuState;
import funkin.menus.LoadingState;
import funkin.menus.FreeplayState;
import funkin._backend.utils.EtternaFunctions;
import funkin._backend.utils.HelperFunctions;
import funkin._backend.utils.ExtendedVector;
import flixel.util.FlxSort;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public var tweenManager:FlxTweenManager = null;
	public var timerManager:FlxTimerManager = null;

	public static var SONG:SongData = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var SONGStyle:StyleData = null;

	public static var rate:Float = 1.0;

	public var songMultiplier(default, set):Float = rate;

	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var swags:Int = 0;

	public var songPosBG:FlxSprite = null;

	// public var visibleCombos:Array<FlxSprite> = [];
	// public var visibleNotes:Array<Note> = [];
	public var songPosBar:FlxBar = null;

	public var hitErrorBar:HitErrorBar = null;

	var noteskinSprite:FlxAtlasFrames = null;

	var noteskinPixelSprite:FlxGraphic;
	var noteskinPixelSpriteEnds:FlxGraphic;

	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var inDaPlay:Bool = false;

	public var inCinematic:Bool = false;

	var songLength:Float = 0;
	var songLengthDiscord:Float = 0;

	var kadeEngineWatermark:CoolText = null;

	public var storyDifficultyText:String = "";

	#if FEATURE_DISCORD
	// Discord RPC variables
	var iconRPC:String = "";
	var iconRPCBefore:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var vocals:FlxSound = null;

	public var inst:FlxSound = null;

	public static var vocalsStream:AudioStream = null;

	public static var instStream:AudioStream = null;

	public static var pauseStream:AudioStream = null;

	public static var isSM:Bool = false;
	#if FEATURE_STEPMANIA
	public static var sm:SMFile = null;
	public static var pathToSm:String;
	#end

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var boyfriendMap:Map<String, Boyfriend> = [];

	public var dadMap:Map<String, Character> = [];

	public var gfMap:Map<String, Character> = [];

	public var boyfriendGroup:FlxTypedSpriteGroup<Boyfriend>;

	public var gfGroup:FlxTypedSpriteGroup<Character>;
	public var dadGroup:FlxTypedSpriteGroup<Character>;

	public var notes:FlxTypedGroup<NoteSpr> = null;

	public var unspawnNotes:ExtendedVector<NoteDef>;

	public var strumLine:FlxSprite = null;

	private var camFollow:FlxPoint;

	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;

	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StaticArrow> = null;

	public var arrowLanes:FlxTypedGroup<FlxSprite> = null;

	public var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignSwags:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;
	public var shownAccuracy:Float = 0;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite = null;

	public var healthBar:FlxBar = null;

	private var songPositionBar:Float = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?

	private var camRatings:FlxCamera;

	public var camHUD:FlxCamera;

	public var camGame:FlxCamera;

	public var mainCam:FlxCamera;

	public var camNotes:FlxCamera;

	public var camSustains:FlxCamera;

	public var camStrums:FlxCamera;

	public var camVideo:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Float> = [];

	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	public static var lastSong:String = '';

	var songName:CoolText = null;

	var talking:Bool = true;

	public static var currentSong = "noneYet";

	public var songScore:Int = 0;
	public var shownSongScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:CoolText = null;

	var judgementCounter:CoolText = null;

	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText = null;
	var skipTo:Float;

	var accText:CoolText = null;

	public static var campaignScore:Int = 0;

	public static var campaignAccuracy:Float = 0.00;

	public var inCutscene:Bool = false;

	var usedTimeTravel:Bool = false;

	var camPos:FlxPoint;

	public var Stage:Stage = null;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// BotPlay text
	private var botPlayState:FlxText = null;

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	public var sourceModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// API stuff
	// WTF WHERE IS IT?
	// MAKING DEEZ PUBLIC TO MAKE COMPLEX ACCURACY WORK
	public var msTiming:Float;

	public var updatedAcc:Bool = false;

	// SONG MULTIPLIER STUFF
	var speedChanged:Bool = false;

	// Scroll Speed changes multiplier
	public var scrollMult:Float = 1.0;

	// SCROLL SPEED
	public var scrollSpeed(default, set):Float = 1.0;
	public var scrollTween:FlxTween = null;

	// Cheatin
	public static var usedBot:Bool = false;

	public static var wentToChartEditor:Bool = false;

	// Fake crochet for Sustain Notes
	public var fakeCrochet:Float = 0;

	public var fakeNoteStepCrochet:Float;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash> = null;

	public var initStoryLength:Int = 0;

	public var arrowsGenerated:Bool = false;

	public var arrowsAppeared:Bool = false;

	// MP4 vids var
	#if (FEATURE_MP4VIDEOS && !html5)
	var reserveVids:Array<VideoSprite> = [];

	public var daVideoGroup:FlxTypedGroup<VideoSprite> = null;
	#end

	// Webm vids var
	var reserveWebmVids:Array<WebmSprite> = [];

	public var daWebmGroup:FlxTypedGroup<WebmSprite> = null;

	public var playerNotes = 0;

	var songNotesCount = 0;

	var opponentNotes = 0;

	public static var isPixelStage:Bool = false;

	public function createTween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		var tween:FlxTween = tweenManager.tween(Object, Values, Duration, Options);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTweenNum(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):FlxTween
	{
		var tween:FlxTween = tweenManager.num(FromValue, ToValue, Duration, Options, TweenFunction);
		tween.manager = tweenManager;
		return tween;
	}

	public function createTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = timerManager;
		return timer.start(Time, OnComplete, Loops);
	}

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function destroyObj(object:FlxBasic)
	{
		object.destroy();
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		Paths.clearStoredMemory();

		FlxG.mouse.visible = false;
		FlxG.mouse.enabled = false;

		instance = this;

		#if cpp
		if (pauseStream == null)
		{
			pauseStream = new AudioStream(OpenFlAssets.getPath(Paths.music('breakfast', true)));
			pauseStream.persist = true;
		}
		#end

		chartEventHandler = new ChartEventHandler(false, this);
		tweenManager = new FlxTweenManager();
		timerManager = new FlxTimerManager();

		// grab variables here too or else its gonna break stuff later on

		GameplayCustomizeState.freeplayNoteStyle = SONG.noteStyle;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		inDaPlay = true;

		if (currentSong != SONG.songName)
		{
			currentSong = SONG.songName;
		}

		swags = 0;
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		SONGStyle = Style.loadJSONFile(SONG.songStyle);

		if (SONGStyle == null)
			SONGStyle = Style.loadJSONFile('default');

		isPixelStage = SONGStyle.styleName == 'pixel';

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;

		if (FlxG.save.data.scrollSpeed == 1)
			scrollSpeed = SONG.speed;
		else
			scrollSpeed = FlxG.save.data.scrollSpeed;

		if (!isStoryMode)
		{
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
		}
		else
		{
			PlayStateChangeables.modchart = true;
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.opponentMode = false;
			PlayStateChangeables.mirrorMode = false;
			PlayStateChangeables.holds = true;
			PlayStateChangeables.healthDrain = false;
			PlayStateChangeables.healthGain = 1;
			PlayStateChangeables.healthLoss = 1;
			PlayStateChangeables.practiceMode = false;
			PlayStateChangeables.skillIssue = false;
		}

		// FlxG.save.data.optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;
		PlayStateChangeables.middleScroll = FlxG.save.data.middleScroll;
		PlayStateChangeables.currentSkin = FlxG.save.data.noteskin;

		usedBot = false;

		removedVideo = false;

		#if FEATURE_LUAMODCHART
		// TODO: Refactor this to use OpenFlAssets.
		if (!isStoryMode)
			executeModchart = OpenFlAssets.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart')) && PlayStateChangeables.modchart;
		else
			executeModchart = OpenFlAssets.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		#if FEATURE_STEPMANIA
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua") && PlayStateChangeables.modchart;
		#end
		#end

		if (!isSM)
			storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);
		else
			storyDifficultyText = "SM";

		Debug.logInfo('Searching for mod chart? ($executeModchart) at ' + Paths.lua('songs/${PlayState.SONG.songId}/modchart'));

		/*if (executeModchart)
			songMultiplier = 1; */

		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.

		if (!isSM)
		{
			if (!PlayStateChangeables.opponentMode)
				iconRPCBefore = SONG.player2;
			else
				iconRPCBefore = SONG.player1;
		}
		else
			iconRPCBefore = 'sm';

		// To avoid having duplicate images in Discord assets
		switch (iconRPCBefore)
		{
			case 'senpai-angry':
				iconRPCBefore = 'senpai';
			case 'monster-christmas':
				iconRPCBefore = 'monster';
			case 'mom-car':
				iconRPCBefore = 'mom';
			case 'bf-holding-gf':
				iconRPCBefore = 'bf';
		}
		iconRPC = iconRPCBefore;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence
		if (FlxG.save.data.discordMode == 1)
			DiscordClient.changePresence(SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
				songLengthDiscord - Conductor.songPosition);
		else
			DiscordClient.changePresence("Playing "
				+ SONG.songName
				+ " ("
				+ storyDifficultyText
				+ " "
				+ songMultiplier
				+ "x"
				+ ") ", "", iconRPC, true,
				songLengthDiscord
				- Conductor.songPosition);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camRatings = new FlxCamera();
		camRatings.bgColor.alpha = 0;
		mainCam = new FlxCamera();
		mainCam.bgColor.alpha = 0;
		camVideo = new FlxCamera();
		camVideo.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camStrums = new FlxCamera();
		camStrums.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		// Game Camera (where stage and characters are)
		FlxG.cameras.reset(camGame);

		// Video Camera if you put funni videos or smth
		FlxG.cameras.add(camVideo, false);

		// HUD Camera (Health Bar, scoreTxt, etc)
		FlxG.cameras.add(camHUD, false);

		// Ratings Camera
		FlxG.cameras.add(camRatings, false);

		// StrumLine Camera
		FlxG.cameras.add(camStrums, false);

		// Long Notes camera
		FlxG.cameras.add(camSustains, false);

		// Single Notes camera
		FlxG.cameras.add(camNotes, false);

		// Main Camera
		FlxG.cameras.add(mainCam, false);

		camHUD.zoom = PlayStateChangeables.zoom;

		camNotes.zoom = camHUD.zoom;
		camSustains.zoom = camHUD.zoom;
		camStrums.zoom = camHUD.zoom;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		switch (SONG.songId)
		{
			case 'tutorial':
				sourceModchart = true;
			default:
				sourceModchart = false;
		}

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (Paths.doesTextAssetExist(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
			if (isStoryMode)
				inCutscene = true;
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage isn't specified in the chart, we use the story week value.
		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (SONG.songId == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (SONG.songId == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (!isStoryMode)
		{
			if (SONG.songId == 'test')
				storyDifficulty = 1;
		}

		Stage = new Stage(SONG.stage);

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		Stage.initStageProperties();

		if (Stage.loadGF)
		{
			gf = new Character(400, 130, gfCheck);

			if (FlxG.save.data.characters && gf.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				#end
				gf = new Character(400, 130, 'gf');
			}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		if (FlxG.save.data.characters && boyfriend.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load boyfriend: " + SONG.player1 + ". Loading default boyfriend"]);
			#end
			boyfriend = new Boyfriend(770, 450, 'bf');
		}

		dad = new Character(100, 100, SONG.player2);

		if (FlxG.save.data.characters && dad.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
			#end
			dad = new Character(100, 100, 'dad');
		}

		Stage.initCamPos();

		gfGroup = new FlxTypedSpriteGroup<Character>(0, 0);
		dadGroup = new FlxTypedSpriteGroup<Character>(0, 0);
		boyfriendGroup = new FlxTypedSpriteGroup<Boyfriend>(0, 0);

		boyfriendGroup.add(boyfriend);
		dadGroup.add(dad);
		if (gf != null)
			gfGroup.add(gf);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person != null)
						if (person.curCharacter == char)
							person.setPosition(pos[0], pos[1]);
		}

		camGame.zoom = Stage.camZoom;

		Stage.initStageSprites();

		if (FlxG.save.data.background)
		{
			for (i in Stage.toAdd)
			{
				add(i);
			}

			if (FlxG.save.data.distractions)
			{
				if (SONG.songId == 'stress')
				{
					switch (gf.curCharacter)
					{
						case 'pico-speaker':
							gf.loadMappedAnims();
					}
				}
			}

			for (index => array in Stage.layInFront)
			{
				switch (index)
				{
					case 0:
						if (gf != null)
						{
							add(gfGroup);
							gf.scrollFactor.set(0.95, 0.95);
						}

						for (bg in array)
							add(bg);
					case 1:
						add(dadGroup);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriendGroup);
						for (bg in array)
							add(bg);
				}
			}

			if (dad.hasTrail)
			{
				if (FlxG.save.data.distractions)
				{
					// trailArea.scrollFactor.set();
					if (FlxG.save.data.characters)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						// evilTrail.changeValuesEnabled(false, false, false, false);
						// evilTrail.changeGraphic()
						add(evilTrail);
					}
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}
			}
		}
		else
		{
			if (gf != null)
			{
				gf.scrollFactor.set(0.95, 0.95);
				add(gf);
			}
			add(dad);
			add(boyfriend);
		}

		if (!FlxG.save.data.characters)
		{
			if (gf != null)
				gf.alpha = 0;
			dad.alpha = 0;
			boyfriend.alpha = 0;
		}

		if (gf != null)
		{
			gf.x += gf.charPos[0];
			gf.y += gf.charPos[1];
		}
		dad.x += dad.charPos[0];
		dad.y += dad.charPos[1];
		boyfriend.x += boyfriend.charPos[0];
		boyfriend.y += boyfriend.charPos[1];

		camPos = new FlxPoint(0, 0);

		camPos.x = Stage.camPosition[0];
		camPos.y = Stage.camPosition[1];

		/*switch (Stage.curStage)
			{
				case 'halloween':
					camPos = new FlxPoint(gf.getMidpoint().x + dad.camPos[0], gf.getMidpoint().y + dad.camPos[1]);
				case 'tank':
					if (SONG.player2 == 'tankman')
						camPos = new FlxPoint(436.5, 534.5);
				case 'stage':
					if (dad.replacesGF)
						camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0] - 200, dad.getGraphicMidpoint().y + dad.camPos[1]);
				case 'mallEvil':
					camPos = new FlxPoint(boyfriend.getMidpoint().x - 100 + boyfriend.camPos[0], boyfriend.getMidpoint().y - 100 + boyfriend.camPos[1]);
				default:
					camPos = new FlxPoint(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);
		}*/

		if (dad.replacesGF)
		{
			if (gf != null)
			{
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			}

			camPos.x += 600;
			tweenCamIn();
		}

		var doof = null;

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		if (isStoryMode)
		{
			switch (storyWeek)
			{
				case 7:
					inCinematic = true;
				case 5:
					if (PlayState.SONG.songId == 'winter-horrorland')
						inCinematic = true;
			}
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLine = new FlxSprite(0, 0).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;
		else
			strumLine.y = FlxG.height - 670;

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		add(playerStrums);
		add(cpuStrums);

		playerStrums.visible = false;
		cpuStrums.visible = false;

		arrowLanes = new FlxTypedGroup<FlxSprite>();
		arrowLanes.camera = camHUD;

		if (isPixelStage)
		{
			noteskinPixelSprite = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, false, 'normal');
			noteskinPixelSpriteEnds = NoteskinHelpers.generatePixelSprite(FlxG.save.data.noteskin, true, 'normal');
		}
		else
			noteskinSprite = NoteskinHelpers.generateNoteskinSprite(FlxG.save.data.noteskin, 'normal',
				SONGStyle.replaceNoteTextures ? SONG.songStyle : 'default');

		var tweenBoolshit = !isStoryMode || storyPlaylist.length >= 3 || SONG.songId == 'tutorial';

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [PlayState.SONG.songId]);
		}
		#end

		setupStaticArrows(0);
		setupStaticArrows(1);

		add(arrowLanes);

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			if (luaModchart != null)
				luaModchart.registerStrums();
		}
		#end

		appearStaticArrows(tweenBoolshit);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		grpNoteSplashes.camera = camStrums;
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 'normal', 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		// startCountdown();

		if (SONG.songId == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.songId);

		var firstNoteTime = Math.POSITIVE_INFINITY;
		var playerTurn = false;
		for (index => section in SONG.notes)
		{
			for (note in section.sectionNotes)
			{
				if (note[0] < firstNoteTime)
				{
					firstNoteTime = note[0];
					if (note[1] > 3)
						playerTurn = true;
					else
						playerTurn = false;
				}
			}

			if (songNotesCount > 0)
				if (index + 1 == SONG.notes.length)
				{
					var timing = firstNoteTime;

					if (timing > 5000)
					{
						needSkip = true;
						skipTo = (timing - 1000) / songMultiplier;
					}
				}
		}

		if (SONG.songId == 'test')
			storyDifficulty = 1;

		#if (FEATURE_MP4VIDEOS && !html5)
		daVideoGroup = new FlxTypedGroup<VideoSprite>();

		add(daVideoGroup);
		#end

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			var window = new LuaWindow();
			new LuaCamera(FlxG.camera, "camGame").Register(luaModchart.lua);
			new LuaCamera(camHUD, "camHUD").Register(luaModchart.lua);
			new LuaCamera(mainCam, "mainCam").Register(luaModchart.lua);
			new LuaCamera(camStrums, "camStrums").Register(luaModchart.lua);
			new LuaCamera(camNotes, "camNotes").Register(luaModchart.lua);
			new LuaCamera(camSustains, "camSustains").Register(luaModchart.lua);
			new LuaCharacter(dad, "dad").Register(luaModchart.lua);
			new LuaCharacter(gf, "gf").Register(luaModchart.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(luaModchart.lua);
		}
		#end

		trace('generated');

		// add(strumLine);

		camFollow = new FlxPoint();

		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}

		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = Stage.camZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		var hudStyleShit = SONGStyle.replaceHUDAssets ? SONG.songStyle : 'default';
		healthBarBG = new FlxSprite(0, FlxG.height - 72).loadGraphic(Paths.image('hud/$hudStyleShit/healthBar', 'shared'));
		if (PlayStateChangeables.useDownscroll)
		{
			healthBarBG.y = FlxG.height - 670;
		}
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, PlayStateChangeables.opponentMode ? LEFT_TO_RIGHT : RIGHT_TO_LEFT,
			Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);

		healthBar.scrollFactor.set();

		RatingWindow.createRatings(SONG.judgeStyle);

		if (FlxG.save.data.hitErrorBar)
		{
			hitErrorBar = new HitErrorBar();
			hitErrorBar.camera = camHUD;
			hitErrorBar.screenCenter(X);

			if (PlayStateChangeables.useDownscroll)
				hitErrorBar.y = FlxG.height - 50;
			else
				hitErrorBar.y = FlxG.height - 670;
		}

		// healthBar
		var accMode:String = "None";
		if (FlxG.save.data.accuracyMod == 0)
			accMode = "Accurate";
		else if (FlxG.save.data.accuracyMod == 1)
			accMode = "Complex";

		// Add Kade Engine watermark
		kadeEngineWatermark = new CoolText(FlxG.width - 1276, FlxG.height - 27, 14.5, 16, Paths.bitmapFont('fonts/vcr'));
		kadeEngineWatermark.autoSize = true;
		kadeEngineWatermark.text = SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ storyDifficultyText;
		kadeEngineWatermark.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		kadeEngineWatermark.borderSize = 2;
		kadeEngineWatermark.antialiasing = FlxG.save.data.antialiasing;
		kadeEngineWatermark.updateHitbox();
		kadeEngineWatermark.scrollFactor.set();

		add(kadeEngineWatermark);

		// ACCURACY WATERMARK
		accText = new CoolText(kadeEngineWatermark.x, kadeEngineWatermark.y - 20, 14.5, 16, Paths.bitmapFont('fonts/vcr'));
		accText.autoSize = true;
		accText.text = "Accuracy Mode: " + accMode;
		accText.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		accText.antialiasing = FlxG.save.data.antialiasing;
		accText.borderSize = 2;
		accText.scrollFactor.set();
		accText.updateHitbox();

		add(accText);

		scoreTxt = new CoolText(0, healthBarBG.y + 50, 14.5, 16, Paths.bitmapFont('fonts/vcr'));

		scoreTxt.autoSize = true;
		scoreTxt.antialiasing = FlxG.save.data.antialiasing;
		scoreTxt.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		scoreTxt.borderSize = 2;

		scoreTxt.scrollFactor.set();

		scoreTxt.camera = camHUD;

		/*scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
			(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy)); */
		if (!FlxG.save.data.healthBar)
			scoreTxt.y = healthBarBG.y;

		add(scoreTxt);

		judgementCounter = new CoolText(35, 0, 20, 20, Paths.bitmapFont('fonts/vcr'));
		judgementCounter.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;
		judgementCounter.antialiasing = FlxG.save.data.antialiasing;
		judgementCounter.scrollFactor.set();
		judgementCounter.borderSize = 3.5;
		judgementCounter.borderQuality = 1;
		judgementCounter.y = (FlxG.height - 100) / 2;
		judgementCounter.camera = camHUD;
		judgementCounter.autoSize = true;
		if (FlxG.save.data.judgementCounter)
			add(judgementCounter);

		currentTimingShown = new CoolText(0, 0, 24, 24, Paths.bitmapFont('fonts/pixel'));
		currentTimingShown.scrollFactor.set();

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		botPlayState.cameras = [camHUD];
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(boyfriend.healthicon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(dad.healthicon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (FlxG.save.data.healthBar)
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);

			if (FlxG.save.data.colour)
			{
				if (!PlayStateChangeables.opponentMode)
					healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
				else
					healthBar.createFilledBar(boyfriend.barColor, dad.barColor);
			}
			else
			{
				if (!PlayStateChangeables.opponentMode)
					healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
				else
					healthBar.createFilledBar(0xFF66FF33, 0xFFFF0000);
			}
		}

		add(hitErrorBar);

		strumLineNotes.cameras = [camStrums];
		notes.cameras = [camNotes];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		if (isStoryMode)
			doof.cameras = [mainCam];
		kadeEngineWatermark.cameras = [camHUD];
		accText.cameras = [camHUD];

		currentTimingShown.camera = camRatings;
		comboSpr.camera = camRatings;
		rating.camera = camRatings;

		startingSong = true;

		trace('starting');

		if (FlxG.save.data.characters)
		{
			dad.dance();
			boyfriend.dance();
			if (gf != null)
				gf.dance();
		}

		cacheCountdown();

		if (inCutscene)
			cancelAppearArrows();

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					camStrums.visible = false;
					cancelAppearArrows();

					createTimer(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						snapCamFollowToPos(camFollow.x + 200, -2050);
						FlxG.camera.zoom = 1.5;

						createTimer(1, function(tmr:FlxTimer)
						{
							remove(blackScreen);
							createTween(camGame, {zoom: Stage.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
									camHUD.visible = true;
									camStrums.visible = true;
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					appearStaticArrows(false);
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);

				case 'ugh', 'guns', 'stress':
					if (FlxG.save.data.background)
						tankIntro();
					else
					{
						cancelAppearArrows();
						#if FEATURE_MP4VIDEOS
						startVideo('cutscenes/${SONG.songId}_cutscene');
						#end
					}

				default:
					createTimer(0.5, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			createTimer(0.5, function(timer)
			{
				startCountdown();
			});
		}

		var styleShit = SONGStyle.replaceSounds ? SONG.songStyle : 'default';
		for (i in 1...3)
		{
			precacheThing('$styleShit/missnote$i', 'sound', 'shared');
		}

		if (FlxG.save.data.characters)
		{
			if (PlayStateChangeables.opponentMode)
				new Character(0, 0, dad.deadChar);
			else
				new Character(0, 0, boyfriend.deadChar);
		}

		/*if (!loadRep)
			rep = new Replay("na"); */

		// This allow arrow key to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();

		#if desktop
		Application.current.window.title = Main.appName + ' - Playing ${SONG.songName} - ${CoolUtil.difficultyFromInt(storyDifficulty)}';
		#end

		#if FEATURE_DISCORD
		richPresenceUpdate = new FlxTimer(timerManager);
		richPresenceUpdate.start(1, function(_)
		{
			if (songStarted && !paused)
			{
				// Updating Discord Rich Presence
				if (FlxG.save.data.discordMode == 1)
					DiscordClient.changePresence(SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
						songLengthDiscord - Conductor.songPosition);
				else
					DiscordClient.changePresence("Playing "
						+ SONG.songName
						+ " ("
						+ storyDifficultyText
						+ " "
						+ songMultiplier
						+ "x"
						+ ") ", "", iconRPC,
						true, songLengthDiscord
						- Conductor.songPosition);
			}
		}, 0);
		#end

		if (FlxG.save.data.distractions && FlxG.save.data.background)
		{
			if (gfCheck == 'pico-speaker' && Stage.curStage == 'tank')
			{
				if (FlxG.save.data.distractions)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					if (Stage.swagBacks['tankmanRun'] != null)
					{
						Stage.swagBacks['tankmanRun'].add(firstTank);

						for (i in 0...TankmenBG.animationNotes.length)
						{
							if (FlxG.random.bool(16))
							{
								var tankBih = Stage.swagBacks['tankmanRun'].recycle(TankmenBG);
								tankBih.strumTime = TankmenBG.animationNotes[i].strumTime;
								tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i].noteData < 2);
								Stage.swagBacks['tankmanRun'].add(tankBih);
							}
						}
					}
				}
			}
		}

		if (!isStoryMode)
			tankIntroEnd = true;

		precacheThing('alphabet', 'image', null);

		#if !cpp
		precacheThing('breakfast', 'music', 'shared');
		#end

		if (FlxG.save.data.hitSound != 0)
			precacheThing("hitsounds/" + HitSounds.getSoundByID(FlxG.save.data.hitSound).toLowerCase(), 'sound', 'shared');

		cachePopUpScore();

		if (isStoryMode)
			initStoryLength = StoryMenuState.weekData()[storyWeek].songs.length;

		/*if (FlxG.save.data.optimize)
			Stage.destroy(); */
		add(comboSpr);
		comboSpr.alpha = 0;
		add(rating);
		rating.alpha = 0;
		add(currentTimingShown);
		currentTimingShown.alpha = 0;

		subStates.push(new PauseSubState());
		subStates.push(new ResultsScreen());
		subStates.push(new GameOverSubstate());
		subStates.push(new OptionsMenu(true));

		Paths.clearUnusedMemory();

		transSubstate.nextCamera = mainCam;
	}

	var richPresenceUpdate:FlxTimer;

	function cancelAppearArrows()
	{
		strumLineNotes.forEach(function(babyArrow:StaticArrow)
		{
			tweenManager.cancelTweensOf(babyArrow);
			babyArrow.alpha = 0;
			babyArrow.y = strumLine.y + FlxG.save.data.strumOffset.get(FlxG.save.data.downscroll ? 'downscroll' : 'upscroll');
		});
		arrowsAppeared = false;
	}

	function removeStaticArrows(?destroy:Bool = false)
	{
		if (arrowsGenerated)
		{
			arrowLanes.forEach(function(bgLane:FlxSprite)
			{
				arrowLanes.remove(bgLane, true);
			});

			playerStrums.forEach(function(babyArrow:StaticArrow)
			{
				playerStrums.remove(babyArrow);
				if (destroy)
					babyArrow.destroy();
			});
			cpuStrums.forEach(function(babyArrow:StaticArrow)
			{
				cpuStrums.remove(babyArrow);
				if (destroy)
					babyArrow.destroy();
			});
			strumLineNotes.forEach(function(babyArrow:StaticArrow)
			{
				strumLineNotes.remove(babyArrow);
				if (destroy)
					babyArrow.destroy();
			});
			arrowsGenerated = false;
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy', 'week6');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId == 'roses' || PlayState.SONG.songId == 'thorns')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns')
			{
				camHUD.visible = false;
				add(red);
			}
		}

		createTimer(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (PlayState.SONG.songId == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						createTimer(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								createTimer(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	#if FEATURE_LUAMODCHART
	public var luaModchart:ModchartState = null;
	#end

	function set_scrollSpeed(value:Float):Float // STOLEN FROM PSYCH ENGINE ONLY SPRITE SCALING PART.
	{
		speedChanged = true;
		if (generatedMusic)
		{
			var ratio:Float = value / scrollSpeed;
			for (note in notes)
			{
				if (note.animation.curAnim != null)
					if (note._def.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					{
						note.scale.y *= ratio;
						note.updateHitbox();
					}
			}
		}
		scrollSpeed = value;
		return value;
	}

	function startCountdown():Void
	{
		if (inCinematic || inCutscene)
		{
			if (!arrowsAppeared)
				appearStaticArrows(true);
		}
		inCinematic = false;
		inCutscene = false;
		canPause = true;

		// appearStaticArrows();

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		#if !cpp
		if (inst.playing)
			inst.stop();
		if (vocals != null)
			vocals.stop();
		#end

		var swagCounter:Int = 0;

		startTimer = createTimer((Conductor.crochet / 1000), function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (FlxG.save.data.characters)
			{
				if (gf != null)
					if (allowedToHeadbang && swagCounter % gfSpeed == 0)
						gf.dance();

				if (swagCounter % idleBeat == 0)
				{
					if (boyfriend != null && idleToBeat && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance(forcedToIdle);
					if (dad != null && idleToBeat)
						dad.dance(forcedToIdle);
				}
				else if (swagCounter % idleBeat != 0)
				{
					if (boyfriend != null && boyfriend.isDancing && !boyfriend.animation.curAnim.name.endsWith("miss"))
						boyfriend.dance();
					if (dad != null && dad.isDancing)
						dad.dance();
				}
			}

			var styleShit = SONGStyle.replaceHUDAssets ? SONG.songStyle : 'default';
			var soundStyle = SONGStyle.replaceSounds ? SONG.songStyle : 'default';
			var introAlts = ['hud/$styleShit/ready', 'hud/$styleShit/set', 'hud/$styleShit/go'];

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('$soundStyle/intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], 'shared'));
					ready.scrollFactor.set();
					ready.scale.set(0.7, 0.7);
					ready.cameras = [camHUD];
					ready.updateHitbox();

					ready.setGraphicSize(Std.int(ready.width * SONGStyle.scaleFactor));

					ready.screenCenter();
					add(ready);
					createTween(ready, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('$soundStyle/intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], 'shared'));
					set.scrollFactor.set();
					set.scale.set(0.7, 0.7);

					set.setGraphicSize(Std.int(set.width * SONGStyle.scaleFactor));
					set.cameras = [camHUD];
					set.screenCenter();
					add(set);
					createTween(set, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('$soundStyle/intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], 'shared'));
					go.scrollFactor.set();
					go.scale.set(0.7, 0.7);
					go.cameras = [camHUD];

					go.setGraphicSize(Std.int(go.width * SONGStyle.scaleFactor));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					createTween(go, {alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('$soundStyle/introGo'), 0.6);
			}

			swagCounter += 1;
		}, 4);
	}

	var lastReportedPlayheadPosition:Int = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];
	var binds:Array<String> = [
		FlxG.save.data.leftBind,
		FlxG.save.data.downBind,
		FlxG.save.data.upBind,
		FlxG.save.data.rightBind
	];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		if (!isStoryMode && PlayStateChangeables.botPlay)
			return;

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

		var data = -1;

		data = getKeyFromKeyCode(evt.keyCode);

		if (data == -1)
			return;

		keys[data] = false;

		if (songStarted && !paused)
			keyShit();
	}

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (!isStoryMode && PlayStateChangeables.botPlay || loadRep || paused || !songStarted)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		if (FlxG.keys.checkStatus(evt.keyCode, JUST_PRESSED))
		{
			var lastConductorTime:Float = Conductor.songPosition;

			Conductor.songPosition = lastConductorTime;

			@:privateAccess
			var key = FlxKey.toStringMap.get(evt.keyCode);

			var data = -1;

			data = getKeyFromKeyCode(evt.keyCode);

			if (data == -1)
			{
				trace("couldn't find a keybind with the code " + key);
				return;
			}
			if (keys[data])
			{
				trace("ur already holding " + key);
				return;
			}

			keys[data] = true;

			var closestNotes:Array<NoteSpr> = notes.members.filter(function(aliveNote:NoteSpr)
			{
				return aliveNote != null && aliveNote.alive && aliveNote._def.canBeHit && aliveNote._def.mustPress && !aliveNote._def.wasGoodHit
					&& !aliveNote._def.isSustainNote && aliveNote._def.noteData == data;
			});

			var defNotes:Array<NoteDef> = [for (v in closestNotes) v._def];

			haxe.ds.ArraySort.sort(defNotes, sortHitNotes);

			if (closestNotes.length != 0)
			{
				var coolNote = null;
				coolNote = defNotes[0];

				if (defNotes.length > 1) // stacked notes or really close ones
				{
					for (i in 0...defNotes.length)
					{
						if (i == 0) // skip the first note
							continue;

						var note = defNotes[i];

						if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
						{
							trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
							// just fuckin remove it since it's a stacked note and shouldn't be there
							destroyNote(note.connectedNote);
						}
					}
				}

				if (!PlayStateChangeables.opponentMode)
					boyfriend.holdTimer = 0;
				else
					dad.holdTimer = 0;

				goodNoteHit(coolNote);
			}
			else if (!FlxG.save.data.ghost && songStarted)
			{
				noteMiss(data, null);

				health -= 0.04 * PlayStateChangeables.healthLoss;
			}

			if (songStarted && !inCutscene && !paused)
				keyShit();

			Conductor.songPosition = Conductor.rawPosition;
		}
	}

	private function getKeyFromKeyCode(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...binds.length)
			{
				if (key == binds[i])
				{
					return i;
				}
			}
		}
		return -1;
	}

	public var songStarted = false;

	public var doAnything = false;

	public var bar:FlxSprite;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;

		#if FEATURE_WEBM
		if (daWebmGroup != null)
		{
			for (vid in daWebmGroup)
			{
				vid.webmHandler.resume();
			}
		}
		#end

		#if (FEATURE_MP4VIDEOS && !html5)
		if (daVideoGroup != null)
		{
			for (vid in daVideoGroup)
			{
				vid.bitmap.resume();
			}
		}
		#end

		lastReportedPlayheadPosition = 0;

		#if cpp
		instStream.play();
		vocalsStream.play();
		#else
		inst.play();
		vocals.play();
		#end

		// have them all dance when the song starts
		if (FlxG.save.data.characters)
		{
			if (allowedToHeadbang)
				if (gf != null)
					gf.dance();
			if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance(forcedToIdle);
			if (idleToBeat && !dad.animation.curAnim.name.startsWith("sing") && !PlayStateChangeables.opponentMode)
				dad.dance(forcedToIdle);

			// Song check real quick
			switch (SONG.songId)
			{
				case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog':
					allowedToCheer = true;
				default:
					allowedToCheer = false;
			}
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		if (inst != null)
			inst.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		if (FlxG.save.data.songPosition)
		{
			createTween(songName, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			createTween(songPosBar, {alpha: 0.85}, 0.5, {ease: FlxEase.circOut});
			createTween(bar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, 500, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = FlxColor.WHITE;
			skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 2, 1);
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			createTween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function getNotesAmount():Int
	{
		var count:Int = 0;
		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var susLength:Float = songNotes[2] / songMultiplier;

				var anotherCrochet:Float = Conductor.crochet;
				var anotherStepCrochet:Float = anotherCrochet / 4;
				susLength = susLength / anotherStepCrochet;

				count++;

				if (susLength > 0)
				{
					if (PlayStateChangeables.holds)
						for (susNote in 0...Std.int(Math.max(susLength, 2)))
						{
							count++;
						}
				}
			}
		}

		return count;
	}

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		var songData = SONG;

		activeSong = SONG;

		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		#if !cpp
		inst = new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.songId));
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();
		#end

		setupMusicStream();

		if (PlayStateChangeables.skillIssue)
		{
			var redVignette:FlxSprite = new FlxSprite().loadGraphic(Paths.image('nomisses_vignette', 'shared'));
			redVignette.screenCenter();
			redVignette.cameras = [mainCam];
			add(redVignette);
		}

		trace('loaded vocals');

		#if cpp
		add(instStream);
		add(vocalsStream);
		#else
		FlxG.sound.list.add(inst);
		FlxG.sound.list.add(vocals);
		#end

		songMultiplier = isStoryMode ? 1 : PlayState.rate;

		addSongEvents();

		recalculateAllSectionTimes();

		checkforSections();

		Song.sortSectionNotes(SONG);

		Conductor.changeBPM(SONG.bpm * songMultiplier);

		fakeCrochet = Conductor.crochet;

		fakeNoteStepCrochet = fakeCrochet / 4;

		Debug.logTrace(fakeNoteStepCrochet);

		notes = new FlxTypedGroup<NoteSpr>();

		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		// allocateNotes();

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		unspawnNotes = new ExtendedVector<NoteDef>(getNotesAmount());

		var noteIndex = 0;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = (songNotes[0] - FlxG.save.data.offset - SONG.offset) / songMultiplier;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteType:String = songNotes[3];
				var daNoteSpeedMult:Int = songNotes[4];

				var daBeat = TimingStruct.getBeatFromTime(daStrumTime);

				var gottaHitNote:Bool = false;

				if (songNotes[1] > 3)
					gottaHitNote = true;
				else if (songNotes[1] <= 3)
					gottaHitNote = false;

				if (PlayStateChangeables.opponentMode)
					gottaHitNote = !gottaHitNote;

				var oldNote:NoteDef;

				if (noteIndex > 0)
					oldNote = unspawnNotes.getByIndex(noteIndex);
				else
					oldNote = null;

				var swagNote:NoteDef = new NoteDef(daStrumTime, daNoteData, oldNote, false, false, daBeat, daNoteType, daNoteSpeedMult, SONG.songStyle);

				/*if ((!gottaHitNote && FlxG.save.data.middleScroll && !PlayStateChangeables.opponentMode && !PlayStateChangeables.healthDrain)
					|| (!gottaHitNote && FlxG.save.data.middleScroll && PlayStateChangeables.opponentMode && !PlayStateChangeables.healthDrain))
					continue; */

				if (PlayStateChangeables.holds)
				{
					swagNote.sustainLength = songNotes[2] / songMultiplier;
				}
				else
				{
					swagNote.sustainLength = 0;
				}

				var susLength:Float = swagNote.sustainLength;

				var anotherCrochet:Float = Conductor.crochet;
				var anotherStepCrochet:Float = anotherCrochet / 4;
				susLength = susLength / anotherStepCrochet;

				unspawnNotes.set(noteIndex, swagNote);

				noteIndex++;

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				if (susLength > 0)
				{
					for (susNote in 0...Std.int(Math.max(susLength, 2)))
					{
						oldNote = unspawnNotes.getByIndex(noteIndex - 1);

						var sustainNote:NoteDef = new NoteDef(daStrumTime + (anotherStepCrochet * susNote) + anotherStepCrochet, daNoteData, oldNote, true,
							false, 0, daNoteType, daNoteSpeedMult, SONG.songStyle);

						unspawnNotes.set(noteIndex, sustainNote);

						sustainNote.noteType = swagNote.noteType;

						sustainNote.mustPress = gottaHitNote;

						sustainNote.parent = swagNote;
						swagNote.children.push(sustainNote);
						sustainNote.spotInLine = type;

						type++;
						noteIndex++;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress && !swagNote.isSustainNote)
					playerNotes++;
				else if (!swagNote.mustPress)
					opponentNotes++;

				songNotesCount++;
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;

		songLength = ((#if cpp instStream.length #else inst.length #end / songMultiplier) / 1000);

		songLengthDiscord = (#if cpp instStream.length #else inst.length #end / songMultiplier);

		var songPosY = FlxG.height - 706;
		if (PlayStateChangeables.useDownscroll)
			songPosY = FlxG.height - 33;

		songPosBar = new FlxBar(390, songPosY, LEFT_TO_RIGHT, 500, 25, this, 'songPositionBar', 0, songLength);
		songPosBar.alpha = 0;
		songPosBar.scrollFactor.set();
		songPosBar.createGradientBar([FlxColor.BLACK], [boyfriend.barColor, dad.barColor]);
		songPosBar.numDivisions = 800;
		add(songPosBar);

		bar = new FlxSprite(songPosBar.x, songPosBar.y).makeGraphic(Math.floor(songPosBar.width), Math.floor(songPosBar.height), FlxColor.TRANSPARENT);
		bar.alpha = 0;
		add(bar);

		FlxSpriteUtil.drawRect(bar, 0, 0, songPosBar.width, songPosBar.height, FlxColor.TRANSPARENT,
			{thickness: 4, color: (!FlxG.save.data.background ? FlxColor.WHITE : FlxColor.BLACK)});

		songName = new CoolText(0, bar.y + ((songPosBar.height - 15) / 2), 14.5, 16, Paths.bitmapFont('fonts/vcr'));
		songName.antialiasing = FlxG.save.data.antialiasing;
		songName.autoSize = true;
		songName.borderStyle = FlxTextBorderStyle.OUTLINE_FAST;

		songName.borderSize = 2;

		songName.scrollFactor.set();

		songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime(songLength, false) + ')';

		songName.alpha = 0;
		songName.visible = FlxG.save.data.songPosition;

		add(songName);

		bar.cameras = [camHUD];
		songPosBar.cameras = [camHUD];
		songName.cameras = [camHUD];

		songName.visible = FlxG.save.data.songPosition;
		songPosBar.visible = FlxG.save.data.songPosition;
		bar.visible = FlxG.save.data.songPosition;

		Debug.logTrace("whats the fuckin shit");
	}

	public static function setupMusicStream()
	{
		#if desktop
		if (!isSM)
		{
			try
			{
				if (lastSong != SONG.songId)
				{
					if (instStream != null)
					{
						instStream.persist = false;

						instStream.destroy();

						instStream = null;
					}

					if (vocalsStream != null)
					{
						vocalsStream.persist = false;
						vocalsStream.destroy();
						vocalsStream = null;
					}

					instStream = new AudioStream(OpenFlAssets.getPath(Paths.inst(SONG.songId, true)));
					instStream.persist = true;

					if (SONG.needsVoices)
					{
						vocalsStream = new AudioStream(OpenFlAssets.getPath(Paths.voices(SONG.songId, true)));
					}
					else
						vocalsStream = new AudioStream('');

					vocalsStream.persist = true;
					#if !cpp
					vocalsStream = null;
					instStream = null;
					#end
					lastSong = PlayState.SONG.songId;
				}
				else
				{
					instStream.stop();
					// remove(instStream);
					instStream.time = 0;
					vocalsStream.stop();
					// remove(vocalsStream);
					vocalsStream.time = 0;
				}
			}
			catch (e)
			{
				Debug.logError(e);
			}
		}

		#if FEATURE_STEPMANIA
		if (!isStoryMode && isSM)
		{
			trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
			try
			{
				instStream = new AudioStream(FileSystem.absolutePath(pathToSm + "/" + sm.header.MUSIC));
				lastSong = sm.header.MUSIC;
			}
			catch (e)
			{
				Debug.logError(e);
			}

			vocalsStream = new AudioStream('');
		}
		/*else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false); */
		#end
		#end
	}

	function sortByShit(Obj1:NoteDef, Obj2:NoteDef):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function setupStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(43,
				strumLine.y + FlxG.save.data.strumOffset.get(FlxG.save.data.downscroll ? 'downscroll' : 'upscroll'));

			// defaults if no noteStyle was found in chart
			var noteStyleCheck:String = 'normal';

			/*if (FlxG.save.data.optimize && player == 0)
				continue; */

			babyArrow.downScroll = FlxG.save.data.downscroll;

			if (SONG.noteStyle == null && FlxG.save.data.overrideNoteskins)
			{
				switch (storyWeek)
				{
					case 6:
						noteStyleCheck = 'pixel';
				}
			}
			else
			{
				noteStyleCheck = SONG.noteStyle;
			}

			if (PlayState.isPixelStage)
			{
				babyArrow.loadGraphic(noteskinPixelSprite, true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * SONGStyle.scaleFactor));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

				babyArrow.x += NoteSpr.swagWidth * i;
				babyArrow.animation.add('static', [i]);
				babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
				babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

				for (j in 0...4)
				{
					babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
				}
			}
			else
			{
				babyArrow.frames = noteskinSprite;

				for (j in 0...4)
				{
					babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
					babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
				}

				var lowerDir:String = dataSuffix[i].toLowerCase();

				babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
				babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
				babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

				babyArrow.x += NoteSpr.swagWidth * i;

				babyArrow.antialiasing = FlxG.save.data.antialiasing && SONGStyle.antialiasing;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7 * SONGStyle.scaleFactor));
			}

			babyArrow.loadLane();

			babyArrow.bgLane.updateHitbox();
			babyArrow.bgLane.scrollFactor.set();
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;

			babyArrow.ID = i;

			babyArrow.animation.followGlobalSpeed = false;

			switch (player)
			{
				case 0:
					if (!PlayStateChangeables.opponentMode)
						cpuStrums.add(babyArrow);
					else
						playerStrums.add(babyArrow);
					babyArrow.x += 20.5;

				case 1:
					if (!PlayStateChangeables.opponentMode)
						playerStrums.add(babyArrow);
					else
						cpuStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += ((FlxG.width / 2) * player);
			babyArrow.x += 48.5;

			if (PlayStateChangeables.middleScroll)
			{
				if (!PlayStateChangeables.opponentMode)
				{
					babyArrow.x -= 310;
					if (player == 0)
						babyArrow.x -= 410;
				}
				else
				{
					babyArrow.x += 310;
					if (player == 1)
						babyArrow.x += 410;
				}
			}

			/*cpuStrums.forEach(function(spr:FlxSprite)
				{
					spr.centerOffsets(); // CPU arrows start out slightly off-center
			});*/

			strumLineNotes.add(babyArrow);
		}
		arrowsGenerated = true;
	}

	private function appearStaticArrows(?tween:Bool = true):Void
	{
		strumLineNotes.forEach(function(babyArrow:StaticArrow)
		{
			if (tween)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				createTween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * babyArrow.ID)});
			}
			else
				babyArrow.alpha = 1;

			arrowLanes.add(babyArrow.bgLane);
		});
		arrowsAppeared = true;
	}

	/*private function appearStaticArrows():Void
		{
			var index = 0;
			strumLineNotes.forEach(function(babyArrow:FlxSprite)
			{
				if (isStoryMode && !FlxG.save.data.middleScroll || executeModchart)
					babyArrow.alpha = 1;
				if (index > 3 && FlxG.save.data.middleScroll && isStoryMode)
				{
					babyArrow.alpha = 1;
					index++;
				}
				else if (index > 3)
			});
	}*/
	function tweenCamIn():Void
	{
		createTween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		#if !mobile
		FlxG.mouse.visible = true;
		FlxG.mouse.enabled = true;
		#end
		if (paused)
		{
			#if FEATURE_WEBM
			if (daWebmGroup != null)
			{
				for (vid in daWebmGroup)
				{
					if (vid.webmHandler.initialized && !vid.webmHandler.ended)
						vid.webmHandler.pause();
				}
			}
			#end

			#if (FEATURE_MP4VIDEOS && !html5)
			if (daVideoGroup != null)
			{
				for (vid in daVideoGroup.members)
				{
					if (vid.alive)
						vid.bitmap.pause();
				}
			}
			#end

			#if cpp
			if (instStream.playing)
				instStream.pause();

			if (vocalsStream != null)
				if (vocalsStream.playing)
					vocalsStream.pause();
			#else
			if (inst.playing)
				inst.pause();
			if (vocals != null)
				if (vocals.playing)
					vocals.pause();
			#end

			if (scrollTween != null)
				scrollTween.active = false;

			#if FEATURE_DISCORD
			if (!endingSong)
			{
				if (FlxG.save.data.discordMode == 1)
					DiscordClient.changePresence("PAUSED on " + "\n" + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
				else
					DiscordClient.changePresence("PAUSED on " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", "", iconRPC);
			}
			#end
			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = false;
		}
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		FlxG.mouse.visible = false;
		FlxG.mouse.enabled = false;
		if (PauseSubState.goToOptions)
		{
			Debug.logTrace("pause thingyt");
			if (PauseSubState.goBack)
			{
				Debug.logTrace("pause thingyt");
				PauseSubState.goToOptions = false;

				openSubState(subStates[0]);
				PauseSubState.goBack = false;
			}
			else
			{
				openSubState(subStates[3]);
			}
		}
		else if (paused)
		{
			#if FEATURE_WEBM
			if (daWebmGroup != null)
			{
				for (vid in daWebmGroup)
				{
					if (vid.webmHandler.initialized && !vid.webmHandler.ended)
						vid.webmHandler.resume();
				}
			}
			#end

			#if (FEATURE_MP4VIDEOS && !html5)
			if (daVideoGroup != null)
			{
				for (vid in daVideoGroup)
				{
					if (vid.alive)
						vid.bitmap.resume();
				}
			}
			#end

			if (inst != null && !startingSong)
			{
				resyncVocals();
			}
			#if FEAUTURE_LUAMODCHART
			if (LuaReceptor.receptorTween != null)
				LuaReceptor.receptorTween.active = true;
			#end
			if (scrollTween != null)
				scrollTween.active = true;

			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = true;
			if (!PlayStateChangeables.botPlay)
				keyShit();
			paused = false;

			#if FEATURE_DISCORD
			if (FlxG.save.data.discordMode == 1)
			{
				DiscordClient.changePresence(SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
					+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
					"\nScr: " + songScore + " ("
					+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
					songLengthDiscord - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence("Playing "
					+ SONG.songName
					+ " ("
					+ storyDifficultyText
					+ " "
					+ songMultiplier
					+ "x"
					+ ") ", "", iconRPC, true,
					songLengthDiscord
					- Conductor.songPosition);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (endingSong)
			return;
		#if cpp
		// instStream.pause();
		// vocalsStream.pause();
		#else
		inst.pause();
		vocals.pause();
		#end

		if (songStarted)
		{
			#if cpp
			if (!instStream.playing || instStream.time != Conductor.songPosition * songMultiplier)
			{
				instStream.pause();
				instStream.play();
				instStream.time = Conductor.songPosition * songMultiplier;
			}

			if (!vocalsStream.playing || vocalsStream.time != Conductor.songPosition * songMultiplier)
			{
				vocalsStream.pause();

				if (!(vocalsStream.length < instStream.time))
				{
					vocalsStream.play();

					vocalsStream.time = Conductor.songPosition * songMultiplier;
				}
			}
			#else
			inst.resume();
			inst.time = Conductor.songPosition * songMultiplier;
			if (vocals != null)
				vocals.time = inst.time;
			vocals.resume();
			#end

			#if cpp
			if (instStream.playing)
				@:privateAccess
			{
				instStream.speed = songMultiplier;
				if (vocalsStream.playing)
					vocalsStream.speed = songMultiplier;
			}
			#elseif html5
			if (inst.playing)
				@:privateAccess
			{
				#if lime_howlerjs
				#if (lime >= "8.0.0")
				inst._channel.__alSource.__backend.setPitch(songMultiplier);
				if (vocals.playing)
					vocals._channel.__alSource.__backend.setPitch(songMultiplier);
				#else
				inst._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
				if (vocals.playing)
					vocals._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
				#end
				#end
			}
			#end
		}
	}

	function percentageOfSong():Float
	{
		return (Conductor.songPosition / songLength) * 100;
	}

	var vidIndex:Int = 0;

	public function backgroundOverlayVideo(vidSource:String, type:String, layInFront:Bool = false)
	{
		switch (type)
		{
			default:
				#if (FEATURE_MP4VIDEOS && !html5)
				var vid = new VideoSprite(0, 0);

				vid.antialiasing = true;

				if (!layInFront)
				{
					vid.scrollFactor.set(0, 0);
					vid.camera = camGame;
					vid.scale.set((6 / 5) + (Stage.camZoom / 8), (6 / 5) + (Stage.camZoom / 8));
				}
				else
				{
					vid.camera = camVideo;
					vid.scrollFactor.set();
					vid.scale.set((6 / 5), (6 / 5));
				}

				vid.updateHitbox();
				vid.visible = false;

				reserveVids.push(vid);
				if (!layInFront)
				{
					remove(daVideoGroup);
					remove(gf);
					remove(dad);
					remove(boyfriend);
					for (vid in reserveVids)
						daVideoGroup.add(vid);
					add(daVideoGroup);
					add(gf);
					add(boyfriend);
					add(dad);
				}
				else
				{
					for (vid in reserveVids)
					{
						vid.camera = camGame;
						daVideoGroup.add(vid);
					}
				}

				reserveVids = [];
				daVideoGroup.members[vidIndex].play(Paths.video('${PlayState.SONG.songId}/${vidSource}', type));
				vid.bitmap.rate = songMultiplier;

				daVideoGroup.members[vidIndex].visible = true;

				vidIndex++;
				#end
		}
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;
	public var currentBPM = 0;
	public var updateFrame = 0;

	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (FlxG.save.data.background)
			Stage.update(elapsed);

		if (unspawnNotes.length > 0)
		{
			while (unspawnNotes.getByIndex(0) != null && unspawnNotes.getByIndex(0).onScreen)
			{
				var defNote:NoteDef = unspawnNotes.getNextMember();

				if (notes.members[notes.length - 1] != null)
					if (notes.members[notes.length - 1]._def == defNote)
						break;

				// Idk if doing note pooling make creating instances safe or not.
				var dunceNote:NoteSpr = Type.createInstance(NoteSpr, []);
				dunceNote.setupNote(defNote);
				dunceNote.scrollFactor.set(0, 0);

				dunceNote.visible = dunceNote.active = true;

				#if FEATURE_LUAMODCHART
				if (executeModchart)
				{
					var n = new LuaNote(dunceNote._def, currentLuaIndex);
					n.Register(luaModchart.lua);
					dunceNote._def.LuaNote = n;
					dunceNote._def.luaID = currentLuaIndex;
					currentLuaIndex++;
				}
				#end

				if (dunceNote._def.isSustainNote)
					dunceNote.camera = camSustains;
				else
					dunceNote.camera = camNotes;

				notes.add(dunceNote);
				unspawnNotes.removeFirstMember();
			}
		}

		if (generatedMusic && SONG.events != null)
		{
			if (songStarted)
			{
				if (chartEventIndex < SONG.events.length)
				{
					while (SONG.events[chartEventIndex].beat <= curDecimalBeat)
					{
						switch (SONG.events[chartEventIndex].name)
						{
							default:
								chartEventHandler.processChartEvent(SONG.events[chartEventIndex]);
							case "cameraFlash":
								Debug.logTrace("cameraFlash detected. Processing in PlayState.");
								Debug.logTrace('Flash parameters: ${SONG.events[chartEventIndex].args[0]}');
								camGame.flash(FlxColor.WHITE, SONG.events[chartEventIndex].args[0], null, true);
						}
						chartEventIndex++;
						if (chartEventIndex >= SONG.events.length)
							break;
					}
				}
			}
		}
		if (!paused)
		{
			tweenManager.update(elapsed);
			timerManager.update(elapsed);
		}
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * songMultiplier, 0, 1);
		var lerpScore:Float = CoolUtil.boundTo(elapsed * 35, 0, 1);

		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		shownSongScore = Math.floor(FlxMath.lerp(shownSongScore, songScore, lerpScore));
		shownAccuracy = FlxMath.lerp(shownAccuracy, accuracy, lerpScore);
		if (Math.abs(shownAccuracy - accuracy) <= 0)
			shownAccuracy = accuracy;
		if (Math.abs(shownSongScore - songScore) <= 100)
			shownSongScore = songScore;
		if (firstHit)
			if (FlxG.save.data.lerpScore || nps >= 0)
				updateScoreText();
		if (generatedMusic && !paused && songStarted && songMultiplier < 1)
		{
			if (Conductor.songPosition * songMultiplier >= #if cpp instStream.time #else inst.time #end + 25
				|| Conductor.songPosition * songMultiplier <= #if cpp instStream.time #else inst.time #end - 25)
			{
				resyncVocals();
			}
		}
		if (health <= 0 && PlayStateChangeables.practiceMode)
			health = 0;
		else if (health >= 2 && PlayStateChangeables.practiceMode)
			health = 2;
		if (!usedBot && PlayStateChangeables.botPlay && !isStoryMode)
		{
			usedBot = true;
			add(botPlayState);
		}
		// Pull request that support new pitch shifting functions for New Dev Lime version: https://github.com/openfl/lime/pull/1510
		// YOOO WTF PULLED BY NINJAMUFFIN?? WEEK 8 LEAK???
		#if cpp
		if (instStream.playing)
			@:privateAccess
		{
			instStream.speed = songMultiplier;
			if (vocalsStream.playing)
				vocalsStream.speed = songMultiplier;
		}
		#else
		if (inst.playing)
			@:privateAccess
		{
			#if lime_howlerjs
			#if (lime >= "8.0.0")
			inst._channel.__alSource.__backend.setPitch(songMultiplier);
			if (vocals.playing)
				vocals._channel.__alSource.__backend.setPitch(songMultiplier);
			#else
			inst._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
			if (vocals.playing)
				vocals._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(songMultiplier);
			#end
			#end
		}
		#end
		if (generatedMusic)
		{
			if (songStarted && !endingSong)
			{
				if ((#if cpp instStream.length #else inst.length #end / songMultiplier) - Conductor.songPosition <= 0) // WELL THAT WAS EASY
				{
					Debug.logTrace("we're fuckin ending the song ");
					if (FlxG.save.data.scoreScreen)
					{
						FlxTween.tween(accText, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(judgementCounter, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(scoreTxt, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(kadeEngineWatermark, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(songName, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(songPosBar, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
						FlxTween.tween(bar, {alpha: 0}, 1, {ease: FlxEase.circIn, type: ONESHOT});
					}
					endingSong = true;
					endSong();
				}
			}
		}
		// For some reason full screen bind in parent class MusicBeatState doesn't work in PlayState.
		// So I had to put in here to make it work.
		var fullscreenBind = FlxKey.fromString(FlxG.save.data.fullscreenBind);

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		if (#if cpp instStream.playing #else inst.playing #end)
		{
			if (curTiming != null)
			{
				var currentTimingBpm = curTiming.bpm;

				if (currentTimingBpm != Conductor.bpm)
				{
					Debug.logTrace('Timing Struct BPM: ${currentTimingBpm} | Current Conductor BPM: ${Conductor.bpm}');
					Debug.logTrace("BPM CHANGE to " + currentTimingBpm + " at time: " + TimingStruct.getTimeFromBeat(curTiming.startBeat));
					Conductor.changeBPM(currentTimingBpm);
					Debug.logTrace('Timing Struct BPM: ${currentTimingBpm} | Current Conductor BPM: ${Conductor.bpm}');
				}
			}
		}
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('zoomAllowed', FlxG.save.data.camzoom);
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);
			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/
			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');
			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = updatedAcc;
			}
			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end
		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		if (notesHitArray.length > 0)
		{
			var data = Date.now().getTime();
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Float = notesHitArray[balls];

				if (cock + 1000 < data)
					notesHitArray.remove(cock);
				else
					break;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}
		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();
		scoreTxt.screenCenter(X);
		var pauseBind = FlxKey.fromString(FlxG.save.data.pauseBind);
		var gppauseBind = FlxKey.fromString(FlxG.save.data.gppauseBind);

		if ((FlxG.keys.anyJustPressed([pauseBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gppauseBind]) || !Main.focused)
			&& canPause
			&& !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				MusicBeatState.switchState(new GitarooPause());
			}
			else
				openSubState(subStates[0]);
		}
		if (FlxG.keys.justPressed.SEVEN && !isStoryMode)
		{
			wentToChartEditor = true;
			if (PlayStateChangeables.mirrorMode)
				PlayStateChangeables.mirrorMode = !PlayStateChangeables.mirrorMode;
			executeModchart = false;
			cannotDie = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new ChartingState());
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		var iconLerp = CoolUtil.boundTo(1 - (elapsed * 70), 0, 1);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		var iconOffset:Int = 26;

		if (health >= 2)
			health = 2;
		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(PlayStateChangeables.opponentMode ? 100 - healthBar.percent : healthBar.percent, 0, 100, 100, 0) * 0.01)
				- iconOffset);
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(PlayStateChangeables.opponentMode ? 100 - healthBar.percent : healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (iconP2.width - iconOffset);
		if (healthBar.percent < 20)
		{
			if (!PlayStateChangeables.opponentMode)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 1;
			#if FEATURE_DISCORD
			if (PlayStateChangeables.opponentMode)
				iconRPC = boyfriend.curCharacter + "-dead";
			#end
		}
		else
		{
			if (!PlayStateChangeables.opponentMode)
				iconP1.animation.curAnim.curFrame = 0;
			else
				iconP2.animation.curAnim.curFrame = 0;
		}
		if (healthBar.percent > 80)
		{
			if (!PlayStateChangeables.opponentMode)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 1;
			#if FEATURE_DISCORD
			if (!PlayStateChangeables.opponentMode)
				iconRPC = iconRPCBefore + "-dead";
			#end
		}
		else
		{
			if (!PlayStateChangeables.opponentMode)
				iconP2.animation.curAnim.curFrame = 0;
			else
				iconP1.animation.curAnim.curFrame = 0;
			#if FEATURE_DISCORD
			iconRPC = iconRPCBefore;
			#end
		}
		/* if (FlxG.keys.justPressed.NINE)
			MusicBeatState.switchState(new Charting()); */
		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			MusicBeatState.switchState(new AnimationDebug(dad.curCharacter));
		}
		if (FlxG.save.data.background)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				paused = true;
				// Deleted State for complete rework.
				// MusicBeatState.switchState(new StageDebugState());
			}
		if (FlxG.keys.justPressed.ZERO)
		{
			MusicBeatState.switchState(new AnimationDebug(boyfriend.curCharacter));
		}
		if (FlxG.keys.justPressed.THREE)
		{
			MusicBeatState.switchState(new AnimationDebug(gf.curCharacter));
		}
		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < inst.length)
			{
				usedTimeTravel = true;
				inst.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:NoteSpr)
				{
					if (daNote._def.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;
						destroyNote(daNote);
					}
				});

				inst.time = Conductor.songPosition;
				inst.resume();
				vocals.time = Conductor.songPosition;
				vocals.resume();
				createTimer(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end
		if (skipActive && Conductor.songPosition >= skipTo)
		{
			createTween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}
		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			#if cpp
			instStream.pause();
			vocalsStream.pause();
			#else
			inst.pause();
			vocals.pause();
			#end
			Conductor.songPosition = skipTo;
			Conductor.rawPosition = skipTo;
			#if cpp
			instStream.time = Conductor.songPosition;
			instStream.play();
			vocalsStream.time = Conductor.songPosition;
			vocalsStream.play();
			#else
			inst.time = Conductor.songPosition;
			inst.resume();
			vocals.time = Conductor.songPosition;
			vocals.resume();
			#end
			createTween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			Conductor.rawPosition += FlxG.elapsed * 1000;

			// sync
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = (Conductor.songPosition - songLength) / 1000;
			if (!paused)
			{
				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
				var curTime:Float = #if cpp instStream.time #else inst.time #end / songMultiplier;

				if (curTime < 0)
					curTime = 0;
				var secondsTotal:Int = Math.floor(((curTime - songLength) / 1000));

				if (secondsTotal < 0)
					secondsTotal = 0;
				songName.text = SONG.songName + ' (' + FlxStringUtil.formatTime((songLength - secondsTotal), false) + ')';
				songName.updateHitbox();
				songName.screenCenter(X);
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		// Custom Animations are alt sing animations for each note. So mirror mode fucks it playing the wrong animation.
		switch (SONG.songId)
		{
			case 'ugh':
				if (PlayStateChangeables.mirrorMode)
				{
					if (dad.animation.curAnim.name == 'singDOWN-alt')
					{
						dad.playAnim('singUP-alt');
					}
				}
			case 'stress':
				if (PlayStateChangeables.mirrorMode)
					if (dad.animation.curAnim.name == 'singUP-alt')
					{
						dad.playAnim('singDOWN-alt');
					}
		}
		#if !FEATURE_LUAMODCHART
		if (sourceModchart && PlayStateChangeables.modchart)
		{
			if (SONG.songId == 'tutorial')
			{
				var currentBeat = Conductor.songPosition / Conductor.crochet;

				if (curStep >= 400)
				{
					for (i in 0...playerStrums.length)
					{
						if (!paused)
						{
							cpuStrums.members[i].x += (1.1 * Math.pow(songMultiplier, 2)) * Math.sin((currentBeat + i * 0.25) * Math.PI);
							cpuStrums.members[i].y += (1.1 * Math.pow(songMultiplier, 2)) * Math.cos((currentBeat + i * 0.25) * Math.PI);
							playerStrums.members[i].x += (1.1 * Math.pow(songMultiplier, 2)) * Math.sin((currentBeat + i * 0.25) * Math.PI);
							playerStrums.members[i].y += (1.1 * Math.pow(songMultiplier, 2)) * Math.cos((currentBeat + i * 0.25) * Math.PI);
						}
					}
				}
			}
		}
		#end
		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf != null)
					if (gf.animation.curAnim.name == 'danceLeft'
						|| gf.animation.curAnim.name == 'danceRight'
						|| gf.animation.curAnim.name == 'idle')
					{
						// Per song treatment since some songs will only have the 'Hey' at certain times
						switch (SONG.songId)
						{
							case 'philly':
								{
									// General duration of the song
									if (curStep < 1000)
									{
										// Beats to skip or to stop GF from cheering
										if (curStep != 736 && curStep != 864)
										{
											if (curStep % 64 == 32)
											{
												// Just a garantee that it'll trigger just once
												if (!triggeredAlready)
												{
													gf.playAnim('cheer');
													triggeredAlready = true;
												}
											}
											else
												triggeredAlready = false;
										}
									}
								}
							case 'bopeebo':
								{
									// Where it starts || where it ends
									if (curStep > 20 && curStep < 520)
									{
										if (curStep % 32 == 28)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							case 'blammed':
								{
									if (curStep > 120 && curStep < 760)
									{
										if (curStep < 360 || curStep > 512)
										{
											if (curStep % 16 == 8)
											{
												if (!triggeredAlready)
												{
													gf.playAnim('cheer');
													triggeredAlready = true;
												}
											}
											else
												triggeredAlready = false;
										}
									}
								}
							case 'cocoa':
								{
									if (curStep < 680)
									{
										if (curStep < 260 || curStep > 520 && curStep < 580)
										{
											if (curStep % 64 == 60)
											{
												if (!triggeredAlready)
												{
													gf.playAnim('cheer');
													triggeredAlready = true;
												}
											}
											else
												triggeredAlready = false;
										}
									}
								}
							case 'eggnog':
								{
									if (curStep > 40 && curStep != 444 && curStep < 880)
									{
										if (curStep % 32 == 28)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
						}
					}
			}
		}
		if (FlxG.save.data.hitErrorBar)
			hitErrorBar.update(elapsed);
		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;
			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;
			var bpmRatio = Conductor.bpm / 100;

			FlxG.camera.zoom = FlxMath.lerp(Stage.camZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * bpmRatio * songMultiplier), 0, 1));
			camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * bpmRatio * songMultiplier), 0, 1));
			camNotes.zoom = camHUD.zoom;
			camSustains.zoom = camHUD.zoom;
			camStrums.zoom = camHUD.zoom;
			camRatings.zoom = camHUD.zoom;
		}
		#if debug
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		#end
		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = FlxG.save.data.camzoom;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// MusicBeatState.switchState(new TitleState());
			}
		}
		if (health <= 0 && !cannotDie && !PlayStateChangeables.practiceMode)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				#if cpp
				vocalsStream.pause();
				instStream.pause();
				#else
				vocals.stop();
				inst.stop();
				#end
				if (FlxG.save.data.InstantRespawn
					|| !FlxG.save.data.characters
					|| (PlayStateChangeables.opponentMode && !dad.animOffsets.exists('firstDeath')))
				{
					transSubstate.nextCamera = mainCam;
					MusicBeatState.switchState(new PlayState());
				}
				else
				{
					if (!PlayStateChangeables.opponentMode)
						openSubState(subStates[2]);
					else
						openSubState(subStates[2]);
				}
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode == 1)
				{
					DiscordClient.changePresence("GAME OVER -- " + "\n" + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
						songLengthDiscord - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC, true,
						songLengthDiscord - Conductor.songPosition);
				}
				#end
				// God I love watching Yosuga No Sora with my sister (From: Bolo)
				// God i love futabu!! so fucking much (From: McChomk)
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);

			if ((FlxG.keys.anyJustPressed([resetBind]) || KeyBinds.gamepad && FlxG.keys.anyJustPressed([gpresetBind])))
			{
				boyfriend.stunned = true;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				#if cpp
				vocalsStream.pause();
				instStream.pause();
				#else
				vocals.stop();
				inst.stop();
				#end
				if (FlxG.save.data.InstantRespawn
					|| !FlxG.save.data.characters
					|| (PlayStateChangeables.opponentMode && !dad.animOffsets.exists('firstDeath')))
				{
					transSubstate.nextCamera = mainCam;
					MusicBeatState.switchState(new PlayState());
				}
				else
				{
					if (!PlayStateChangeables.opponentMode)
						openSubState(subStates[2]);
					else
						openSubState(subStates[2]);
				}
				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.discordMode == 1)
				{
					DiscordClient.changePresence("GAME OVER -- " + "\n" + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
						+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
						"\nScr: " + songScore + " ("
						+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
						songLengthDiscord - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence("GAME OVER -- " + "\nPlaying " + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x"
						+ ") ", "", iconRPC, true,
						songLengthDiscord - Conductor.songPosition);
				}
				#end
			}
		}
		if (inCutscene || inCinematic)
			canPause = false;
		#if FEATURE_WEBM
		if (daWebmGroup != null)
		{
			daWebmGroup.forEachAlive(function(vid:WebmSprite)
			{
				if (vid != null && vid.webmHandler != null && vid.webmHandler.initialized && vid.webmHandler.ended)
				{
					vid.visible = false;
					vid.active = false;
					daWebmGroup.remove(vid, false);
					vid.alive = false;
					vid.kill();
					vid.destroy();
				}
			});
		}
		#end
		if (generatedMusic && !(inCutscene || inCinematic))
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			var leSpeed = scrollSpeed == 1 ? SONG.speed : scrollSpeed;

			for (daNote in notes.members.filter(function(aliveNote:NoteSpr)
			{
				return aliveNote != null && aliveNote.alive;
			}))
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote._def.noteData == -1)
				{
					Debug.logWarn('Weird Note detected! Note Data = "${daNote._def.rawNoteData}" is not valid, deleting...');
					destroyNote(daNote);
				}
				var strum:FlxTypedGroup<StaticArrow> = playerStrums;

				if (!daNote._def.mustPress)
					strum = cpuStrums;
				var strumY = strum.members[daNote._def.noteData].y;

				var strumX = strum.members[daNote._def.noteData].x;

				var strumAngle = strum.members[daNote._def.noteData].modAngle;

				var strumScrollType = strum.members[daNote._def.noteData].downScroll;

				var strumDirection = strum.members[daNote._def.noteData].direction;

				var angleDir = strumDirection * Math.PI / 180;

				var origin = strumY + NoteSpr.swagWidth / 2;

				if (daNote._def.isSustainNote)
					daNote.x = (strumX + Math.cos(angleDir) * daNote.distance) + (NoteSpr.swagWidth / 3);
				else
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;
				daNote.y = strumY + Math.sin(angleDir) * daNote.distance;
				if (!daNote.overrideDistance)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						daNote.distance = (0.45 * ((Conductor.songPosition - daNote._def.strumTime)) * (FlxMath.roundDecimal(leSpeed,
							2)) * daNote._def.speedMultiplier)
							- daNote.noteYOff;
					}
					else
						daNote.distance = (-0.45 * ((Conductor.songPosition - daNote._def.strumTime)) * (FlxMath.roundDecimal(leSpeed,
							2)) * daNote._def.speedMultiplier)
							+ daNote.noteYOff;
				}
				// OMG IT'S ALBERT EINSTEIN
				/*for (strum in strumLineNotes)
					{
						strum.y -= elapsed * 25 * leSpeed;
				}*/
				if (daNote._def.isSustainNote)
				{
					// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
					if (songStarted)
						if (daNote._def.sustainActive)
							if (daNote._def.prevNote.wasGoodHit)
							{
								if (strumScrollType)
								{
									if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= origin)
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

										swagRect.height = (origin - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
										daNote.clipRect = swagRect;
									}
								}
								else
								{
									if (daNote.y + daNote.offset.y * daNote.scale.y <= origin)
									{
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (origin - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
										daNote.clipRect = swagRect;
									}
								}
							}
				}
				if (!daNote._def.mustPress)
				{
					if (Conductor.songPosition >= daNote._def.strumTime)
						opponentNoteHit(daNote._def);
				}
				else
				{
					if (PlayStateChangeables.botPlay)
						handleBotplay(daNote._def);
					else if (!PlayStateChangeables.botPlay && daNote._def.isSustainNote && daNote._def.canBeHit && daNote._def.mustPress
						&& keys[daNote._def.noteData] && daNote._def.sustainActive)
						handleHolds(daNote._def);
				}
				if (daNote.exists)
				{
					if (Conductor.songPosition > Ratings.timingWindows[0].timingWindow + daNote._def.strumTime)
					{
						if (daNote._def.isSustainNote && daNote._def.wasGoodHit && Conductor.songPosition >= daNote._def.strumTime)
						{
							destroyNote(daNote);
						}
						if (daNote._def != null)
						{
							if (daNote._def.mustPress && daNote._def.tooLate && !daNote._def.canBeHit && daNote._def.mustPress)
							{
								if (daNote._def.isSustainNote && daNote._def.wasGoodHit)
								{
									destroyNote(daNote);
								}
								else
								{
									switch (daNote._def.noteType)
									{
										case 'hurt':
										default:
											if (daNote._def.isSustainNote && loadRep)
											{
												totalNotesHit += 1;
											}
											else
											{
												if (daNote._def.isParent && daNote.visible)
												{
													// health -= 0.15; // give a health punishment for failing a LN
													Debug.logTrace("User failed Sustain note at the start of sustain.");
													for (i in daNote._def.children)
													{
														i.sustainActive = false;
														health -= (0.04 * PlayStateChangeables.healthLoss) / daNote._def.children.length;
													}
													noteMiss(daNote._def.noteData, daNote._def);
												}
												else
												{
													if (!daNote._def.wasGoodHit && !daNote._def.isSustainNote)
													{
														health -= (0.04 * PlayStateChangeables.healthLoss);
														Debug.logTrace("User failed note.");
														noteMiss(daNote._def.noteData, daNote._def);
													}
												}
											}
									}
									destroyNote(daNote);
								}
							}
						}
					}
					// HOLD KEY RELEASE SHIT
					if (!PlayStateChangeables.botPlay)
						if (daNote._def != null)
							if (daNote._def.mustPress)
							{
								if (!daNote._def.wasGoodHit
									&& daNote._def.isSustainNote
									&& daNote._def.sustainActive
									&& !daNote._def.isSustainEnd
									&& !holdArray[Std.int(Math.abs(daNote._def.noteData))])
								{
									Debug.logTrace("User released key while playing a sustain at: " + daNote._def.spotInLine);
									for (i in daNote._def.parent.children)
									{
										i.sustainActive = false;
										health -= (0.08 * PlayStateChangeables.healthLoss) / daNote._def.parent.children.length;
									}
									if (daNote._def.parent.wasGoodHit)
									{
										totalNotesHit -= 1;
									}
									noteMiss(daNote._def.noteData, daNote._def);
								}
							}
				}
			}
		}
		charactersDance();
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		super.update(elapsed);
	}

	function endSong():Void
	{
		camZooming = false;
		endingSong = true;
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		PlayStateChangeables.botPlay = false;

		canPause = false;

		#if cpp
		instStream.pause();

		vocalsStream.pause();
		#else
		inst.volume = 0;
		inst.stop();
		vocals.volume = 0;
		vocals.stop();
		#end

		var legitTimings:Bool = true;
		for (rating in Ratings.timingWindows)
		{
			if (rating.timingWindow != rating.defaultTimingWindow)
			{
				legitTimings = false;
				break;
			}
		}

		var superMegaConditionShit:Bool = legitTimings
			&& !PlayState.usedBot
			&& !FlxG.save.data.practice
			&& PlayStateChangeables.holds
			&& !PlayState.wentToChartEditor
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthGain, 2) <= 1
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthLoss, 2) >= 1;

		if (SONG.validScore && superMegaConditionShit)
		{
			Highscore.saveScore(PlayState.SONG.songId, Math.round(songScore), storyDifficulty, songMultiplier);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateComboRank(accuracy), storyDifficulty, songMultiplier);
			Highscore.saveAcc(PlayState.SONG.songId, HelperFunctions.truncateFloat(accuracy, 2), storyDifficulty, songMultiplier);
			Highscore.saveLetter(PlayState.SONG.songId, Ratings.GenerateLetterRank(accuracy), storyDifficulty, songMultiplier);
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music(FlxG.save.data.watermark ? "ke_freakyMenu" : "freakyMenu"));
			offsetTesting = false;
			transSubstate.nextCamera = mainCam;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			#if FEATURE_DISCORD
			if (FlxG.save.data.discordMode == 1)
				DiscordClient.changePresence('RESULTS SCREEN -- ' + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
					+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
					"\nScr: " + songScore + " ("
					+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC);
			else
				DiscordClient.changePresence('RESULTS SCREEN -- ' + SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") ", iconRPC);
			#end

			if (isStoryMode)
			{
				campaignAccuracy += HelperFunctions.truncateFloat(accuracy, 2) / initStoryLength;
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignSwags += swags;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					paused = true;
					#if cpp
					instStream.pause();
					vocalsStream.pause();
					#else
					inst.stop();
					vocals.stop();
					#end
					if (FlxG.save.data.scoreScreen)
					{
						paused = true;
						persistentUpdate = false;
						openSubState(subStates[1]);
						createTimer(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						GameplayCustomizeState.freeplayNoteStyle = 'default';
						GameplayCustomizeState.freeplayWeek = 1;
						FlxG.sound.playMusic(Paths.music(FlxG.save.data.watermark ? "ke_freakyMenu" : "freakyMenu"));
						MainMenuState.freakyPlaying = true;
						Conductor.changeBPM(102);
						transSubstate.nextCamera = mainCam;
						MusicBeatState.switchState(new StoryMenuState());
					}

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty, 1);
					}
					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					var diff:String = CoolUtil.getSuffixFromDiff(CoolUtil.difficultyArray[storyDifficulty]);
					Debug.logInfo(CoolUtil.difficultyArray);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					if (FlxTransitionableState.skipNextTransIn)
					{
						transSubstate.nextCamera = null;
					}

					Debug.logInfo('PlayState: Loading next story song ${PlayState.storyPlaylist[0]}${diff}');

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], diff);
					#if cpp
					instStream.pause();
					#else
					inst.stop();
					#end

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				persistentUpdate = false;
				paused = true;

				#if cpp
				instStream.pause();
				vocalsStream.pause();
				#else
				inst.stop();
				vocals.stop();
				#end

				if (FlxG.save.data.scoreScreen)
				{
					persistentUpdate = false;
					paused = true;
					openSubState(subStates[1]);

					createTimer(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					transSubstate.nextCamera = mainCam;
					MainMenuState.freakyPlaying = true;
					Conductor.changeBPM(102);
					MusicBeatState.switchState(new FreeplayState());
				}
			}
		}
	}

	public var endingSong:Bool = false;

	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = rate - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	var timeShown = 0;
	var currentTimingShown:CoolText;

	/*public function NoteSplashesSpawn(daNote:Note):Void
		{
			var sploosh:FlxSprite = new FlxSprite(playerStrums.members[daNote.noteData].x + 10.5, playerStrums.members[daNote.noteData].y - 20);
			sploosh.antialiasing = FlxG.save.data.antialiasing;
			if (FlxG.save.data.noteSplashes)
			{
				switch (SONG.noteStyle)
				{
					case 'pixel':
						var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('weeb/pixelUI/noteSplashes-pixel_${daNote.noteType}', 'week6');

						sploosh.frames = tex;
						sploosh.animation.addByPrefix('splash 0 0', 'note splash 1 purple', 24, false);
						sploosh.animation.addByPrefix('splash 0 1', 'note splash 1  blue', 24, false);
						sploosh.animation.addByPrefix('splash 0 2', 'note splash 1 green', 24, false);
						sploosh.animation.addByPrefix('splash 0 3', 'note splash 1 red', 24, false);
						sploosh.animation.addByPrefix('splash 1 0', 'note splash 2 purple', 24, false);
						sploosh.animation.addByPrefix('splash 1 1', 'note splash 2 blue', 24, false);
						sploosh.animation.addByPrefix('splash 1 2', 'note splash 2 green', 24, false);
						sploosh.animation.addByPrefix('splash 1 3', 'note splash 2 red', 24, false);

						add(sploosh);
						sploosh.cameras = [camStrums];

						if (!FlxG.save.data.stepMania)
							sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
						else
							sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.originColor);
						sploosh.alpha = 0.6;
						sploosh.offset.x += 90;
						sploosh.offset.y += 80;
						sploosh.animation.finishCallback = function(name) sploosh.kill();

						sploosh.update(0);
					default:
						var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('noteSplashes_${daNote.noteType}', 'shared');
						sploosh.frames = tex;

						sploosh.animation.addByPrefix('splash 0 0', 'note splash 1 purple', 24, false);
						sploosh.animation.addByPrefix('splash 0 1', 'note splash 1  blue', 24, false);
						sploosh.animation.addByPrefix('splash 0 2', 'note splash 1 green', 24, false);
						sploosh.animation.addByPrefix('splash 0 3', 'note splash 1 red', 24, false);
						sploosh.animation.addByPrefix('splash 1 0', 'note splash 2 purple', 24, false);
						sploosh.animation.addByPrefix('splash 1 1', 'note splash 2 blue', 24, false);
						sploosh.animation.addByPrefix('splash 1 2', 'note splash 2 green', 24, false);
						sploosh.animation.addByPrefix('splash 1 3', 'note splash 2 red', 24, false);

						add(sploosh);
						sploosh.cameras = [camStrums];
						if (!FlxG.save.data.stepMania)
							sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
						else
							sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.originColor);
						sploosh.alpha = 0.6;
						sploosh.offset.x += 90;
						sploosh.offset.y += 80; // lets stick to eight not nine
						sploosh.animation.finishCallback = function(name) sploosh.kill();

						sploosh.update(0);
				}
			}
	}*/
	var rating:FlxSprite = new FlxSprite();
	var comboSpr:FlxSprite = new FlxSprite();
	var lastRating:String = '';
	var lastScore:Array<FlxSprite> = [];
	var maxScore = 1000000;

	private function popUpScore(noteDef:NoteDef):Void
	{
		var noteDiff:Float = -(noteDef.strumTime - Conductor.songPosition);

		if (FlxG.save.data.hitErrorBar)
			if (PlayStateChangeables.botPlay)
				hitErrorBar.registerHit(0);
			else
				hitErrorBar.registerHit(noteDiff);

		if (PlayStateChangeables.botPlay)
			noteDiff = 0;
		var noteDiffAbs = Math.abs(noteDiff);

		if (!PlayStateChangeables.botPlay)
		{
			if (FlxG.save.data.showMs)
			{
				currentTimingShown.alpha = 1;
				tweenManager.cancelTweensOf(currentTimingShown);
				currentTimingShown.alpha = 1;
			}

			rating.velocity.y = 0;
			rating.velocity.x = 0;
			tweenManager.cancelTweensOf(rating);
			rating.alpha = 1;

			if (FlxG.save.data.showCombo)
			{
				if (combo > 5)
				{
					comboSpr.velocity.y = 0;
					comboSpr.velocity.x = 0;
					tweenManager.cancelTweensOf(comboSpr);
					comboSpr.alpha = 1;
				}
			}
		}

		// boyfriend.playAnim('hey');

		var wife:Float = 0;
		if (!noteDef.isSustainNote)
			wife = EtternaFunctions.wife3(noteDiffAbs);

		#if cpp
		if (vocalsStream.playing)
			vocalsStream.volume = 1;
		#else
		vocals.volume = 1;
		#end

		//

		var daRating:RatingWindow = Ratings.judgeNote(noteDiff);
		var score:Float = 0;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;
		else
			totalNotesHit += daRating.accuracyBonus;

		totalPlayed += 1;

		noteDef.rating = daRating;

		if (!noteDef.isSustainNote)
		{
			ResultsScreen.instance.registerHit(noteDef);
		}

		if (daRating.causeMiss)
		{
			misses++;
			combo = 0;
		}

		if (FlxG.save.data.scoreMod == 0)
			score = daRating.scoreBonus;

		health += daRating.healthBonus > 0 ? daRating.healthBonus * PlayStateChangeables.healthGain : daRating.healthBonus * PlayStateChangeables.healthLoss;

		daRating.count++;

		if (daRating.causeMiss)
			scoreTxt.color = FlxColor.RED;
		else
			scoreTxt.color = FlxColor.WHITE;

		if (FlxG.save.data.noteSplashes)
		{
			if (daRating.doNoteSplash)
			{
				spawnNoteSplashOnStrum(noteDef);
			}
		}

		if (FlxG.save.data.scoreMod == 1)
			score = EtternaFunctions.getMSScore(noteDiffAbs);
		else if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		songScore += Math.round(score);

		var styleShit = SONGStyle.replaceHUDAssets ? SONG.songStyle : 'default';

		if (lastRating != daRating.name.toLowerCase())
		{
			rating.loadGraphic(Paths.image('hud/$styleShit/${daRating.name.toLowerCase()}', 'shared'));

			rating.antialiasing = FlxG.save.data.antialiasing && PlayState.SONGStyle.antialiasing;

			rating.setGraphicSize(Std.int(rating.width * SONGStyle.scaleFactor * 0.7));
		}

		lastRating = daRating.name.toLowerCase();

		rating.x = FlxG.save.data.changedHitX;
		rating.y = FlxG.save.data.changedHitY;

		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
		if (PlayStateChangeables.botPlay)
			msTiming = 0;

		timeShown = 0;

		currentTimingShown.color = daRating.displayColor;

		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 2;
		currentTimingShown.borderColor = FlxColor.BLACK;
		if (FlxG.save.data.showMs)
			currentTimingShown.text = msTiming + "ms";

		if (FlxG.save.data.showCombo)
			if (combo > 5)
			{
				if (comboSpr.graphic != Paths.image('hud/$styleShit/combo', 'shared'))
				{
					comboSpr.loadGraphic(Paths.image('hud/$styleShit/combo', 'shared'));

					comboSpr.setGraphicSize(Std.int(comboSpr.width * SONGStyle.scaleFactor * 0.6));
					comboSpr.antialiasing = FlxG.save.data.antialiasing;
				}
				comboSpr.screenCenter();
				comboSpr.x = rating.x - 84;
				comboSpr.y = rating.y + 145;

				comboSpr.antialiasing = FlxG.save.data.antialiasing && PlayState.SONGStyle.antialiasing;

				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;
				if (SONG.noteStyle == 'pixel')
				{
					comboSpr.x += 5.5;
					comboSpr.y += 29.5;
				}
				comboSpr.velocity.x += FlxG.random.int(1, 10);
				comboSpr.updateHitbox();
			}

		currentTimingShown.x = rating.x + 150;
		currentTimingShown.y = rating.y + 85;

		if (SONG.noteStyle == 'pixel')
		{
			currentTimingShown.x -= 15;
			currentTimingShown.y -= 15;
		}

		/*currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150; */

		currentTimingShown.updateHitbox();

		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		if (combo > highestCombo)
			highestCombo = combo - 1;

		// make sure we have 3 digits to display (looks weird otherwise lol)
		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
			seperatedScore.push(0);

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		if (FlxG.save.data.showComboNum)
		{
			if (lastScore != null)
			{
				while (lastScore.length > 0)
				{
					if (lastScore[0] != null)
						lastScore[0].destroy();
					lastScore.remove(lastScore[0]);
				}
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('hud/' + styleShit + '/num' + Std.int(i), 'shared'));

				numScore.cameras = [camRatings];

				numScore.antialiasing = FlxG.save.data.antialiasing && PlayState.SONGStyle.antialiasing;

				numScore.setGraphicSize(Std.int(numScore.width * SONGStyle.scaleFactor));

				numScore.updateHitbox();

				numScore.x = rating.x + (43 * daLoop) - ((numScore.width * seperatedScore.length) / 2) + 25;
				numScore.y = rating.y + 100;

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (FlxG.save.data.showComboNum)
					if (combo >= 5)
					{
						lastScore.push(numScore);
						add(numScore);
					}

				createTween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						remove(numScore);
						numScore.destroy();
					},

					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
		}

		createTween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		if (FlxG.save.data.showMs)
			createTween(currentTimingShown, {alpha: 0}, 0.1, {startDelay: Conductor.crochet * 0.0005});

		if (combo > 5)
			if (FlxG.save.data.showCombo)
				createTween(comboSpr, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var ctrlMap:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	private function parseControls(?suffix:String = ''):Array<Bool>
	{
		var array = [];
		for (i in 0...ctrlMap.length)
			array[i] = Reflect.getProperty(controls, ctrlMap[i] + suffix);
		return array;
	}

	function sortHitNotes(a:NoteDef, b:NoteDef):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U

		var holdArray:Array<Bool> = parseControls();
		var pressArray:Array<Bool> = parseControls('_P');
		var releaseArray:Array<Bool> = parseControls('_R');
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (!isStoryMode && PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		if (FlxG.save.data.hitSound != 0 && pressArray.contains(true))
		{
			if (FlxG.save.data.strumHit)
			{
				var daHitSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSound).toLowerCase()}',
					'shared'));
				daHitSound.volume = FlxG.save.data.hitVolume;
				daHitSound.play();
			}
		}

		playerStrums.forEach(function(spr:StaticArrow)
		{
			if (!PlayStateChangeables.botPlay)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
				{
					spr.playAnim('pressed', false);
					if (spr.animation.curAnim.name == 'pressed' && spr.animation.curAnim.finished)
						spr.animation.curAnim.pause();
				}
				if (!keys[spr.ID])
				{
					spr.playAnim('static', false);
					spr.localAngle = 0;
				}
			}
		});
	}

	private function handleHolds(def:NoteDef)
	{
		// HOLDS, check for sustain notes
		if (keys.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			goodNoteHit(def);
		}
	}

	private function charactersDance()
	{
		if (FlxG.save.data.characters)
		{
			if (boyfriend.holdTimer >= Conductor.stepCrochet * 4 * 0.001
				&& (!keys.contains(true) || PlayStateChangeables.botPlay || PlayStateChangeables.opponentMode))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss')
					&& (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
					boyfriend.dance();
			}
		}
		// Debug.logInfo('dadHoldTimer: ' + dad.holdTimer + ", condition:" + Conductor.stepCrochet * 4 * 0.001 * dad.holdLength);

		if (PlayStateChangeables.opponentMode)
		{
			if (FlxG.save.data.characters)
			{
				if (dad.holdTimer > Conductor.stepCrochet * 4 * 0.001 * dad.holdLength * 0.5
					&& (!keys.contains(true) || PlayStateChangeables.botPlay))
				{
					if (dad.animation.curAnim.name.startsWith('sing')

						&& !dad.animation.curAnim.name.endsWith('miss')
						&& (boyfriend.animation.curAnim.curFrame >= 10 || dad.animation.curAnim.finished))
					{
						dad.dance();
					}
				}
			}
		}
	}

	// This function is broken until I figure out what's happening.

	/*public function backgroundVideo(source:String, layInFront:Int = 2, screenCenter:Bool = true, camera:FlxCamera, looped:Bool, ?width:Int = 1280,
				?height:Int = 720, ?x:Float, ?y:Float)
		{
			#if (FEATURE_MP4VIDEOS && !html5)
			useVideo = true;
			var daSource = Paths.video(source);

			videoSprite = new FlxSprite();
			videoSprite.antialiasing = true;
			videoSprite.scrollFactor.set(0, 0);

			videoSprite.screenCenter();
			videoSprite.cameras = [camera];

			videoHandler = new VideoSprite();
			videoHandler.playVideo(daSource, looped, true, false);

			videoSprite.loadGraphic(videoHandler.bitmap.bitmapData);

			videoSprite.setGraphicSize(width, height);

			var perecentSupposed = (FlxG.sound.music.time / songMultiplier) / (FlxG.sound.music.length / songMultiplier);
			videoHandler.bitmap.seek(perecentSupposed);
			videoHandler.bitmap.resume();

			if (camera == camGame)
			{
				switch (layInFront)
				{
					case 0:
						remove(gf);
						add(videoSprite);
						add(gf);
					case 1:
						remove(dad);
						remove(gf);
						add(videoSprite);
						add(gf);
						add(dad);
					case 2:
						remove(dad);
						remove(gf);
						remove(boyfriend);
						add(videoSprite);
						add(gf);
						add(dad);
						add(boyfriend);
				}
			}

			Debug.logInfo(videoSprite.graphic == null ? 'MP4 background video sprite is broken for now :C' : 'Playing MP4 background video sprite!: $daSource');
			#end
	}*/
	function noteMiss(direction:Int = 1, noteDef:NoteDef):Void
	{
		if (!boyfriend.stunned)
		{
			#if cpp
			if (vocalsStream.playing)
				vocalsStream.volume = 0;
			#else
			vocals.volume = 0;
			#end
			if (PlayStateChangeables.skillIssue)
				if (!PlayStateChangeables.opponentMode)
					health = 0;
				else
					health = 2.1;
			// health -= 0.15;
			if (gf != null)
			{
				if (combo > 5 && gf.animOffsets.exists('sad') && !PlayStateChangeables.opponentMode)
				{
					gf.playAnim('sad');
				}
			}

			if (combo != 0)
			{
				combo = 0;
			}
			misses++;

			if (noteDef != null)
			{
				noteDef.rating = Ratings.timingWindows[0];
				ResultsScreen.instance.registerHit(noteDef, true);
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.scoreMod == 1)
			{
				var score = EtternaFunctions.getMSScore(Ratings.timingWindows[0].timingWindow);

				songScore += Math.round(score);
			}

			totalNotesHit -= 1;

			if (FlxG.save.data.scoreMod == 0)
			{
				if (noteDef != null)
				{
					if (!noteDef.isSustainNote)
						songScore -= 10;
				}
				else
					songScore -= 10;
			}

			if (FlxG.save.data.missSounds)
			{
				var styleShit = SONGStyle.replaceSounds ? SONG.songStyle : 'default';
				FlxG.sound.play(Paths.soundRandom('$styleShit/missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}

			// Hole switch statement replaced with a single line :)
			if (FlxG.save.data.characters)
			{
				if (!PlayStateChangeables.opponentMode)
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
				else if (PlayStateChangeables.opponentMode && dad.animOffsets.exists('sing' + dataSuffix[direction] + 'miss'))
					dad.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			if (FlxG.save.data.hitErrorBar)
				hitErrorBar.registerHit(Ratings.timingWindows[0].timingWindow);

			updateAccuracy();
			updateScoreText();
		}
	}

	function updateAccuracy()
	{
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		updatedAcc = true;
		judgementCounter.text = '';

		var timingWins = Ratings.timingWindows.copy();
		timingWins.reverse();

		for (rating in timingWins)
			judgementCounter.text += '${rating.name}s: ${rating.count}\n';

		judgementCounter.updateHitbox();

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		if (FlxG.save.data.discordMode == 1)
			DiscordClient.changePresence(SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
				songLengthDiscord - Conductor.songPosition);
		#end
	}

	private function handleBotplay(def:NoteDef)
	{
		if (def.mustPress && Conductor.songPosition >= def.strumTime)
		{
			// Force good note hit regardless if it's too late to hit it or not as a fail safe

			goodNoteHit(def);
			if (!PlayStateChangeables.opponentMode)
				boyfriend.holdTimer = 0;
			else
				dad.holdTimer = 0;
		}
	}

	function updateScoreText()
	{
		if (FlxG.save.data.lerpScore)
		{
			scoreTxt.text = Ratings.CalculateRanking(shownSongScore, songScoreDef, nps, maxNPS,
				(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(shownAccuracy, 0) : shownAccuracy));
		}
		else
		{
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS,
				(FlxG.save.data.roundAccuracy ? FlxMath.roundDecimal(accuracy, 0) : accuracy));
		}

		scoreTxt.updateHitbox();
		scoreTxt.screenCenter(X);

		// scoreTxt.x = scoreTxt.getStringWidth(scoreTxt.text) / 2;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function opponentNoteHit(noteDef:NoteDef):Void
	{
		if (SONG.songId != 'tutorial')
			camZooming = FlxG.save.data.camzoom;
		var altAnim:String = "";

		#if cpp
		if (vocalsStream.playing)
			vocalsStream.volume = 1;
		#else
		vocals.volume = 1;
		#end

		if (noteDef.noteType == 'alt')
		{
			altAnim = '-alt';
			trace("YOO WTF THIS IS AN ALT NOTE????");
		}
		#if FEATURE_DISCORD
		if (FlxG.save.data.discordMode == 1)
			DiscordClient.changePresence(SONG.songName + " (" + storyDifficultyText + " " + songMultiplier + "x" + ") "
				+ Ratings.GenerateComboRank(accuracy) + " " + Ratings.GenerateLetterRank(accuracy),
				"\nScr: " + songScore + " ("
				+ HelperFunctions.truncateFloat(accuracy, 2) + "%)" + " | Misses: " + misses, iconRPC, true,
				songLengthDiscord - Conductor.songPosition);
		#end

		if (!noteDef.wasGoodHit)
		{
			if (noteDef.isParent)
				for (i in noteDef.children)
					i.sustainActive = true;

			if (!PlayStateChangeables.opponentMode)
				dad.holdTimer = 0;
			else
				boyfriend.holdTimer = 0;

			if (PlayStateChangeables.healthDrain)
			{
				if (!noteDef.isSustainNote)
					updateScoreText();

				if (!noteDef.isSustainNote)
				{
					health -= .04 * PlayStateChangeables.healthLoss;
					if (health <= 0.01)
					{
						health = 0.01;
					}
				}
				else
				{
					health -= .02 * PlayStateChangeables.healthLoss;
					if (health <= 0.01)
					{
						health = 0.01;
					}
				}
			}

			var singData:Int = Std.int(Math.abs(noteDef.noteData));

			if (FlxG.save.data.characters)
			{
				if (PlayStateChangeables.opponentMode)
					boyfriend.playAnim('sing' + dataSuffix[singData] + altAnim, true);
				else
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				if (!PlayStateChangeables.opponentMode)
					luaModchart.executeState('playerTwoSing', [Math.abs(noteDef.noteData), Conductor.songPosition]);
				else
					luaModchart.executeState('playerOneSing', [Math.abs(noteDef.noteData), Conductor.songPosition]);
			#end
			if (!PlayStateChangeables.opponentMode)
				dad.holdTimer = 0;
			else
				boyfriend.holdTimer = 0;
			if (SONG.needsVoices)
				#if cpp
				if (vocalsStream.playing)
					vocalsStream.volume = 1;
				#else
				vocals.volume = 1;
				#end

			if (FlxG.save.data.cpuStrums)
			{
				cpuStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, noteDef);
				});
			}

			if (!noteDef.isSustainNote)
				destroyNote(noteDef.connectedNote);

			noteDef.wasGoodHit = true;
		}
	}

	var firstHit:Bool = false;

	function goodNoteHit(noteDef:NoteDef, resetMashViolation = true):Void
	{
		if (PlayStateChangeables.opponentMode)
			camZooming = FlxG.save.data.camzoom;

		if (mashing != 0)
			mashing = 0;

		firstHit = true;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first

		if (!noteDef.isSustainNote)
		{
			var noteDate:Date = Date.now();
			notesHitArray.unshift(noteDate.getTime());
		}

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!noteDef.wasGoodHit)
		{
			switch (noteDef.noteType)
			{
				case 'hurt':
					health -= 0.5;

				default:
			}

			if (!noteDef.isSustainNote)
			{
				if (FlxG.save.data.hitSound != 0)
				{
					if (!FlxG.save.data.strumHit)
					{
						var daHitSound:FlxSound = new FlxSound()
							.loadEmbedded(Paths.sound('hitsounds/${HitSounds.getSoundByID(FlxG.save.data.hitSound).toLowerCase()}', 'shared'));
						daHitSound.volume = FlxG.save.data.hitVolume;
						daHitSound.play();
					}
				}

				switch (noteDef.noteType)
				{
					case 'hurt':
					default:
						combo += 1;
						popUpScore(noteDef);
				}

				/* Enable Sustains to be hit. 
					//This is to prevent hitting sustains if you hold a strum before the note is coming without hitting the note parent. 
					(I really hope I made me understand lol.) */
				if (noteDef.isParent)
					for (i in noteDef.children)
						i.sustainActive = true;
			}

			var altAnim:String = "";
			if (noteDef.noteType == 'alt')
			{
				altAnim = '-alt';
			}

			if (FlxG.save.data.characters)
			{
				if (PlayStateChangeables.opponentMode)
					dad.playAnim('sing' + dataSuffix[noteDef.noteData] + altAnim, true);
				else
					boyfriend.playAnim('sing' + dataSuffix[noteDef.noteData] + altAnim, true);
			}

			/*
				———————————No HP regen?———————————
				⠀⣞⢽⢪⢣⢣⢣⢫⡺⡵⣝⡮⣗⢷⢽⢽⢽⣮⡷⡽⣜⣜⢮⢺⣜⢷⢽⢝⡽⣝
				⠸⡸⠜⠕⠕⠁⢁⢇⢏⢽⢺⣪⡳⡝⣎⣏⢯⢞⡿⣟⣷⣳⢯⡷⣽⢽⢯⣳⣫⠇
				⠀⠀⢀⢀⢄⢬⢪⡪⡎⣆⡈⠚⠜⠕⠇⠗⠝⢕⢯⢫⣞⣯⣿⣻⡽⣏⢗⣗⠏⠀
				⠀⠪⡪⡪⣪⢪⢺⢸⢢⢓⢆⢤⢀⠀⠀⠀⠀⠈⢊⢞⡾⣿⡯⣏⢮⠷⠁⠀⠀
				⠀⠀⠀⠈⠊⠆⡃⠕⢕⢇⢇⢇⢇⢇⢏⢎⢎⢆⢄⠀⢑⣽⣿⢝⠲⠉⠀⠀⠀⠀
				⠀⠀⠀⠀⠀⡿⠂⠠⠀⡇⢇⠕⢈⣀⠀⠁⠡⠣⡣⡫⣂⣿⠯⢪⠰⠂⠀⠀⠀⠀
				⠀⠀⠀⠀⡦⡙⡂⢀⢤⢣⠣⡈⣾⡃⠠⠄⠀⡄⢱⣌⣶⢏⢊⠂⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⢝⡲⣜⡮⡏⢎⢌⢂⠙⠢⠐⢀⢘⢵⣽⣿⡿⠁⠁⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠨⣺⡺⡕⡕⡱⡑⡆⡕⡅⡕⡜⡼⢽⡻⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⣼⣳⣫⣾⣵⣗⡵⡱⡡⢣⢑⢕⢜⢕⡝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⣴⣿⣾⣿⣿⣿⡿⡽⡑⢌⠪⡢⡣⣣⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⡟⡾⣿⢿⢿⢵⣽⣾⣼⣘⢸⢸⣞⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				⠀⠀⠀⠀⠁⠇⠡⠩⡫⢿⣝⡻⡮⣒⢽⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
				—————————————————————————————
				Just kidding lol
			 */

			switch (noteDef.noteType)
			{
				case 'hurt':
					spawnNoteSplashOnStrum(noteDef);
				default:
					if (noteDef.isSustainNote)
						health += 0.02 * PlayStateChangeables.healthGain;
					if (!noteDef.isSustainNote)
					{
						updateAccuracy();
						updateScoreText();
					}
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				if (!PlayStateChangeables.opponentMode)
					luaModchart.executeState('playerOneSing', [Math.abs(noteDef.noteData), Conductor.songPosition]);
				else
					luaModchart.executeState('playerTwoSing', [Math.abs(noteDef.noteData), Conductor.songPosition]);
			#end

			if (!PlayStateChangeables.botPlay || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, noteDef);
				});
			}

			if (!noteDef.isSustainNote)
			{
				destroyNote(noteDef.connectedNote);
			}

			noteDef.wasGoodHit = true;
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, noteDef:NoteDef)
	{
		if (Math.abs(noteDef.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);

				spr.animation.finishCallback = function(name)
				{
					if (noteDef.mustPress && PlayStateChangeables.botPlay)
					{
						if ((!noteDef.isSustainNote && !noteDef.isParent) || noteDef.isSustainEnd)
						{
							spr.playAnim('static', true);
						}
					}
					else if (!noteDef.mustPress)
					{
						if (FlxG.save.data.cpuStrums)
						{
							if ((!noteDef.isSustainNote && !noteDef.isParent) || noteDef.isSustainEnd)
							{
								spr.playAnim('static', true);
							}
						}
					}
				}
			}
			else
			{
				spr.playAnim('dirCon' + noteDef.connectedNote.originColor, true);

				spr.localAngle = noteDef.connectedNote.originAngle;
				spr.animation.finishCallback = function(name)
				{
					if (noteDef.mustPress && PlayStateChangeables.botPlay)
					{
						if ((!noteDef.isSustainNote && !noteDef.isParent) || noteDef.isSustainEnd)
						{
							spr.playAnim('static', true);
							spr.localAngle = 0;
						}
					}
					else if (!noteDef.mustPress)
					{
						if (FlxG.save.data.cpuStrums)
						{
							if ((!noteDef.isSustainNote && !noteDef.isParent) || noteDef.isSustainEnd)
							{
								spr.playAnim('static', true);
								spr.localAngle = 0;
							}
						}
					}
				}
			}
		}
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		if (!paused)
		{
			var bpmRatio:Float = Conductor.bpm / 100;
			if (Math.abs(Conductor.songPosition * songMultiplier) > Math.abs(#if cpp instStream.time #else inst.time #end + (25 * bpmRatio))
				|| Math.abs(Conductor.songPosition * songMultiplier) < Math.abs(#if cpp instStream.time #else inst.time #end - (25 * bpmRatio)))
			{
				resyncVocals();
			}
		}

		/*if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				{
					Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				}
		}*/

		// INTERLOPE SCROLL SPEED PULSE EFFECT SHIT (TESTING PURPOSES) --Credits to Hazard
		// Also check out tutorial modchart.lua that has this same tween but better :3
		/*if (curStep % Math.floor(4 * songMultiplier) == 0)
			{
				var scrollSpeedShit:Float = scrollSpeed;
				scrollSpeed /= scrollSpeed;
				scrollTween = createTween(this, {scrollSpeed: scrollSpeedShit}, 0.25 / songMultiplier, {
					ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween)
					{
						scrollTween = null;
					}
				});
		}*/

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if (!endingSong && currentSection != null)
		{
			if (FlxG.save.data.characters)
			{
				if (allowedToHeadbang && curStep % 4 == 0)
				{
					if (gf != null)
						gf.dance();
				}

				if (curStep % 64 == 60 && SONG.songId == 'tutorial' && dad.curCharacter == 'gf' && curStep > 64 && curStep < 192)
				{
					#if cpp
					if (vocalsStream.volume != 0)
					{
						boyfriend.playAnim('hey', true);
						dad.playAnim('cheer', true);
					}
					else
					{
						dad.playAnim('sad', true);
						FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
					}
					#else
					if (vocals.volume != 0)
					{
						boyfriend.playAnim('hey', true);
						dad.playAnim('cheer', true);
					}
					else
					{
						dad.playAnim('sad', true);
						FlxG.sound.play(Paths.soundRandom('GF_', 1, 4, 'shared'), 0.3);
					}
					#end
				}
			}

			/*if (vocals.volume == 0 && !currentSection.mustHitSection)
				vocals.volume = 1; */
		}

		// HARDCODING FOR MILF ZOOMS!
		if (PlayState.SONG.songId == 'milf' && curStep >= 672 && curStep < 800 && camZooming)
		{
			if (curStep % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		if (curStep % 32 == 28 #if cpp && curStep != 316 #end && SONG.songId == 'bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}
		if ((curStep == 190 || curStep == 446) && SONG.songId == 'bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		#if !FEATURE_LUAMODCHART
		if (sourceModchart && PlayStateChangeables.modchart)
		{
			if (SONG.songId == 'tutorial')
			{
				if (curStep < 413)
				{
					if ((curStep % 8 == 4) && (curStep < 254 || curStep > 323))
					{
						receptorTween();
						elasticCamZoom();
						speedBounce();
					}
					else
					{
						if (curStep % 16 == 8 && (curStep >= 254 && curStep < 323))
						{
							receptorTween();
							elasticCamZoom();
							speedBounce();
						}
					}
				}
			}
		}
		#end

		if (!paused)
		{
			if (curStep % 4 == 0)
			{
				iconP1.setGraphicSize(Std.int(iconP1.width + 45 / songMultiplier));
				iconP2.setGraphicSize(Std.int(iconP2.width + 45 / songMultiplier));
				iconP1.updateHitbox();
				iconP2.updateHitbox();
			}
		}

		if (isStoryMode)
		{
			if (SONG.songId == 'eggnog' && curStep == 938)
			{
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;
				camStrums.visible = false;

				FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				createTimer(1.5, function(tmr)
				{
					endSong();
				});
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (currentSection != null && FlxG.save.data.characters)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.playerAltAnim);
			}
			else if (curBeat % idleBeat != 0)
			{
				if (boyfriend.isDancing && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (dad.isDancing && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(forcedToIdle, currentSection.CPUAltAnim);
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
	}

	override function sectionHit():Void
	{
		super.sectionHit();

		if (camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		#if FEATURE_LUAMODCHART
		if (currentSection != null)
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
		#end

		changeCameraFocus();
	}

	function changeCameraFocus()
	{
		try
		{
			if (!Stage.staticCam)
			{
				if (currentSection != null)
				{
					if (!currentSection.mustHitSection)
					{
						var offsetX = 0;
						var offsetY = 0;

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
						camFollow.set(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
						// camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoTurn', []);
						#end

						// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
						#if !FEATURE_LUAMODCHART
						if (SONG.songId == 'tutorial')
							tweenCamZoom(true);
						#end

						camFollow.x += dad.camFollow[0];
						camFollow.y += dad.camFollow[1];
					}

					if (currentSection.mustHitSection)
					{
						var offsetX = 0;
						var offsetY = 0;

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
						camFollow.set(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerOneTurn', []);
						#end
						#if !FEATURE_LUAMODCHART
						if (SONG.songId == 'tutorial')
							tweenCamZoom(false);
						#end

						switch (Stage.curStage)
						{
							case 'limo':
								camFollow.x = boyfriend.getMidpoint().x - 300;
							case 'mall':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'school' | 'schoolEvil':
								camFollow.x = boyfriend.getMidpoint().x - 300;
								camFollow.y = boyfriend.getMidpoint().y - 300;
						}

						camFollow.x += boyfriend.camFollow[0];
						camFollow.y += boyfriend.camFollow[1];
					}
				}
			}
		}
		catch (e)
		{
		}
	}

	public function updateSettings():Void
	{
		binds = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		scoreTxt.y = healthBarBG.y;
		if (FlxG.save.data.colour)
		{
			if (!PlayStateChangeables.opponentMode)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(boyfriend.barColor, dad.barColor);
		}
		else
		{
			if (!PlayStateChangeables.opponentMode)
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
			else
				healthBar.createFilledBar(0xFF66FF33, 0xFFFF0000);
		}
		healthBar.updateBar();

		if (!isStoryMode)
			PlayStateChangeables.botPlay = FlxG.save.data.botplay;

		iconP1.kill();
		iconP2.kill();
		healthBar.kill();
		healthBarBG.kill();
		remove(healthBar);
		remove(iconP1);
		remove(iconP2);
		remove(healthBarBG);

		judgementCounter.kill();
		remove(judgementCounter);

		if (FlxG.save.data.judgementCounter)
		{
			judgementCounter.revive();
			add(judgementCounter);
		}

		if (songStarted)
		{
			songName.kill();
			songPosBar.kill();
			bar.kill();
			remove(bar);
			remove(songName);
			remove(songPosBar);
			songName.visible = FlxG.save.data.songPosition;
			songPosBar.visible = FlxG.save.data.songPosition;
			bar.visible = FlxG.save.data.songPosition;
			if (FlxG.save.data.songPosition)
			{
				songName.revive();
				songPosBar.revive();
				bar.revive();
				add(songPosBar);
				add(songName);
				add(bar);
				songName.alpha = 1;
				songPosBar.alpha = 0.85;
				bar.alpha = 1;
			}
		}

		if (!isStoryMode)
		{
			botPlayState.kill();
			remove(botPlayState);
			if (PlayStateChangeables.botPlay)
			{
				usedBot = true;
				botPlayState.revive();
				add(botPlayState);
			}
		}

		if (FlxG.save.data.healthBar)
		{
			healthBarBG.revive();
			healthBar.revive();
			iconP1.revive();
			iconP2.revive();
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
			scoreTxt.y = healthBarBG.y + 47;
		}
	}

	public function changeScrollSpeed(mult:Float, time:Float, ease):Void
	{
		var newSpeed = FlxG.save.data.scrollSpeed * mult;
		if (time <= 0)
		{
			scrollSpeed = newSpeed;
		}
		else
		{
			scrollTween = createTween(this, {scrollSpeed: newSpeed}, time, {
				ease: ease,
				onUpdate: function(twn:FlxTween)
				{
					mult = scrollSpeed / FlxG.save.data.scrollSpeed;
					scrollMult = mult;
				},
				onComplete: function(twn:FlxTween)
				{
					scrollTween = null;
				}
			});
		}

		scrollMult = mult;
	}

	public var tankIntroEnd:Bool = false;

	function tankIntro()
	{
		dad.visible = false;
		precacheThing('DISTORTO', 'music', 'week7');
		var tankManEnd:Void->Void = function()
		{
			tankIntroEnd = true;
			var timeForStuff:Float = Conductor.crochet / 1000 * 5;
			createTween(FlxG.camera, {zoom: Stage.camZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();
			camStrums.visible = true;
			camHUD.visible = true;
			dad.visible = true;
			FlxG.sound.music.stop();

			var cutSceneStuff:Array<FlxSprite> = [Stage.swagBacks['tankman']];
			if (SONG.songId == 'stress')
			{
				cutSceneStuff.push(Stage.swagBacks['bfCutscene']);
				cutSceneStuff.push(Stage.swagBacks['gfCutscene']);
			}
			for (char in cutSceneStuff)
			{
				char.kill();
				remove(char);
				char.destroy();
			}
			Paths.clearUnusedMemory();
		}

		switch (SONG.songId)
		{
			case 'ugh':
				cancelAppearArrows();
				camHUD.visible = false;
				precacheThing('wellWellWell', 'sound', 'week7');
				precacheThing('killYou', 'sound', 'week7');
				precacheThing('bfBeep', 'sound', 'week7');
				var WellWellWell:FlxSound = new FlxSound().loadEmbedded(Paths.sound('wellWellWell', 'week7'));

				FlxG.sound.list.add(WellWellWell);

				FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'));
				FlxG.sound.music.fadeIn();
				Stage.swagBacks['tankman'].animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
				Stage.swagBacks['tankman'].animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
				Stage.swagBacks['tankman'].animation.play('wellWell', true);
				FlxG.camera.zoom *= 1.2;
				camFollow.x = 436.5;
				camFollow.y = 534.5;

				// Well well well, what do we got here?
				createTimer(0.1, function(tmr:FlxTimer)
				{
					WellWellWell.play(true);
				});

				// Move camera to BF
				createTimer(3, function(tmr:FlxTimer)
				{
					camFollow.x += 400;
					camFollow.y += 60;
					// Beep!
					createTimer(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP', true);
						FlxG.sound.play(Paths.sound('bfBeep'));
					});

					// Move camera to Tankman
					createTimer(3, function(tmr:FlxTimer)
					{
						camFollow.x = 436.5;
						camFollow.y = 534.5;
						boyfriend.dance();
						Stage.swagBacks['tankman'].animation.play('killYou', true);
						FlxG.sound.play(Paths.sound('killYou'));

						// We should just kill you but... what the hell, it's been a boring day... let's see what you've got!
						createTimer(6.1, function(tmr:FlxTimer)
						{
							tankManEnd();
						});
					});
				});

			case 'guns':
				precacheThing('tankSong2', 'sound', 'week7');
				FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0, false);
				FlxG.sound.music.fadeIn();

				var tightBars:FlxSound = new FlxSound().loadEmbedded(Paths.sound('tankSong2', 'week7'));
				FlxG.sound.list.add(tightBars);

				createTimer(0.01, function(tmr:FlxTimer)
				{
					tightBars.play(true);
				});

				createTimer(0.5, function(tmr:FlxTimer)
				{
					createTween(camStrums, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
					createTween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
							camStrums.visible = false;
							camStrums.alpha = 1;
							cancelAppearArrows();
						}
					});
				});

				Stage.swagBacks['tankman'].animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
				Stage.swagBacks['tankman'].animation.play('tightBars', true);
				boyfriend.animation.curAnim.finish();

				createTimer(1, function(tmr:FlxTimer)
				{
					camFollow.x = 436.5;
					camFollow.y = 534.5;
				});

				createTimer(4, function(tmr:FlxTimer)
				{
					camFollow.y -= 150;
					camFollow.x += 100;
				});
				createTimer(1, function(tmr:FlxTimer)
				{
					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2}, 3, {ease: FlxEase.quadInOut});

					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2 * 1.2}, 0.5, {ease: FlxEase.quadInOut, startDelay: 3});
					createTween(FlxG.camera, {zoom: Stage.camZoom * 1.2}, 1, {ease: FlxEase.quadInOut, startDelay: 3.5});
				});

				createTimer(4, function(tmr:FlxTimer)
				{
					if (gf != null)
					{
						gf.playAnim('sad', true);
						gf.animation.finishCallback = function(name:String)
						{
							gf.playAnim('sad', true);
						};
					}
				});

				createTimer(11.6, function(tmr:FlxTimer)
				{
					camFollow.x = 440;
					camFollow.y = 534.5;
					tankManEnd();

					if (gf != null)
					{
						gf.dance();
						gf.animation.finishCallback = null;
					}
				});

			case 'stress':
				precacheThing('stressCutscene', 'sound', 'week7');

				precacheThing('cutscenes/stress2', 'image', 'week7');

				createTimer(0.5, function(tmr:FlxTimer)
				{
					createTween(camStrums, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
					createTween(camHUD, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = false;
							camHUD.alpha = 1;
							camStrums.visible = false;
							camStrums.alpha = 1;
							cancelAppearArrows();
						}
					});
				});

				if (gf != null)
				{
					gf.alpha = 0.0001;
					boyfriend.alpha = 0.0001;
				}
				createTimer(1, function(tmr:FlxTimer)
				{
					camFollow.x = 436.5;
					camFollow.y = 534.5;
					createTween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
				});

				Stage.swagBacks['bfCutscene'].animation.finishCallback = function(name:String)
				{
					Stage.swagBacks['bfCutscene'].animation.play('idle');
				}

				Stage.swagBacks['dummyGf'].animation.finishCallback = function(name:String)
				{
					Stage.swagBacks['dummyGf'].animation.play('idle');
				}

				var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
				FlxG.sound.list.add(cutsceneSnd);

				Stage.swagBacks['tankman'].animation.addByPrefix('godEffingDamnIt', 'TANK TALK 3', 24, false);
				Stage.swagBacks['tankman'].animation.play('godEffingDamnIt', true);

				createTimer(0.01, function(tmr:FlxTimer) // Fixes sync????
				{
					cutsceneSnd.play(true);
				});

				createTimer(14.2, function(tmr:FlxTimer)
				{
					Stage.swagBacks['bfCutscene'].animation.finishCallback = null;
					Stage.swagBacks['dummyGf'].animation.finishCallback = null;
				});

				createTimer(15.2, function(tmr:FlxTimer)
				{
					createTween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
					createTween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
					createTimer(2.3, function(tmr:FlxTimer)
					{
						camFollow.x = 630;
						camFollow.y = 425;
						FlxG.camera.zoom = 0.9;
					});

					remove(Stage.swagBacks['dummyGf']);
					createTween(Stage.swagBacks['gfCutscene'], {alpha: 1}, 0.0000001);
					Stage.swagBacks['gfCutscene'].animation.play('dieBitch', true);
					Stage.swagBacks['gfCutscene'].animation.finishCallback = function(name:String)
					{
						if (name == 'dieBitch') // Next part
						{
							Stage.swagBacks['gfCutscene'].animation.play('getRektLmao', true);
							Stage.swagBacks['gfCutscene'].offset.set(224, 445);
						}
						else
						{
							remove(Stage.swagBacks['gfCutscene']);

							createTween(Stage.swagBacks['picoCutscene'], {alpha: 1}, 0.0000001);
							Stage.swagBacks['picoCutscene'].animation.play('anim', true);

							boyfriend.alpha = 1;
							remove(Stage.swagBacks['bfCutscene']);
							boyfriend.playAnim('bfCatch', true);
							boyfriend.animation.finishCallback = function(name:String)
							{
								if (name != 'idle')
								{
									boyfriend.playAnim('idle', true);
									boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
								}
							};

							Stage.swagBacks['picoCutscene'].animation.finishCallback = function(name:String)
							{
								remove(Stage.swagBacks['picoCutscene']);
								if (gf != null)
									gf.alpha = 1;
								Stage.swagBacks['picoCutscene'].animation.finishCallback = null;
							};
							Stage.swagBacks['gfCutscene'].animation.finishCallback = null;
						}
					};
				});

				createTimer(19.5, function(tmr:FlxTimer)
				{
					Stage.swagBacks['tankman'].frames = Paths.getSparrowAtlas('cutscenes/stress2', 'week7');
					Stage.swagBacks['tankman'].animation.addByPrefix('lookWhoItIs', 'TANK TALK 3', 24, false);
					Stage.swagBacks['tankman'].animation.play('lookWhoItIs', true);
					Stage.swagBacks['tankman'].x += 90;
					Stage.swagBacks['tankman'].y += 6;

					createTimer(0.5, function(tmr:FlxTimer)
					{
						camFollow.x = 436.5;
						camFollow.y = 534.5;
					});
				});

				createTimer(31.2, function(tmr:FlxTimer)
				{
					boyfriend.playAnim('singUPmiss', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if (name == 'singUPmiss')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); // Instantly goes to last frame
						}
					};

					snapCamFollowToPos(1100, 625);
					FlxG.camera.zoom = 1.3;

					createTimer(1, function(tmr:FlxTimer)
					{
						FlxG.camera.zoom = Stage.camZoom;
						snapCamFollowToPos(440, 534.5);
					});
				});
				createTimer(35.5, function(tmr:FlxTimer)
				{
					tankManEnd();
					boyfriend.animation.finishCallback = null;
				});
		}
	}

	// LUA MODCHART TO SOURCE FOR HTML5 TUTORIAL MODCHART :)
	#if !cpp
	function elasticCamZoom()
	{
		var camGroup:Array<FlxCamera> = [camHUD, camNotes, camSustains, camStrums];
		for (camShit in camGroup)
		{
			camShit.zoom += 0.06;
			createTween(camShit, {zoom: camShit.zoom - 0.06}, 0.5 / songMultiplier, {
				ease: FlxEase.elasticOut
			});
		}

		FlxG.camera.zoom += 0.06;

		createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.06, 0.5 / songMultiplier, {ease: FlxEase.elasticOut}, updateCamZoom.bind(FlxG.camera));
	}

	function receptorTween()
	{
		for (i in 0...strumLineNotes.length)
		{
			createTween(strumLineNotes.members[i], {modAngle: strumLineNotes.members[i].modAngle + 360}, 0.5 / songMultiplier,
				{ease: FlxEase.smootherStepInOut});
		}
	}

	function updateCamZoom(camGame:FlxCamera, upZoom:Float)
	{
		camGame.zoom = upZoom;
	}

	function speedBounce()
	{
		var scrollSpeedShit:Float = scrollSpeed;
		scrollSpeed /= scrollSpeed;
		changeScrollSpeed(scrollSpeedShit, 0.35 / songMultiplier, FlxEase.sineOut);
	}

	var isTweeningThisShit:Bool = false;

	function tweenCamZoom(isDad:Bool)
	{
		if (isDad)
			createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom + 0.3, (Conductor.stepCrochet * 4 / 1000) / songMultiplier, {
				ease: FlxEase.smootherStepInOut,
			}, updateCamZoom.bind(FlxG.camera));
		else
			createTweenNum(FlxG.camera.zoom, FlxG.camera.zoom - 0.3, (Conductor.stepCrochet * 4 / 1000) / songMultiplier, {
				ease: FlxEase.smootherStepInOut,
			}, updateCamZoom.bind(FlxG.camera));
	}
	#end

	// https://github.com/ShadowMario/FNF-PsychEngine/pull/9015
	// Seems like a good pull request. Credits: Raltyro.
	private function cachePopUpScore()
	{
		var styleShit = SONGStyle.replaceHUDAssets ? SONG.songStyle : 'default';

		for (precaching in Ratings.timingWindows)
			Paths.image('hud/$styleShit/${precaching.name.toLowerCase()}', 'shared');

		Paths.image('hud/$styleShit/combo', 'shared');

		for (i in 0...10)
		{
			Paths.image('hud/$styleShit/num$i', 'shared');
		}
	}

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);

		var styleShit = SONGStyle.replaceHUDAssets ? SONG.songStyle : 'default';
		var soundStyle = SONGStyle.replaceSounds ? SONG.songStyle : 'default';
		var introAlts = ['hud/$styleShit/ready', 'hud/$styleShit/set', 'hud/$styleShit/go'];

		for (asset in introAlts)
			Paths.image(asset, 'shared');

		var things:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];
		for (precaching in things)
			Paths.sound('$soundStyle/$precaching');
	}

	function startVideo(name:String):Void
	{
		var fileName = OpenFlAssets.getPath(Paths.video(name));
		try
		{
			Debug.logTrace('Playing video cutscene. Poggers');
			inCinematic = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			#if (FEATURE_MP4VIDEOS && !html5)
			var daVid:VideoHandler = new VideoHandler();
			daVid.onEndReached.add(function()
			{
				remove(bg);
				daVid.dispose();
				startAndEnd();
			});
			daVid.play(fileName);
			#else
			var netStream = new FlxVideo();
			add(netStream);
			netStream.playVideo(fileName);
			netStream.finishCallback = function()
			{
				remove(netStream);
				remove(bg);
				startAndEnd();
			}
			#end
			return;
		}
		catch (e)
		{
			FlxG.log.warn("Video not found: " + fileName);
			startAndEnd();
		}
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	private function cleanPlayObjects()
	{
		timerManager.clear();

		tweenManager.clear();

		for (note in notes)
		{
			if (note != null)
			{
				@:privateAccess
				note.nullSafety = false;
			}
		}

		chartEventHandler.destroy();
		chartEventHandler = null;

		Stage.destroy();
		Stage = null;
	}

	override function destroy()
	{
		transSubstate.nextCamera = mainCam;
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		#if desktop
		Application.current.window.title = Main.appName;

		if (instStream != null)
			instStream.stop();

		if (vocalsStream != null)
			vocalsStream.pause();
		#end

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}

		noteskinSprite = null;

		LuaStorage.ListOfCameras.resize(0);

		LuaStorage.objectProperties.clear();

		LuaStorage.objects.clear();
		#end

		cleanPlayObjects();

		instance = null;

		super.destroy();
	}

	// Precache List for some stuff (Like frames, sounds and that kinda of shit)

	public static function precacheThing(target:String, type:String, ?library:String = null)
	{
		switch (type)
		{
			case 'image':
				Paths.image(target, library);
			case 'sound':
				Paths.sound(target, library);
			case 'music':
				Paths.music(target, library);
		}
	}

	function spawnNoteSplashOnStrum(noteDef:NoteDef)
	{
		if (FlxG.save.data.noteSplashes && noteDef != null)
		{
			var strum:StaticArrow = playerStrums.members[noteDef.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, noteDef);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, ?noteDef:NoteDef = null)
	{
		if (noteDef == null)
			return;

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.noteType = noteDef.noteType;
		splash.noteData = noteDef.noteData;
		splash.setupNoteSplash(x, y);
		grpNoteSplashes.add(splash);
	}

	private function destroyNote(daNote:NoteSpr)
	{
		if (daNote == null)
			return;

		daNote.active = false;
		daNote.visible = false;
		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();
	}

	var chartEventIndex:Int = 0;
	var chartEventHandler:ChartEventHandler;

	private function addSongEvents()
	{
		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (event in SONG.events)
		{
			switch (event.name)
			{
				case 'changeBPM':
					{
						var beat:Float = event.beat;
						var endBeat:Float = Math.POSITIVE_INFINITY;

						var bpm = event.args[0] * songMultiplier;
						TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = ((data.endBeat - (data.startBeat)) / (data.bpm / 60));
							var step = ((60 / (data.bpm)) * 1000) / 4;
							TimingStruct.AllTimings[currentIndex].startStep = Math.floor((((data.endBeat / (data.bpm / 60)) * 1000) / step));
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
					}
				case 'changeChar':
					var group:String = event.args[0];
					var char:String = event.args[1];
					switch (group)
					{
						// gf
						case "speaker":
							var newGF = new Character(0, 0, char);
							if (newGF == null)
							{
								Debug.logWarn('${newGF} is null. Skipping.');
								continue;
							}
							newGF.alpha = 0.0001;
							gfMap.set(char, newGF);
							gfGroup.add(newGF);

						// dad
						case "opponent":
							var newDAD:Character;
							newDAD = new Character(100, 100, char);
							if (newDAD == null)
							{
								Debug.logWarn('${newDAD} is null. Skipping.');
								continue;
							}
							newDAD.alpha = 0.0001;
							dadMap.set(char, newDAD);
							dadGroup.add(newDAD);

						// boyfriend
						case "player":
							var newBF:Boyfriend;
							newBF = new Boyfriend(100, 100, char);
							if (newBF == null)
							{
								Debug.logWarn('${newBF} is null. Skipping.');
								continue;
							}
							newBF.alpha = 0.0001;
							boyfriendMap.set(char, newBF);
							boyfriendGroup.add(newBF);
					}
			}

			chartEventHandler.checkChartEvent(event);
		}

		// sort events by beat
		if (SONG.events != null)
		{
			SONG.events.sort(function(a, b)
			{
				if (a.beat < b.beat)
					return -1
				else if (a.beat > b.beat)
					return 1;
				else
					return 0;
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	private function newSection(lengthInSteps:Int = 16, mustHitSection:Bool = false, CPUAltAnim:Bool = true, playerAltAnim:Bool = true):SwagSection
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: SONG.bpm,
			changeBPM: false,
			mustHitSection: mustHitSection,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			CPUAltAnim: CPUAltAnim,
			playerAltAnim: playerAltAnim
		};

		return sec;
	}

	public var currentShaders:Array<FlxRuntimeShader> = [];

	private function setShaders(obj:Dynamic, shaders:Array<FNFShader>)
	{
		#if (!flash && sys)
		var filters = [];

		for (shader in shaders)
		{
			filters.push(new ShaderFilter(shader));

			if (!Std.isOfType(obj, FlxCamera))
			{
				obj.shader = shader;

				return true;
			}

			currentShaders.push(shader);
		}
		if (Std.isOfType(obj, FlxCamera))
			obj.setFilters(filters);

		return true;
		#end
	}

	private function removeShaders(obj:Dynamic)
	{
		#if (!flash && sys)
		var filters = [];

		for (shader in currentShaders)
		{
			currentShaders.remove(shader);
		}

		if (!Std.isOfType(obj, FlxCamera))
		{
			obj.shader = null;

			return true;
		}

		if (Std.isOfType(obj, FlxCamera))
			obj.setFilters(filters);

		return true;
		#end
	}

	private function checkforSections()
	{
		var totalBeats = TimingStruct.getBeatFromTime(#if cpp instStream.length / songMultiplier #else inst.length / songMultiplier #end);

		var lastSecBeat = TimingStruct.getBeatFromTime(SONG.notes[SONG.notes.length - 1].endTime);

		while (lastSecBeat < totalBeats)
		{
			Debug.logTrace('LastBeat: $lastSecBeat | totalBeats: $totalBeats ');
			SONG.notes.push(newSection(SONG.notes[SONG.notes.length - 1].lengthInSteps, true, false, false));
			recalculateAllSectionTimes(SONG.notes.length - 1);
			lastSecBeat = TimingStruct.getBeatFromTime(SONG.notes[SONG.notes.length - 1].endTime);
		}
	}

	function set_songMultiplier(value:Float):Float
	{
		rate = value;
		FlxAnimationController.globalSpeed = value;
		#if cpp
		instStream.speed = value;

		if (vocalsStream != null)
			vocalsStream.speed = value;
		#elseif html5
		if (inst.playing)
			@:privateAccess
		{
			#if lime_howlerjs
			#if (lime >= "8.0.0")
			inst._channel.__alSource.__backend.setPitch(value);
			if (vocals.playing)
				vocals._channel.__alSource.__backend.setPitch(value);
			#else
			inst._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(value);
			if (vocals.playing)
				vocals._channel.__alSource.__backend.parent.buffer.__srcHowl.rate(value);
			#end
			#end
		}
		#end

		return value;
	}

	public function changeChar(target:String, newChar:String)
	{
		switch (target)
		{
			case "speaker":
				if (gf != null)
				{
					var lastAlpha:Float = gf.alpha;
					gf.alpha = 0.00001;
					gf = gfMap.get(newChar);
					gf.alpha = lastAlpha;
				}
			case "opponent":
				var lastAlpha:Float = dad.alpha;
				dad.alpha = 0.00001;
				dad = dadMap.get(newChar);
				dad.alpha = lastAlpha;

			case "player":
				var lastAlpha:Float = boyfriend.alpha;
				boyfriend.alpha = 0.00001;
				boyfriend = boyfriendMap.get(newChar);

				boyfriend.alpha = lastAlpha;
		}

		iconP1.changeIcon(boyfriend.healthicon);

		iconP2.changeIcon(dad.healthicon);

		var positions = Stage.positions[Stage.curStage];
		if (positions != null)
		{
			for (char => pos in positions)
				for (person in [boyfriend, gf, dad])
					if (person != null)
						if (person.curCharacter == char)
							person.setPosition(pos[0], pos[1]);
		}

		#if FEATURE_DISCORD
		iconRPC = newChar;
		iconRPCBefore = iconRPC;
		#end

		if (FlxG.save.data.colour)
		{
			if (!PlayStateChangeables.opponentMode)
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
			else
				healthBar.createFilledBar(boyfriend.barColor, dad.barColor);
		}
		else
		{
			if (!PlayStateChangeables.opponentMode)
				healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
			else
				healthBar.createFilledBar(0xFF66FF33, 0xFFFF0000);
		}
		healthBar.updateBar();

		songPosBar.createGradientBar([FlxColor.BLACK], [boyfriend.barColor, dad.barColor]);
		songPosBar.updateBar();
	}
} // u looked :O -ides

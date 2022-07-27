package;

import openfl.Lib;
import flixel.FlxG;

class Data
{
	public static var noteskinArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/noteSkinList'));
	public static var hitsoundArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/hitSoundList'));
	public static var freeplaySongArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

	public static function resetBinds():Void
	{
		FlxG.save.data.upBind = "W";
		FlxG.save.data.downBind = "S";
		FlxG.save.data.leftBind = "A";
		FlxG.save.data.rightBind = "D";
		FlxG.save.data.pauseBind = "ENTER";
		FlxG.save.data.resetBind = "R";
		FlxG.save.data.muteBind = "ZERO";
		FlxG.save.data.volUpBind = "PLUS";
		FlxG.save.data.volDownBind = "MINUS";
		FlxG.save.data.fullscreenBind = "F";

		FlxG.sound.muteKeys = ["ZERO", "NUMPADZERO"];
		FlxG.sound.volumeDownKeys = ["MINUS", "NUMPADMINUS"];
		FlxG.sound.volumeUpKeys = ["PLUS", "NUMPADPLUS"];

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function reloadSaves()
	{
		if (FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 7;

		if (FlxG.save.data.newInput == null)
			FlxG.save.data.newInput = true;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.hitSound == null)
			FlxG.save.data.hitSound = 0;

		if (FlxG.save.data.hitVolume == null)
			FlxG.save.data.hitVolume = 0.5;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;

		if (FlxG.save.data.dfjk == null)
			FlxG.save.data.dfjk = false;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = true;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = true;

		if (FlxG.save.data.memoryDisplay == null)
			FlxG.save.data.memoryDisplay = true;

		if (FlxG.save.data.lerpScore == null)
			FlxG.save.data.lerpScore = false;

		if (FlxG.save.data.fpsBorder == null)
			FlxG.save.data.fpsBorder = false;

		if (FlxG.save.data.rotateSprites == null)
			FlxG.save.data.rotateSprites = true;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 60;

		if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 60; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = true;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.colour == null)
			FlxG.save.data.colour = true;

		if (FlxG.save.data.stepMania == null)
			FlxG.save.data.stepMania = false;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;

		if (FlxG.save.data.instantRespawn == null)
			FlxG.save.data.instantRespawn = false;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = true;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;

		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = 0;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.inputShow == null)
			FlxG.save.data.inputShow = false;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;

		if (FlxG.save.data.discordMode == null)
			FlxG.save.data.discordMode = 2;

		if (FlxG.save.data.roundAccuracy == null)
			FlxG.save.data.roundAccuracy = false;

		FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = false;

		if (FlxG.save.data.editorBG == null)
			FlxG.save.data.editor = false;

		if (FlxG.save.data.zoom == null)
			FlxG.save.data.zoom = 1;

		if (FlxG.save.data.judgementCounter == null)
			FlxG.save.data.judgementCounter = true;

		if (FlxG.save.data.laneUnderlay == null)
			FlxG.save.data.laneUnderlay = true;

		if (FlxG.save.data.healthBar == null)
			FlxG.save.data.healthBar = true;

		if (FlxG.save.data.laneTransparency == null)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.shitMs == null)
			FlxG.save.data.shitMs = 160.0;

		if (FlxG.save.data.badMs == null)
			FlxG.save.data.badMs = 135.0;

		if (FlxG.save.data.goodMs == null)
			FlxG.save.data.goodMs = 90.0;

		if (FlxG.save.data.sickMs == null)
			FlxG.save.data.sickMs = 45.0;

		if (FlxG.save.data.background == null)
			FlxG.save.data.background = true;

		if (FlxG.save.data.noteskin == null)
			FlxG.save.data.noteskin = 0;

		if (FlxG.save.data.hgain == null)
			FlxG.save.data.hgain = 1;

		if (FlxG.save.data.hloss == null)
			FlxG.save.data.hloss = 1;

		if (FlxG.save.data.hdrain == null)
			FlxG.save.data.hdrain = false;

		if (FlxG.save.data.sustains == null)
			FlxG.save.data.sustains = true;

		if (FlxG.save.data.noMisses == null)
			FlxG.save.data.noMisses = false;

		if (FlxG.save.data.modcharts == null)
			FlxG.save.data.modcharts = true;

		if (FlxG.save.data.practice == null)
			FlxG.save.data.practice = false;

		if (FlxG.save.data.opponent == null)
			FlxG.save.data.opponent = false;

		if (FlxG.save.data.mirror == null)
			FlxG.save.data.mirror = false;

		if (FlxG.save.data.noteSplashes == null)
			FlxG.save.data.noteSplashes = false;

		if (FlxG.save.data.strumHit == null)
			FlxG.save.data.strumHit = true;

		if (FlxG.save.data.showCombo == null)
			FlxG.save.data.showCombo = true;

		if (FlxG.save.data.showComboNum == null)
			FlxG.save.data.showComboNum = true;

		if (FlxG.save.data.showMs == null)
			FlxG.save.data.showMs = true;

		// Gonna make this an option on another PR
		if (FlxG.save.data.overrideNoteskins == null)
			FlxG.save.data.overrideNoteskins = false;

		if (FlxG.save.data.gpuRender == null)
		{
			#if (html5 || mobile)
			FlxG.save.data.gpuRender = false;
			#else
			FlxG.save.data.gpuRender = true;
			#end
		}

		if (FlxG.save.data.volume == null)
			FlxG.save.data.volume = 1;

		if (FlxG.save.data.mute == null)
			FlxG.save.data.mute = false;

		if (FlxG.save.data.upBind == null)
			FlxG.save.data.upBind = "W";

		if (FlxG.save.data.downBind == null)
			FlxG.save.data.downBind = "S";

		if (FlxG.save.data.leftBind == null)
			FlxG.save.data.leftBind = "A";

		if (FlxG.save.data.rightBind == null)
			FlxG.save.data.rightBind = "D";

		if (FlxG.save.data.pauseBind == null)
			FlxG.save.data.pauseBind = "ENTER";

		if (FlxG.save.data.resetBind == null)
			FlxG.save.data.resetBind = "R";

		// VOLUME CONTROLS !!!!
		if (FlxG.save.data.muteBind == null)
			FlxG.save.data.muteBind = "ZERO";

		if (FlxG.save.data.volumeUpKeys == null)
			FlxG.save.data.volumeUpKeys = ["PLUS"];

		if (FlxG.save.data.volumeDownKeys == null)
			FlxG.save.data.volumeDownKeys = ["MINUS"];

		if (FlxG.save.data.fullscreenBind == null)
			FlxG.save.data.fullscreenBind = "F";

		if (FlxG.save.data.volDownBind == null)
			FlxG.save.data.volDownBind = "NUMPADMINUS";

		if (FlxG.save.data.volUpBind == null)
			FlxG.save.data.volUpBind = "NUMPADPLUS";

		FlxG.sound.muteKeys = [FlxKey.fromString(Std.string(FlxG.save.data.muteBind))];
		FlxG.sound.volumeDownKeys = [FlxKey.fromString(Std.string(FlxG.save.data.volDownBind))];
		FlxG.sound.volumeUpKeys = [FlxKey.fromString(Std.string(FlxG.save.data.volUpBind))];

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();

		FlxG.save.data.watermarks = FlxG.save.data.watermark;

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}

	public static function resetModifiers():Void
	{
		FlxG.save.data.hgain = 1;
		FlxG.save.data.hloss = 1;
		FlxG.save.data.hdrain = false;
		FlxG.save.data.sustains = true;
		FlxG.save.data.noMisses = false;
		FlxG.save.data.modcharts = true;
		FlxG.save.data.practice = false;
		FlxG.save.data.opponent = false;
		FlxG.save.data.mirror = false;
	}
}

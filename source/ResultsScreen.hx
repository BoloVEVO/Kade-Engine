package;

import Modifiers.Modifier;
import haxe.Exception;
#if FEATURE_STEPMANIA
import smTools.SMFile;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

class ResultsScreen extends FlxSubState
{
	public var background:FlxSprite;
	public var text:FlxText;

	public var anotherBackground:FlxSprite;
	public var graph:HitGraph;
	public var graphSprite:OFLSprite;

	public var comboText:FlxText;
	public var contText:FlxText;
	public var settingsText:FlxText;

	public var songText:FlxText;
	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;

	public var modifiers:String;

	public var activeMods:FlxText;

	public var superMegaConditionShit:Bool;

	override function create()
	{
		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		if (!PlayState.inResults)
		{
			music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			music.volume = 0;
			music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
			FlxG.sound.list.add(music);
		}

		// I was gonna use Arrays to do this but I'm dumb. So, I had to chose the mortal way XP
		if (!PlayState.isStoryMode)
		{
			modifiers = 'Active Modifiers:\n${(PlayStateChangeables.opponentMode ? '- Opponent Mode\n' : '')}${(PlayStateChangeables.mirrorMode ? '- Mirror Mode\n' : '')}${(PlayStateChangeables.practiceMode ? '- Practice Mode\n' : '')}${(PlayStateChangeables.skillIssue ? '- No Misses mode\n' : '')}${(!PlayStateChangeables.holds ? '- Hold Notes OFF\n' : '')}${(!PlayStateChangeables.modchart #if FEATURE_LUAMODCHART && FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart')) #else && PlayState.instance.sourceModchart #end ? '- Song modchart OFF\n' : '')}${(PlayStateChangeables.healthDrain ? '- Health Drain ON\n' : '')}${(HelperFunctions.truncateFloat(PlayStateChangeables.healthGain,2) != 1 ? '- HP Gain ${HelperFunctions.truncateFloat(PlayStateChangeables.healthGain, 2)}x\n': '')}${(HelperFunctions.truncateFloat(PlayStateChangeables.healthLoss,2) != 1 ? '- HP Loss ${HelperFunctions.truncateFloat(PlayStateChangeables.healthLoss, 2)}x\n':'')}';
			if (modifiers == 'Active Modifiers:\n')
				modifiers = 'Active Modifiers: None';
			activeMods = new FlxText(FlxG.width - 500, FlxG.height - 450, FlxG.width, modifiers);
			activeMods.size = 24;
			activeMods.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			activeMods.scrollFactor.set();
			add(activeMods);
		}

		background.alpha = 0;

		text = new FlxText(20, -55, 0, "Song Cleared!");
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		if (!PlayState.isStoryMode)
		{
			songText = new FlxText(20, -65, FlxG.width,
				'Played on ${PlayState.SONG.songName} - ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
			songText.size = 34;
			songText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			songText.color = FlxColor.WHITE;
			songText.scrollFactor.set();
			add(songText);
		}

		var score = PlayState.instance.songScore;
		var acc = PlayState.instance.accuracy;
		if (PlayState.isStoryMode)
		{
			acc = PlayState.campaignAccuracy;
			score = PlayState.campaignScore;
			text.text = 'Week Cleared on ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}!';
		}

		var sicks = PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.sicks;
		var goods = PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.goods;
		var bads = PlayState.isStoryMode ? PlayState.campaignBads : PlayState.bads;
		var shits = PlayState.isStoryMode ? PlayState.campaignShits : PlayState.shits;

		comboText = new FlxText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: $score\n${(PlayState.isStoryMode ? 'Average Accuracy' : 'Accuracy')}: ${HelperFunctions.truncateFloat(acc, 2)}% ( ${(FlxG.save.data.accuracyMod == 0 ? 'Accurate' : 'Complex')} )\n\n${Ratings.GenerateComboRank(PlayState.instance.accuracy)} ${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}\nRate: ${HelperFunctions.truncateFloat(PlayState.songMultiplier, 2)}x\n\n${!PlayState.loadRep ? "\nF1 - Replay song" : ""}
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxText(FlxG.width - 525, FlxG.height + 50, 0, 'Click or Press ${KeyBinds.gamepad ? 'A' : 'ENTER'} to continue.');
		#if mobile
		contText.text = "Touch to continue";
		#end
		contText.size = 24;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		anotherBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		graph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		graph.alpha = 0;

		graphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, graph);

		graphSprite.scrollFactor.set();
		graphSprite.alpha = 0;

		add(graphSprite);

		var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods, 1);
		var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads, 1);

		if (sicks == Math.POSITIVE_INFINITY)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY)
			goods = 0;

		var mean:Float = 0;

		for (i in 0...PlayState.instance.saveNotes.length)
		{
			// 0 = time
			// 1 = length
			// 2 = type
			// 3 = diff
			var obj = PlayState.instance.saveNotes[i];
			// judgement
			var obj2 = PlayState.instance.saveJudge[i];

			var obj3 = obj[0];

			var diff = obj[3];
			var judge = obj2;
			if (diff != (Ratings.timingWindows[0] * Math.floor((10 / 60) * 1000) / Ratings.timingWindows[0]))
				mean += diff;
			if (obj[1] != -1)
				graph.addToHistory(diff / PlayState.songMultiplier, judge, obj3 / PlayState.songMultiplier);
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 0;

		graph.update();

		superMegaConditionShit = Ratings.timingWindows[3] == 45
			&& Ratings.timingWindows[2] == 90
			&& Ratings.timingWindows[1] == 135
			&& Ratings.timingWindows[0] == 160
			&& (!PlayStateChangeables.botPlay && !PlayState.usedBot && !FlxG.save.data.botplay)
			&& !FlxG.save.data.practice
			&& PlayStateChangeables.holds
			&& !PlayState.wentToChartEditor
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthGain, 2) <= 1
			&& HelperFunctions.truncateFloat(PlayStateChangeables.healthLoss, 2) >= 1;

		if (PlayState.SONG.validScore && superMegaConditionShit)
		{
			Highscore.saveScore(PlayState.SONG.songId, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty, PlayState.songMultiplier);
			Highscore.saveCombo(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty,
				PlayState.songMultiplier);
			Highscore.saveAcc(PlayState.SONG.songId, HelperFunctions.truncateFloat(PlayState.instance.accuracy, 2), PlayState.storyDifficulty,
				PlayState.songMultiplier);
			Highscore.saveLetter(PlayState.SONG.songId, Ratings.GenerateLetterRank(PlayState.instance.accuracy), PlayState.storyDifficulty,
				PlayState.songMultiplier);
		}

		mean = HelperFunctions.truncateFloat(mean / PlayState.instance.saveNotes.length, 2);
		var acceptShit:String = (superMegaConditionShit && FlxG.save.data.accuracyMod == 0 ? '| Accepted' : '| Rejected');

		if (!PlayStateChangeables.modchart #if FEATURE_LUAMODCHART
			&& FileSystem.exists(Paths.lua('songs/${PlayState.SONG.songId}/modchart')) #else && PlayState.instance.sourceModchart #end)
			acceptShit = '| Rejected';

		#if debug
		acceptShit = '| Debug';
		#end

		if (PlayState.isStoryMode)
			acceptShit = '';

		settingsText = new FlxText(20, FlxG.height + 50, 0,
			'Mean: ${mean}ms (SICK:${Ratings.timingWindows[3]}ms,GOOD:${Ratings.timingWindows[2]}ms,BAD:${Ratings.timingWindows[1]}ms,SHIT:${Ratings.timingWindows[0]}ms) $acceptShit');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		if (!PlayState.isStoryMode)
		{
			FlxTween.tween(songText, {y: 65}, 0.5, {ease: FlxEase.expoInOut});
			FlxTween.tween(activeMods, {y: FlxG.height - 400}, 0.5, {ease: FlxEase.expoInOut});
		}
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});

		FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				graph.alpha = FlxMath.lerp(0, 1, tween.percent);
				graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		if (music != null)
			if (music.volume < 0.5)
				music.volume += 0.01 * elapsed;

		// keybinds

		if ((PlayerSettings.player1.controls.ACCEPT && !FlxG.keys.pressed.ALT) || FlxG.mouse.pressed)
		{
			if (music != null)
				music.fadeOut(0.3);

			PlayState.loadRep = false;
			PlayState.rep = null;

			if (PlayState.isStoryMode)
			{
				FlxG.sound.playMusic(Paths.music(FlxG.save.data.watermark ? "ke_freakyMenu" : "freakyMenu"));
				Conductor.changeBPM(102);
				MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				Conductor.changeBPM(102);
				MusicBeatState.switchState(new FreeplayState());
			}
		}

		if (FlxG.keys.justPressed.F1 && !PlayState.loadRep)
		{
			PlayState.rep = null;

			PlayState.loadRep = false;

			if (music != null)
				music.fadeOut(0.3);

			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = PlayState.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		super.update(elapsed);
	}
}

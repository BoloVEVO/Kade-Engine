package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import openfl.Lib;
import flixel.addons.ui.FlxUI;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIState;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;

	public static var switchingState:Bool = false;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var initSave:Bool = false;

	private var assets:Array<FlxBasic> = [];

	override function destroy()
	{
		clean();

		/*Application.current.window.onFocusIn.remove(onWindowFocusOut);
			Application.current.window.onFocusIn.remove(onWindowFocusIn); */

		super.destroy();
	}

	public function destroyObject(Object:Dynamic):Void
	{
		if (Std.isOfType(Object, FlxSprite))
		{
			var spr:FlxSprite = cast(Object, FlxSprite);
			spr.kill();
			remove(spr, true);
			spr.destroy();
			spr = null;
		}
		else if (Std.isOfType(Object, FlxTypedGroup))
		{
			var grp:FlxTypedGroup<Dynamic> = cast(Object, FlxTypedGroup<Dynamic>);
			for (ObjectGroup in grp.members)
			{
				if (Std.isOfType(ObjectGroup, FlxSprite))
				{
					var spr:FlxSprite = cast(ObjectGroup, FlxSprite);
					spr.kill();
					remove(spr, true);
					spr.destroy();
					spr = null;
				}
			}
		}
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Std.isOfType(Object, FlxUI))
			return null;

		if (Std.isOfType(Object, FlxSprite))
			var spr:FlxSprite = cast(Object, FlxSprite);

		// Debug.logTrace(Object);
		#if FEATURE_MULTITHREADING
		MasterObjectLoader.addObject(Object);
		#else
		assets.push(Object);
		#end
		var result = super.add(Object);
		return result;
	}

	override function remove(Object:FlxBasic, Splice:Bool = false):FlxBasic
	{
		#if FEATURE_MULTITHREADING
		MasterObjectLoader.removeObject(Object);
		#end
		var result = super.remove(Object, Splice);
		return result;
	}

	public function clean()
	{
		#if FEATURE_MULTITHREADING
		for (i in MasterObjectLoader.Objects)
		{
			destroyObject(i);
		}
		#else
		for (i in assets)
		{
			remove(i);
		}
		#end
	}

	override function create()
	{
		if (initSave)
		{
			if (FlxG.save.data.laneTransparency < 0)
				FlxG.save.data.laneTransparency = 0;

			if (FlxG.save.data.laneTransparency > 1)
				FlxG.save.data.laneTransparency = 1;
		}

		/*Application.current.window.onFocusIn.add(onWindowFocusIn);
			Application.current.window.onFocusOut.add(onWindowFocusOut); */
		// TimingStruct.clearTimings();

		KeyBinds.keyCheck();

		if (transIn != null)
			trace('reg ' + transIn.region);

		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		super.create();

		if (!skip)
		{
			openSubState(new PsychTransition(0.85, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		Paths.clearUnusedMemory();

		super.create();
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		/*var nextStep:Int = updateCurStep();

			if (nextStep >= 0)
			{
				if (nextStep > curStep)
				{
					for (i in curStep...nextStep)
					{
						curStep++;
						updateBeat();
						stepHit();
					}
				}
				else if (nextStep < curStep)
				{
					//Song reset?
					curStep = nextStep;
					updateBeat();
					stepHit();
				}
		}*/

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			var data = null;

			data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

			if (data != null)
			{
				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((Conductor.songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition) - startInMS) / step);
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (ste < curStep)
					{
						trace("reset steps for some reason?? at " + Conductor.songPosition);
						// Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
					}
				}

				Conductor.crochet = ((60 / data.bpm) * 1000) / PlayState.songMultiplier;
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor((Conductor.songPosition) / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (nextStep < curStep)
					{
						// Song reset?
						trace("(no bpm change) reset steps for some reason?? at " + Conductor.songPosition);
						curStep = nextStep;
						updateBeat();
						stepHit();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000) / PlayState.songMultiplier;
			}
		}

		// (cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		super.update(elapsed);
	}

	// ALL CREDITS TO SHADOWMARIO
	public static function switchState(nextState:FlxState)
	{
		MusicBeatState.switchingState = true;
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new PsychTransition(0.75, false));
			if (nextState == FlxG.state)
			{
				PsychTransition.finishCallback = function()
				{
					MusicBeatState.switchingState = false;
					FlxG.resetState();
				};
				// trace('resetted');
			}
			else
			{
				PsychTransition.finishCallback = function()
				{
					MusicBeatState.switchingState = false;
					FlxG.switchState(nextState);
				};
				// trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}
	/*function onWindowFocusOut():Void
		{
			if (PlayState.inDaPlay)
			{
				if (PlayState.instance.vocals != null)
					PlayState.instance.vocals.pause();
				if (FlxG.sound.music != null)
					FlxG.sound.music.pause();
				if (!PlayState.instance.paused && !PlayState.instance.endingSong && PlayState.instance.songStarted)
				{
					Debug.logTrace("Lost Focus");
					PlayState.instance.openSubState(new PauseSubState());
					PlayState.boyfriend.stunned = true;

					PlayState.instance.persistentUpdate = false;
					PlayState.instance.persistentDraw = true;
					PlayState.instance.paused = true;
				}
			}
		}

		function onWindowFocusIn():Void
		{
			Debug.logTrace("IM BACK!!!");
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
			if (PlayState.inDaPlay)
			{
				if (PlayState.boyfriend.stunned)
					PlayState.boyfriend.stunned = false;
			}
	}*/
}

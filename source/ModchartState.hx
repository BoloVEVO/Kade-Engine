// this file is for modchart things, this is to declutter playstate.hx
// Lua
#if FEATURE_LUAMODCHART
import LuaClass.LuaGame;
import LuaClass.LuaWindow;
import LuaClass.LuaSprite;
import LuaClass.LuaCamera;
import LuaClass.LuaReceptor;
import LuaClass.LuaNote;
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_FILESYSTEM
import sys.io.File;
#end
import openfl.display3D.textures.VideoTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import lime.app.Application;
import flixel.FlxSprite;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.Lib;
import Shaders;

using StringTools;

class ModchartState
{
	// public static var shaders:Array<LuaShader> = null;
	public static var lua:State = null;

	public static var shownNotes:Array<LuaNote> = [];

	function callLua(func_name:String, args:Array<Dynamic>, ?type:String):Dynamic
	{
		var result:Any = null;

		Lua.getglobal(lua, func_name);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);
		var p = Lua.tostring(lua, result);
		var e = getLuaErrorMessage(lua);

		Lua.tostring(lua, -1);

		if (e != null)
		{
			if (e != "attempt to call a nil value")
			{
				trace(StringTools.replace(e, "c++", "haxe function"));
			}
		}
		if (result == null)
		{
			return null;
		}
		else
		{
			return convert(result, type);
		}
	}

	static function toLua(l:State, val:Any):Bool
	{
		switch (Type.typeof(val))
		{
			case Type.ValueType.TNull:
				Lua.pushnil(l);
			case Type.ValueType.TBool:
				Lua.pushboolean(l, val);
			case Type.ValueType.TInt:
				Lua.pushinteger(l, cast(val, Int));
			case Type.ValueType.TFloat:
				Lua.pushnumber(l, val);
			case Type.ValueType.TClass(String):
				Lua.pushstring(l, cast(val, String));
			case Type.ValueType.TClass(Array):
				Convert.arrayToLua(l, val);
			case Type.ValueType.TObject:
				objectToLua(l, val);
			default:
				trace("haxe value not supported - " + val + " which is a type of " + Type.typeof(val));
				return false;
		}

		return true;
	}

	static function objectToLua(l:State, res:Any)
	{
		var FUCK = 0;
		for (n in Reflect.fields(res))
		{
			trace(Type.typeof(n).getName());
			FUCK++;
		}

		Lua.createtable(l, FUCK, 0); // TODONE: I did it

		for (n in Reflect.fields(res))
		{
			if (!Reflect.isObject(n))
				continue;
			Lua.pushstring(l, n);
			toLua(l, Reflect.field(res, n));
			Lua.settable(l, -3);
		}
	}

	function getType(l, type):Any
	{
		return switch Lua.type(l, type)
		{
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type) : String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l)
	{
		var lua_v:Int;
		var v:Any = null;
		while ((lua_v = Lua.gettop(l)) != 0)
		{
			var type:String = getType(l, lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v:Any, type:String):Dynamic
	{ // I didn't write this lol
		if (Std.is(v, String) && type != null)
		{
			var v:String = v;
			if (type.substr(0, 4) == 'array')
			{
				if (type.substr(4) == 'float')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Float> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseFloat(vars));
					}

					return array2;
				}
				else if (type.substr(4) == 'int')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Int> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseInt(vars));
					}

					return array2;
				}
				else
				{
					var array:Array<String> = v.split(',');
					return array;
				}
			}
			else if (type == 'float')
			{
				return Std.parseFloat(v);
			}
			else if (type == 'int')
			{
				return Std.parseInt(v);
			}
			else if (type == 'bool')
			{
				if (v == 'true')
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return v;
			}
		}
		else
		{
			return v;
		}
	}

	function getLuaErrorMessage(l)
	{
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name:String, object:Dynamic)
	{
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua, object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name:String, type:String):Dynamic
	{
		var result:Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return null;
		}
		else
		{
			var result = convert(result, type);
			// trace(var_name + ' result: ' + result);
			return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch (id)
		{
			case 'boyfriend':
				@:privateAccess
				return PlayState.boyfriend;
			case 'girlfriend':
				@:privateAccess
				return PlayState.gf;
			case 'dad':
				@:privateAccess
				return PlayState.dad;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
		{
			if (Std.parseInt(id) == null)
				return Reflect.getProperty(PlayState.instance, id);
			return PlayState.PlayState.strumLineNotes.members[Std.parseInt(id)];
		}
		return luaSprites.get(id);
	}

	function getPropertyByName(id:String)
	{
		return Reflect.field(PlayState.instance, id);
	}

	public static var luaSprites:Map<String, FlxSprite> = [];

	function changeDadCharacter(id:String)
	{
		var olddadx = PlayState.dad.x;
		var olddady = PlayState.dad.y;
		PlayState.instance.remove(PlayState.dad);
		PlayState.dad = new Character(olddadx, olddady, id);
		PlayState.instance.add(PlayState.dad);
		PlayState.instance.iconP2.changeIcon(id);
	}

	function changeBoyfriendCharacter(id:String)
	{
		var oldboyfriendx = PlayState.boyfriend.x;
		var oldboyfriendy = PlayState.boyfriend.y;
		PlayState.instance.remove(PlayState.boyfriend);
		PlayState.boyfriend = new Character(oldboyfriendx, oldboyfriendy, id, true);
		PlayState.instance.add(PlayState.boyfriend);
		PlayState.instance.iconP1.changeIcon(id);
	}

	function makeLuaSprite(spritePath:String, toBeCalled:String, drawBehind:Bool)
	{
		#if FEATURE_FILESYSTEM
		var data:BitmapData;

		#if (FEATURE_STEPMANIA && FEATURE_FILESYSTEM)
		if (PlayState.isSM)
			data = BitmapData.fromFile(PlayState.pathToSm + "/" + spritePath + ".png");
		else
		#end
			data = OpenFlAssets.getBitmapData("assets/data/songs/" + PlayState.SONG.songId + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(data);

		@:privateAccess
		{
			if (drawBehind)
			{
				PlayState.instance.remove(PlayState.gf);
				PlayState.instance.remove(PlayState.boyfriend);
				PlayState.instance.remove(PlayState.dad);
			}
			PlayState.instance.add(sprite);
			if (drawBehind)
			{
				PlayState.instance.add(PlayState.gf);
				PlayState.instance.add(PlayState.boyfriend);
				PlayState.instance.add(PlayState.dad);
			}
		}
		#end

		new LuaSprite(sprite, toBeCalled).Register(lua);
		return toBeCalled;
	}

	public function die()
	{
		Lua.close(lua);
		lua = null;
	}

	public var luaWiggles:Map<String, WiggleEffect> = new Map<String, WiggleEffect>();

	// LUA SHIT

	public function new()
	{
		shownNotes = [];
		trace('opening a lua state (because we are cool :))');
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		trace("Lua version: " + Lua.version());
		trace("LuaJIT version: " + Lua.versionJIT());
		Lua.init_callbacks(lua);

		// shaders = new Array<LuaShader>();

		var path:String = OpenFlAssets.getText(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));

		#if (FEATURE_STEPMANIA && FEATURE_FILESYSTEM)
		if (PlayState.isSM)
			path = File.getContent(PlayState.pathToSm + "/modchart.lua");
		#end

		var result = LuaL.dostring(lua, path); // execute le file
		if (result != 0)
		{
			Application.current.window.alert("LUA COMPILE ERROR:\n" + Lua.tostring(lua, result), "Kade Engine Modcharts");
			return;
		}

		// get some fukin globals up in here bois

		setVar("difficulty", PlayState.storyDifficulty);
		setVar("bpm", Conductor.bpm);
		setVar("scrollspeed",
			FlxG.save.data.scrollSpeed != 1 ? FlxG.save.data.scrollSpeed * PlayState.songMultiplier : PlayState.SONG.speed * PlayState.songMultiplier);
		setVar("fpsCap", FlxG.save.data.fpsCap);
		setVar("flashing", FlxG.save.data.flashing);
		setVar("distractions", FlxG.save.data.distractions);
		setVar("colour", FlxG.save.data.colour);
		setVar("middlescroll", FlxG.save.data.middleScroll);
		setVar("rate", PlayState.songMultiplier); // Kinda XD since you can modify this through Lua and break the game.

		setVar("curStep", 0);
		setVar("curBeat", 0);
		setVar("crochet", Conductor.stepCrochet);
		setVar("safeZoneOffset", Conductor.safeZoneOffset);

		setVar("hudZoom", PlayState.instance.camHUD.zoom);
		setVar("cameraZoom", FlxG.camera.zoom);

		setVar("cameraAngle", FlxG.camera.angle);
		setVar("camHudAngle", PlayState.instance.camHUD.angle);

		setVar("followXOffset", 0);
		setVar("followYOffset", 0);

		setVar("showOnlyStrums", false);
		setVar("strumLine1Visible", true);
		setVar("strumLine2Visible", true);

		setVar("screenWidth", FlxG.width);
		setVar("screenHeight", FlxG.height);
		setVar("windowWidth", FlxG.width);
		setVar("windowHeight", FlxG.height);
		setVar("hudWidth", PlayState.instance.camHUD.width);
		setVar("hudHeight", PlayState.instance.camHUD.height);

		setVar("mustHit", false);

		setVar("strumLineY", PlayState.instance.strumLine.y);

		Lua_helper.add_callback(lua, "precache", function(asset:String, type:String, ?library:String)
		{
			PlayState.instance.precacheThing(asset, type, library);
		});

		// callbacks

		Lua_helper.add_callback(lua, "getProperty", getPropertyByName);
		Lua_helper.add_callback(lua, "makeSprite", makeLuaSprite);

		// sprites

		Lua_helper.add_callback(lua, "setNoteWiggle", function(wiggleId)
		{
			PlayState.instance.camNotes.setFilters([new ShaderFilter(luaWiggles.get(wiggleId).shader)]);
		});

		Lua_helper.add_callback(lua, "setSustainWiggle", function(wiggleId)
		{
			PlayState.instance.camSustains.setFilters([new ShaderFilter(luaWiggles.get(wiggleId).shader)]);
		});

		Lua_helper.add_callback(lua, "createWiggle", function(freq:Float, amplitude:Float, speed:Float)
		{
			var wiggle = new WiggleEffect();
			wiggle.waveAmplitude = amplitude;
			wiggle.waveSpeed = speed;
			wiggle.waveFrequency = freq;

			var id = Lambda.count(luaWiggles) + 1 + "";

			luaWiggles.set(id, wiggle);
			return id;
		});

		Lua_helper.add_callback(lua, "setWiggleTime", function(wiggleId:String, time:Float)
		{
			var wiggle = luaWiggles.get(wiggleId);

			wiggle.shader.uTime.value = [time];
		});

		Lua_helper.add_callback(lua, "setWiggleAmplitude", function(wiggleId:String, amp:Float)
		{
			var wiggle = luaWiggles.get(wiggleId);

			wiggle.waveAmplitude = amp;
		});

		Lua_helper.add_callback(lua, "setStrumlineY", function(y:Float)
		{
			PlayState.instance.strumLine.y = y;
		});

		Lua_helper.add_callback(lua, "getNotes", function(y:Float)
		{
			Lua.newtable(lua);

			for (i in 0...PlayState.instance.notes.members.length)
			{
				var note = PlayState.instance.notes.members[i];
				Lua.pushstring(lua, note.LuaNote.className);
				Lua.rawseti(lua, -2, i);
			}
		});

		Lua_helper.add_callback(lua, "setScrollSpeed", function(value:Float)
		{
			PlayState.instance.scrollSpeed = value;
		});

		Lua_helper.add_callback(lua, "changeScrollSpeed", function(mult:Float, time:Float, ?ease:String)
		{
			PlayState.instance.changeScrollSpeed(mult, time, getFlxEaseByString(ease));
		});

		Lua_helper.add_callback(lua, "setCamZoom", function(zoomAmount:Float)
		{
			FlxG.camera.zoom = zoomAmount;
		});

		Lua_helper.add_callback(lua, "setHudZoom", function(zoomAmount:Float)
		{
			PlayState.instance.camHUD.zoom = zoomAmount;
		});

		Lua_helper.add_callback(lua, "setLaneUnderLayPos", function(value:Int)
		{
			PlayState.instance.laneunderlay.x = value;
		});

		Lua_helper.add_callback(lua, "setOpponentLaneUnderLayOpponentPos", function(value:Int)
		{
			PlayState.instance.laneunderlayOpponent.x = value;
		});

		Lua_helper.add_callback(lua, "setLaneUnderLayAlpha", function(value:Int)
		{
			PlayState.instance.laneunderlay.alpha = value;
		});

		Lua_helper.add_callback(lua, "setOpponentLaneUnderLayOpponentAlpha", function(value:Int)
		{
			PlayState.instance.laneunderlayOpponent.alpha = value;
		});

		// SHADER SHIT (Thanks old psych engine)

		Lua_helper.add_callback(lua, "addChromaticAbberationEffect", function(camera:String, chromeOffset:Float = 0.005)
		{
			PlayState.instance.addShaderToCamera(camera, new ChromaticAberrationEffect(chromeOffset));
		});

		Lua_helper.add_callback(lua, "addVignetteEffect", function(camera:String, radius:Float = 0.5, smoothness:Float = 0.5)
		{
			PlayState.instance.addShaderToCamera(camera, new VignetteEffect(radius, smoothness));
		});

		Lua_helper.add_callback(lua, "addGameboyEffect", function(camera:String, brightness:Float = 1.0)
		{
			PlayState.instance.addShaderToCamera(camera, new GameboyEffect(brightness));
		});

		Lua_helper.add_callback(lua, "addCRTEffect", function(camera:String, curved:Bool = true)
		{
			PlayState.instance.addShaderToCamera(camera, new CRTEffect(curved));
		});

		Lua_helper.add_callback(lua, "addGlitchEffect", function(camera:String, waveSpeed:Float = 0, waveFrq:Float = 0, waveAmp:Float = 0)
		{
			PlayState.instance.addShaderToCamera(camera, new GlitchEffect(waveSpeed, waveFrq, waveAmp));
		});

		Lua_helper.add_callback(lua, "clearEffects", function(camera:String)
		{
			PlayState.instance.clearShaderFromCamera(camera);
		});

		for (i in 0...PlayState.strumLineNotes.length)
		{
			var member = PlayState.strumLineNotes.members[i];
			new LuaReceptor(member, "receptor_" + i).Register(lua);
		}

		new LuaGame().Register(lua);

		new LuaWindow().Register(lua);
	}

	public function executeState(name, args:Array<Dynamic>)
	{
		return Lua.tostring(lua, callLua(name, args));
	}

	public static function createModchartState():ModchartState
	{
		return new ModchartState();
	}

	public static function getFlxEaseByString(?ease:String = '')
	{
		switch (ease.toLowerCase().trim())
		{
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}
#end

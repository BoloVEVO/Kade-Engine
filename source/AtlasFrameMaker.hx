package;

import JSONData;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import haxe.Json;
import openfl.display.BitmapData;
import JSONData.AtlasData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class AtlasFrameMaker extends FlxFramesCollection
{
	public static function construct(key:String, ?library:String, excludeArray:Array<String> = null):FlxFramesCollection
	{
		var frameCollection:FlxFramesCollection;
		var frameArray:Array<Array<FlxFrame>> = [];

		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			trace("Only Spritemaps made with Adobe Animate 2018 are supported");
			return null;
		}

		var animationData:AnimationAtlasData = Json.parse(OpenFlAssets.getText(Paths.animJson(key, library)));
		var atlasData:AtlasData = Json.parse(OpenFlAssets.getText(Paths.spriteMapJson(key, library)).replace("\uFEFF", ""));

		var graphic:FlxGraphic = Paths.image('$key/spritemap');
		var ss:SpriteAnimationLibrary = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
		var t:SpriteMovieClip = ss.createAnimation(FlxG.save.data.antialiasing);

		frameCollection = new FlxFramesCollection(graphic, FlxFrameCollectionType.IMAGE);

		if (excludeArray == null)
			excludeArray = t.getFrameLabels();

		for (x in excludeArray)
			frameArray.push(getFramesArray(t, x));

		for (x in frameArray)
			for (y in x)
				frameCollection.pushFrame(y);

		return frameCollection;
	}

	@:noCompletion static function getFramesArray(t:SpriteMovieClip, animation:String):Array<FlxFrame>
	{
		var sizeInfo:Rectangle = new Rectangle(0, 0);
		t.currentLabel = animation;
		var bitMapArray:Array<BitmapData> = [];
		var daFramez:Array<FlxFrame> = [];
		var firstPass = true;
		var frameSize:FlxPoint = new FlxPoint(0, 0);

		for (i in t.getFrame(animation)...t.numFrames)
		{
			t.currentFrame = i;
			if (t.currentLabel == animation)
			{
				sizeInfo = t.getBounds(t);
				var bitmapShit:BitmapData = new BitmapData(Std.int(sizeInfo.width + sizeInfo.x), Std.int(sizeInfo.height + sizeInfo.y), true, 0);
				bitmapShit.draw(t, null, null, null, null, true);
				bitMapArray.push(bitmapShit);

				if (firstPass)
				{
					frameSize.set(bitmapShit.width, bitmapShit.height);
					firstPass = false;
				}
			}
			else
				break;
		}

		for (i in 0...bitMapArray.length)
		{
			var bitmap:FlxGraphic = FlxGraphic.fromBitmapData(bitMapArray[i]);
			var theFrame:FlxFrame = new FlxFrame(bitmap);
			theFrame.parent = bitmap;
			theFrame.name = animation + i;
			theFrame.sourceSize.set(frameSize.x, frameSize.y);
			theFrame.frame = new FlxRect(0, 0, bitMapArray[i].width, bitMapArray[i].height);
			daFramez.push(theFrame);
		}

		return daFramez;
	}
}

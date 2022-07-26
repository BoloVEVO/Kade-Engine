package;

import openfl.media.Video;
import openfl.net.NetStream;
import openfl.net.NetConnection;
import flixel.FlxG;
import flixel.FlxBasic;
#if (FEATURE_MP4VIDEOS && !web)
import vlc.MP4Handler;
#end

class FlxVideo extends FlxBasic
{
	public var finishCallback:Void->Void;

	public function new(videoAsset:String)
	{
		super();

		#if (FEATURE_MP4VIDEOS && web)
		var video:Video = new Video();
		video.x = 0;
		video.y = 0;
		FlxG.addChildBelowMouse(video);

		var netConnection:NetConnection = new NetConnection();
		netConnection.connect(null);
		var netStream:NetStream = new NetStream(netConnection);
		netStream.client = {onMetaData: function()
		{
			video.attachNetStream(netStream);
			video.width = FlxG.width;
			video.height = FlxG.height;
		}};
		netConnection.addEventListener('netStatus', function(e)
		{
			if (e.info.code == 'NetStream.Play.Complete')
			{
				netStream.dispose();

				if (FlxG.game.contains(video))
					FlxG.game.removeChild(video);

				if (finishCallback != null)
					finishCallback();
			}
		});
		netStream.play(videoAsset);
		#elseif (FEATURE_MP4VIDEOS && !web)
		var daVid:MP4Handler = new MP4Handler();
		daVid.playVideo(videoAsset);
		daVid.finishCallback = function()
		{
			if (finishCallback != null)
				finishCallback();
		}
		#else
		if (finishCallback != null)
			finishCallback();
		#end
	}
}

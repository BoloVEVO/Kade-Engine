package;

import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.Polymod;

/**
 * Okay now this is epic.
 */
class ModCore
{
	/**
	 * The current API version.
	 * Must be formatted in Semantic Versioning v2; <MAJOR>.<MINOR>.<PATCH>.
	 * 
	 * Remember to increment the major version if you make breaking changes to mods!
	 */

	static final API_VERSION = "0.1.0";
	static final MOD_DIRECTORY = "mods";

	public static function reload()
	{
		Debug.logInfo("Reloading ModCore...");

		loadModsById([for (i in Polymod.scan(MOD_DIRECTORY)) i.id]);
	}

	public static function loadModsById(ids:Array<String>)
	{
		Debug.logInfo('Attempting to load ${ids.length} mods...');

		var loadedModList = Polymod.init({
			modRoot: MOD_DIRECTORY,
			dirs: ids,
			framework: CUSTOM,
			apiVersion: API_VERSION,
			errorCallback: function(error:PolymodError)
			{
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
						Debug.logInfo(error.message, null);
					case WARNING:
						Debug.logWarn(error.message, null);
					case ERROR:
						Debug.logError(error.message, null);
				}
			},
			frameworkParams: {
				assetLibraryPaths: [
					"fonts" => "fonts",
					"default" => "preload",
					"songs" => "songs",
					"shared" => "shared",
					"videos" => "videos",
					"week2" => "week2",
					"week3" => "week3",
					"week4" => "week4",
					"week5" => "week5",
					"week6" => "week6",
					"week7" => "week7",
				]
			},
			customBackend: ModCoreBackend,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			parseRules: {
				var output = polymod.format.ParseRules.getDefault();
				output.addType("txt", TextFileFormat.LINES);
				return output;
			}
		});

		Debug.logInfo('Mod loading complete. We loaded ${loadedModList.length} / ${ids.length} mods.');

		for (mod in loadedModList)
			Debug.logTrace('* ${mod.title} v${mod.modVersion} [${mod.id}]');

		var fileList = Polymod.listModFiles("BINARY");
		Debug.logInfo('Installed mods have replaced ${fileList.length} binary files.');
		for (item in fileList)
			Debug.logTrace('* $item');

		var fileList = Polymod.listModFiles("FONT");
		Debug.logInfo('Installed mods have replaced ${fileList.length} font files.');
		for (item in fileList)
			Debug.logTrace('* $item');

		var fileList = Polymod.listModFiles("IMAGE");
		Debug.logInfo('Installed mods have replaced ${fileList.length} images.');
		for (item in fileList)
			Debug.logTrace('* $item');

		fileList = Polymod.listModFiles("MUSIC");
		Debug.logInfo('Installed mods have replaced ${fileList.length} music files.');
		for (item in fileList)
			Debug.logTrace('* $item');

		fileList = Polymod.listModFiles("SOUND");
		Debug.logInfo('Installed mods have replaced ${fileList.length} sound files.');
		for (item in fileList)
			Debug.logTrace('* $item');

		fileList = Polymod.listModFiles("TEXT");
		Debug.logInfo('Installed mods have replaced ${fileList.length} text files.');
		for (item in fileList)
			Debug.logTrace('* $item');
	}
}

class ModCoreBackend extends OpenFLBackend
{
	public function new()
	{
		super();
		Debug.logTrace('Initialized custom asset loader backend.');
	}

	public override function clearCache()
	{
		super.clearCache();
		Debug.logWarn('Custom asset cache has been cleared.');
	}

	public override function exists(id:String):Bool
	{
		Debug.logTrace('Call to ModCoreBackend: exists($id)');
		return super.exists(id);
	}

	public override function getBytes(id:String):lime.utils.Bytes
	{
		Debug.logTrace('Call to ModCoreBackend: getBytes($id)');
		return super.getBytes(id);
	}

	public override function getText(id:String):String
	{
		Debug.logTrace('Call to ModCoreBackend: getText($id)');
		return super.getText(id);
	}

	public override function list(type:PolymodAssetType = null):Array<String>
	{
		Debug.logTrace('Listing assets in custom asset cache ($type).');
		return super.list(type);
	}
}

package;

import flixel.FlxG;

class NoteskinHelpers
{
	public static var noteskinArray:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/noteSkinsList'));

	static public function generateNoteskinSprite(id:Int)
	{
		return Paths.getSparrowAtlas('noteskins/' + NoteskinHelpers.noteskinArray[FlxG.save.data.noteskin], 'shared');
	}

	static public function generatePixelSprite(id:Int, ends:Bool = false)
	{
		return Paths.image('noteskins/' + NoteskinHelpers.noteskinArray[FlxG.save.data.noteskin] + '-pixel${(ends ? '-ends' : '')}', "shared");
	}
}

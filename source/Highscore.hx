package;

import flixel.FlxG;

class Highscore {
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end

	public static function saveScore(song:String, score:Int = 0, diff:String):Void {
		song = song.toLowerCase();
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong)) {
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:String = "week0", score:Int = 0, diff:String):Void {
		var daWeek:String = formatSong(week, diff);

		if (songScores.exists(daWeek)) {
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void {
		song = song.toLowerCase();
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:String):String {
		return song.toLowerCase() + CoolUtil.getDiffSuffix(diff);
	}

	public static function getScore(song:String, diff:String):Int {
		song = song.toLowerCase();
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:String, diff:String):Int {
		if (!songScores.exists(formatSong(week, diff)))
			setScore(formatSong(week, diff), 0);

		return songScores.get(formatSong(week, diff));
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null) {
			songScores = FlxG.save.data.songScores;
		}
	}
}

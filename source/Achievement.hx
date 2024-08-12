package;

import flixel.sound.FlxSoundGroup;
import flixel.sound.FlxSound;
import AltSharedObject.AltSave;
import Main.AchievementNotification;
import yaml.util.ObjectMap.AnyObjectMap;
import openfl.display.BitmapData;
import yaml.Yaml;
import sys.FileSystem;
import flixel.FlxG;

class Achievement {
	private static var _achievementSave:AltSave;
	private static var soundGroup:FlxSoundGroup = new FlxSoundGroup();
    
	public static function unlock(id:String) {
		if (!isUnlocked(id)) {
			new AchievementNotification(id);
			FlxG.sound.play(Paths.sound('achievementGet'), 1, false, soundGroup);
			set(id, true);
        }
    }

	public static function isUnlocked(id:String) {
		if (get(id) != true) {
            return false;
        }
        return true;
    }

	public static function getAchievements():Array<AchievementObject> {
		var arra:Array<AchievementObject> = new Array<AchievementObject>();

		if (FileSystem.exists("assets/achievements")) {
			for (folder in FileSystem.readDirectory("assets/achievements")) {
				var path = "assets/achievements/" + folder + "/";
				if (FileSystem.isDirectory(path)) {
					var config = Yaml.read(path + "config.yml");
					arra.push(new AchievementObject(folder, config, path + "icon.png"));
                }
            }
        }
		if (FileSystem.exists('${Paths.modsLoc}/achievements')) {
			for (folder in FileSystem.readDirectory('${Paths.modsLoc}/achievements')) {
				var path = '${Paths.modsLoc}/achievements/' + folder + "/";
				if (FileSystem.isDirectory(path)) {
					var config = Yaml.read(path + "config.yml");
					arra.push(new AchievementObject(folder, config, path + "icon.png"));
                }
            }
		}
        return arra;
    }

	public static function init() {
		_achievementSave = new AltSave();
		_achievementSave.bind("achievements", Main.ENGINE_NAME);
        _achievementSave.data._ = true;
		_achievementSave.flush();
	}

	private static function contains(variable):Bool {
		return Reflect.hasField(_achievementSave.data, variable);
	}

	private static function get(variable):Dynamic {
		return Reflect.field(_achievementSave.data, variable);
	}

	private static function set(variable, value) {
		Reflect.setField(_achievementSave.data, variable, value);
		_achievementSave.flush();
	}
}

class AchievementObject {

    public var id:String;
    public var config:AnyObjectMap;

	public var displayName:String;
	public var description:String;
	public var iconPath:String;

	public function new(id:String, config:AnyObjectMap, iconPath:String) {
		this.id = id;
		this.displayName = config.get("displayName");
		this.description = config.get("description");
		this.iconPath = iconPath;
    }

    public static function fromID(id:String):AchievementObject {
		if (FileSystem.exists("assets/achievements/" + id)) {
			var path = "assets/achievements/" + id + "/";
            if (FileSystem.isDirectory(path)) {
                var config = Yaml.read(path + "config.yml");
				return new AchievementObject(id, config, path + "icon.png");
            }
		}
		if (FileSystem.exists(Paths.modsLoc + "/achievements/" + id)) {
			var path = Paths.modsLoc + "/achievements/" + id + "/";
            if (FileSystem.isDirectory(path)) {
                var config = Yaml.read(path + "config.yml");
				return new AchievementObject(id, config, path + "icon.png");
            }
		}
        return null;
    }

    public function toString():String {
        return '("$id", "$displayName", "$description", "$iconPath")';
    }
}
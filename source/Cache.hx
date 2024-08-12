package;

import yaml.Yaml;
import lime.utils.Assets;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Resource;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import openfl.media.Sound;

/**
 * Class that caches game assets
 */
class Cache {
    public static var characters:Map<String, Character> = new Map();
	public static var bfs:Map<String, Boyfriend> = new Map();
	public static var charactersAssets:Map<String, ImageCache> = new Map();
	public static var charactersConfigs:Map<String, Dynamic> = new Map();

	public static var menuCharacters:Map<String, MenuCharacter> = new Map();

    public static var stages:Map<String, Stage> = new Map();

    public static var sounds:Map<String, Sound> = new Map();

    public static var bytes:Map<String, Bytes> = new Map();

	public static var notes:Map<String, FlxAtlasFrames> = new Map();
	public static var notesConfigs:Map<String, Dynamic> = new Map();

	public static function cacheCharacter(char, daChar, ?forceCache:Bool = false):Dynamic {
		if (char == "bf") {
			if (!Cache.bfs.exists(daChar) || forceCache) {
				Sys.println("caching character (boyfriend): " + daChar + "...");
				Cache.bfs.set(daChar, new Boyfriend(0, 0, daChar));
			}
			return Cache.bfs.get(daChar);
		}
		else {
			if (!Cache.characters.exists(daChar) || forceCache) {
				Sys.println("caching character: " + daChar + "...");
				Cache.characters.set(daChar, new Character(0, 0, daChar));
			}
            return Cache.characters.get(daChar);
		}
	}

    public static function cacheCharacterConfig(daChar, forceCache:Bool = false) {
		if (!Cache.charactersConfigs.exists(daChar) || forceCache) {
            if (FileSystem.exists(Paths.getCharacterPath(daChar) + "config.yml")) {
				Sys.println("caching character config: " + daChar + "...");
                Cache.charactersConfigs.set(daChar, CoolUtil.readYAML(Paths.getCharacterPath(daChar) + "config.yml"));
            }
        }
    }

    public static function cacheCharacterAssets(daChar, ?forceCache:Bool = false) {
		var path = Paths.getCharacterPath(daChar);
		if (path.startsWith(Paths.modsLoc + "/skins/")) {
			var spltPath = path.split("/");
			path += spltPath[spltPath.length - 2];
		}
		else {
			path += daChar;
		}
		if (!Cache.charactersAssets.exists(daChar) || forceCache) {
			Sys.println("caching character assets: " + path + "...");
            if (FileSystem.exists(path + ".txt")) {
				Cache.charactersAssets.set(daChar, new ImageCache(File.getBytes(path + ".png"), File.getContent(path + ".txt")));
            }
            else {
				Cache.charactersAssets.set(daChar, new ImageCache(File.getBytes(path + ".png"), File.getContent(path + ".xml")));
            }
        }
		cacheCharacterConfig(daChar, forceCache);
		if (FileSystem.exists(path + ".txt")) {
			return FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromBytes(Cache.charactersAssets.get(daChar).imageBytes),
				Cache.charactersAssets.get(daChar).xml);
        }
        else {
			return FlxAtlasFrames.fromSparrow(BitmapData.fromBytes(Cache.charactersAssets.get(daChar).imageBytes), 
                Cache.charactersAssets.get(daChar).xml);
        }
		
	}

	public static function cacheNote(note, ?forceCache:Bool = false) {
		var path = (FileSystem.exists("assets/custom_notes/" + note + "/") ? "assets" : "mods") + "/custom_notes/" + note + "/";
		if (Cache.notes.get(note) == null) {
			Sys.println("caching custom note: " + note);
			Cache.notes.set(note, FlxAtlasFrames.fromSparrow(BitmapData.fromBytes(File.getBytes(path + note + ".png")),
				File.getContent(path + note + ".xml")));
		}
		if (!Cache.notesConfigs.exists(note) || forceCache) {
			if (FileSystem.exists(path + "config.yml")) {
				Sys.println("caching custom note config: " + note);
				Cache.notesConfigs.set(note, CoolUtil.readYAML(path + "config.yml"));
			}
		}
		return Cache.notes.get(note);
	}

	// uncomment for free ram!
	/*
	public static function cacheNote(note, ?forceCache:Bool = false) {
		var path = (FileSystem.exists("assets/custom_notes/" + note + "/") ? "assets" : "mods") + "/custom_notes/" + note + "/";
		if (!Cache.notes.exists(note) || forceCache) {
			trace("caching note: " + path + note + "...");
			if (FileSystem.exists(path + note + ".txt")) {
				Cache.notes.set(note, new ImageCache(File.getBytes(path + note + ".png"), File.getContent(path + note + ".txt")));
			}
			else {
				Cache.notes.set(note, new ImageCache(File.getBytes(path + note + ".png"), File.getContent(path + note + ".xml")));
			}
		}
		cacheNoteConfig(note, forceCache);
		if (FileSystem.exists(path + note + ".txt")) {
			return FlxAtlasFrames.fromSpriteSheetPacker(BitmapData.fromBytes(Cache.notes.get(note).imageBytes), Cache.notes.get(note).xml);
		}
		else {
			return FlxAtlasFrames.fromSparrow(BitmapData.fromBytes(Cache.notes.get(note).imageBytes), Cache.notes.get(note).xml);
		}
	}

	public static function cacheNoteConfig(note:String, ?forceCache:Bool = false) {
		var path = (FileSystem.exists("assets/custom_notes/" + note + "/") ? "assets" : "mods") + "/custom_notes/" + note + "/";

		if (!Cache.notesConfigs.exists(note) || forceCache) {
			if (FileSystem.exists(path + "config.yml")) {
				//if (path.startsWith("assets")) {
				//Cache.notes.set(note, Yaml.parse(Assets.getText("custom_notes/" + note + "/config.yml")));
				//}
				//else {
				Cache.notesConfigs.set(note, CoolUtil.readYAML(path + "config.yml"));
				//}
			}
		}
	}
	*/

    public static function cacheStage(name) {
		if (Cache.stages.get(name) == null) {
			Sys.println("caching stage: " + name);
            Cache.stages.set(name, new Stage(name));
        }
		return Cache.stages.get(name);
    }

	public static function cacheSound(path:String) {
		if (Cache.sounds.get(path) == null) {
			Sys.println("caching sound: " + path);
            Cache.sounds.set(path, Sound.fromFile(path));
        }
		return Cache.sounds.get(path);
    }

    public static function cacheBytes(path:String) {
		if (Cache.bytes.get(path) == null) {
			Sys.println("caching bytes: " + path);
            Cache.bytes.set(path, File.getBytes(path));
        }
		return Cache.bytes.get(path);
    }
}

//made this because haxeflixel asset handling is shit
class ImageCache {
	public var imageBytes:Bytes;
	public var xml:String;

	public function new(imageBytes:Bytes, xml:String) {
		this.imageBytes = imageBytes;
        this.xml = xml;
    }
}
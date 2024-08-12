package;

import yaml.util.ObjectMap.AnyObjectMap;
import openfl.Assets;
import haxe.Exception;
import sys.FileSystem;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

#if MONITOR
@:build(MonitorMacro.build())
#end
class Note extends FlxSprite {
	var daStage:String;

	// NOTE DATA
	public var noteData:Int = 0;
	public var action:String = null;
	public var actionValue:String = null;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isGoodNote:Bool = true;
	public var canBeMissed:Bool = false;
	public var config:AnyObjectMap = new AnyObjectMap();
	public var lua:LuaShit = null;

	// INPUT SHIT

	/** blocks action notes from doing anything */
	public var blockActions:Bool = false;

	/** the position of note in song */
	public var strumTime:Float = 0;

	/** `true` if the note is for boyfriend */
	public var mustPress:Bool = false;

	/** `true` when the note is in `Conductor.safeZoneOffset` */
	public var canBeHit(get, null):Bool = false;

	/** `true` when it missed the strum line */
	public var tooLate(get, null):Bool = false;

	/** `true` if the note `strumTime` equals or is higher than current song position. works only for dad note */
	public var wasGoodHit:Bool = false;

	/** `true` if the note `strumTime` equals current song position */
	public var wasGoodHitButt:Bool = false;

	/** `true` if the note `strumTime` equals or is higher than current song position */
	public var wasInSongPosition:Bool = false;

	/*
		public var canActuallyBeHit(default, set):Bool = false;

		function set_canActuallyBeHit(value:Bool):Bool {
			if (canBeHit) {
				canActuallyBeHit = value;
			}
			else {
				canActuallyBeHit = false;
			}
			return canActuallyBeHit;
		}
	 */
	// OTHER
	public static var sizeShit = 0.7;

	public var prevNote:Note;
	public var isXInitialized:Bool = false;
	public var prevX:Float;

	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	override function set_x(_x:Float):Float {
		prevX = x;
		@:privateAccess
		return super.set_x(_x);
	}

	public static function getSwagWidth(?whichK:Int = 4):Float {
		return 160 * sizeShit;
	}

	public static function setSizeVar() {
		switch (PlayState.SONG.whichK) {
			case 4, 5:
				Note.sizeShit = 0.7;
			case 6:
				Note.sizeShit = 0.55;
			case 7:
				Note.sizeShit = 0.5;
			case 8:
				Note.sizeShit = 0.45;
			case 9:
				Note.sizeShit = 0.4;
			default:
				Note.sizeShit = 0.7;
		}
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?action:String, ?actionValue:String) {
		super();

		this.noteData = noteData;
		setNotePrefix();

		setSizeVar();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		if (action != null && action.trim() != "") {
			this.action = action.toLowerCase();
			this.actionValue = actionValue.toLowerCase();
		}
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		daStage = PlayState.instance.stage.name;

		setNoteAsset();
		/*
			switch (action.toLowerCase()) {
				case("ebola"):
					canBeMissed = true;
					isGoodNote = false;
					noteAsset(true, "eNotes");
				case("damage"):
					canBeMissed = true;
					isGoodNote = false;
					noteAsset(true, "damageNotes");
				default:
					noteAsset(false);
			}
		 */

		x += getSwagWidth(PlayState.SONG.whichK) * noteData;
		animation.play(notePrefix + "Scroll");

		// trace(prevNote);

		if (isSustainNote && prevNote != null) {
			if (prevNote.isSustainNote) {
				prevNote.animation.play(notePrefix + "hold");

				switch (PlayState.SONG.whichK) {
					case 6, 7:
						prevNote.scale.y *= (Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed * PlayState.SONG.whichK / 4.7);
					default:
						prevNote.scale.y *= (Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed);
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			alpha = 0.6;

			x += width / 2;
			animation.play(notePrefix + "holdend");

			updateHitbox();
		}
	}

	public function setNoteAsset() {
		var swagNoteExists = FileSystem.exists("mods/custom_notes/" + action + "/")
			|| FileSystem.exists("assets/custom_notes/" + action + "/");
		if (!swagNoteExists) {
			switch (daStage) {
				case 'school' | 'schoolEvil':
					loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					if (isSustainNote) {
						loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();

				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('thingScroll', 'thing0');

					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('thingholdend', 'thing hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('thinghold', 'thing hold piece');

					setGraphicSize(Std.int(width * Note.sizeShit));
					updateHitbox();
					antialiasing = true;
			}
		}
		else if (swagNoteExists) {
			if (FileSystem.exists("mods/custom_notes/" + action + "/")) {
				frames = Cache.cacheNote(action);
				config = Cache.notesConfigs.get(action);
			}
			else if (FileSystem.exists("assets/custom_notes/" + action + "/")) {
				frames = Cache.cacheNote(action);
				//frames = Paths.getNoteSparrowAtlas(action);
				//Cache.cacheNoteConfig(action);
				config = Cache.notesConfigs.get(action);
			}

			if (FileSystem.exists("mods/custom_notes/" + action + "/script.lua")) {
				lua = new LuaShit("mods/custom_notes/" + action + "/script.lua", this, NOTE);
			}
			else if (FileSystem.exists("assets/custom_notes/" + action + "/script.lua")) {
				lua = new LuaShit("assets/custom_notes/" + action + "/script.lua", this, NOTE);
			}

			animation.addByPrefix('greenScroll', 'green0');
			animation.addByPrefix('redScroll', 'red0');
			animation.addByPrefix('blueScroll', 'blue0');
			animation.addByPrefix('purpleScroll', 'purple0');
			animation.addByPrefix('thingScroll', 'thing0');

			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');
			animation.addByPrefix('thingholdend', 'thing hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
			animation.addByPrefix('thinghold', 'thing hold piece');

			if (config.exists("canBeMissed"))
				canBeMissed = CoolUtil.stringToOgType(Std.string(config.get('canBeMissed')));

			if (config.exists("isGoodNote"))
				isGoodNote = CoolUtil.stringToOgType(Std.string(config.get('isGoodNote')));

			setGraphicSize(Std.int(width * Note.sizeShit));
			updateHitbox();
			antialiasing = true;
		}
	}

	@:deprecated("replaced by setNoteAsset()")
	function noteAsset(?custom:Bool = false, ?name:String) {
		if (custom == true && name != null) {
			frames = Paths.getSparrowAtlas(name);

			animation.addByPrefix('greenScroll', 'green0');
			animation.addByPrefix('redScroll', 'red0');
			animation.addByPrefix('blueScroll', 'blue0');
			animation.addByPrefix('purpleScroll', 'purple0');
			animation.addByPrefix('thingScroll', 'thing0');

			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');
			animation.addByPrefix('thingholdend', 'thing hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
			animation.addByPrefix('thinghold', 'thing hold piece');

			setGraphicSize(Std.int(width * Note.sizeShit));
			updateHitbox();
			antialiasing = true;
		}
		else {
			switch (daStage) {
				case 'school' | 'schoolEvil':
					loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);

					if (isSustainNote) {
						loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);

						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();

				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');

					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
					animation.addByPrefix('thingScroll', 'thing0');

					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
					animation.addByPrefix('thingholdend', 'thing hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
					animation.addByPrefix('thinghold', 'thing hold piece');

					setGraphicSize(Std.int(width * Note.sizeShit));
					updateHitbox();
					antialiasing = true;
			}
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (isSustainNote && PlayState.instance.downscroll) {
			flipY = true;
		}

		// The * 0.5 is so that it's easier to hit them too late, instead of too early
		/*
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		 */

		if (strumTime <= Conductor.songPosition)
			wasInSongPosition = true;

		/*
			if (!mustPress) {
				if (PlayState.instance.playAs == "bf") {
					canBeHit = false;
					if (strumTime <= Conductor.songPosition)
						wasGoodHit = true;
				}
			}
		 */

		if (wasGoodHitButt) {
			missedSongPosition = true;
			wasGoodHitButt = false;
		}

		if (!missedSongPosition) {
			if (strumTime <= Conductor.songPosition)
				wasGoodHitButt = true;
		}

		if (tooLate) {
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (isSustainNote) {
			offset.x = -(width / 1.3);

			if (daStage.startsWith('school'))
				offset.x = -(width / 0.9);
		}

		if (PlayState.instance.downscroll) {
			if (animation.curAnim != null)
				if (animation.curAnim.name.endsWith("holdend"))
					offset.y = -(height / 1.35);
		}

		// would be for blind mode
		//alpha = canActuallyBeHit ? 1.0 : 0.05;
	}

	public var missedSongPosition:Bool = false;

	public function setNotePrefix() {
		switch (PlayState.SONG.whichK) {
			case 4:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'blue';
					case 2:
						notePrefix = 'green';
					case 3:
						notePrefix = 'red';
				}
			case 5:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'blue';
					case 2:
						notePrefix = 'thing';
					case 3:
						notePrefix = 'green';
					case 4:
						notePrefix = 'red';
				}
			case 6:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'green';
					case 2:
						notePrefix = 'red';
					case 3:
						notePrefix = 'purple';
					case 4:
						notePrefix = 'blue';
					case 5:
						notePrefix = 'red';
				}
			case 7:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'green';
					case 2:
						notePrefix = 'red';
					case 3:
						notePrefix = 'thing';
					case 4:
						notePrefix = 'purple';
					case 5:
						notePrefix = 'blue';
					case 6:
						notePrefix = 'red';
				}
			case 8:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'blue';
					case 2:
						notePrefix = 'green';
					case 3:
						notePrefix = 'red';
					case 4:
						notePrefix = 'purple';
					case 5:
						notePrefix = 'blue';
					case 6:
						notePrefix = 'green';
					case 7:
						notePrefix = 'red';
				}
			case 9:
				switch (noteData) {
					case 0:
						notePrefix = 'purple';
					case 1:
						notePrefix = 'blue';
					case 2:
						notePrefix = 'green';
					case 3:
						notePrefix = 'red';
					case 4:
						notePrefix = 'thing';
					case 5:
						notePrefix = 'purple';
					case 6:
						notePrefix = 'blue';
					case 7:
						notePrefix = 'green';
					case 8:
						notePrefix = 'red';
				}
		}
	}

	// function for lua note shit
	public function toArray():Array<Dynamic> {
		return [strumTime, noteData, sustainLength, action, actionValue];
	}

	public function onSongPosition() {
		var actionValueFloat = Std.parseFloat(actionValue);
		if (!blockActions) {
			switch (action.toLowerCase()) {
				case "subtitle", "sub":
					PlayState.addSubtitle(actionValue);
				case "p1 icon alpha":
					PlayState.instance.iconP1.alpha = actionValueFloat;
				case "p2 icon alpha":
					PlayState.instance.iconP2.alpha = actionValueFloat;
				case "picos":
					if (PlayState.gf.curCharacter == "pico-speaker") {
						PlayState.gf.playAnim("picoShoot" + actionValue);
					}
				case "change character":
					var splicedValue = actionValue.split(", ");
					PlayState.instance.changeCharacter(splicedValue[0], splicedValue[1]);
				case "change stage":
					PlayState.instance.changeStage(actionValue);
				case "change scroll speed":
					PlayState.instance.curSpeed = actionValueFloat;
				case "add camera zoom":
					PlayState.instance.addCameraZoom(actionValueFloat);
				case "hey":
					PlayState.bf.playAnim('hey', true);
					PlayState.gf.playAnim('cheer', true);
				case "play animation":
					var splicedValue = actionValue.split(", ");
					switch (splicedValue[0]) {
						case "bf":
							PlayState.bf.playAnim(splicedValue[1], true);
						case "gf":
							PlayState.gf.playAnim(splicedValue[1], true);
						case "dad":
							PlayState.dad.playAnim(splicedValue[1], true);
					}
			}
		}
		blockActions = true;
	}

	public function onPlayerHit() {
		if (!blockActions) {
			if (lua != null) {
				//TODO
				//lua.call("onPlayerHit");
			}

			/*
				switch (action.toLowerCase()) {
					case "ebola":
						new FlxTimer().start(0.01, function(timer:FlxTimer) {
							PlayState.instance.health -= 0.001;
						}, 0);
					case "damage":
						if (actionValue != null)
							PlayState.instance.health -= Std.parseFloat(actionValue);
						else
							PlayState.instance.health -= 0.3;
				}
			 */
		}
		blockActions = true;
	}

	public var notePrefix:String = "blue";

	function get_canBeHit():Bool {
		return // TOO LATE
			strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.4 * (isGoodNote ? 1 : 0.2)) && // TOO EARLY
			strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 1.2 * (isGoodNote ? 1 : 0.2));
	}

	function get_tooLate():Bool {
		return strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit;
	}
}

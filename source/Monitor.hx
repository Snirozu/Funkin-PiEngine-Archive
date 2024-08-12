import haxe.CallStack;
import sys.FileSystem;
import sys.io.File;
import flixel.math.FlxMath;
import openfl.Assets;
import flixel.FlxG;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.display.Sprite;

class Monitor extends Sprite {
    public static var monitorMap:Map<String, Float> = new Map<String, Float>();
    private static var lastUpdated:Map<String, Float> = new Map<String, Float>();
	public static var curLog:String = "";

    var text:TextField;
	var logs:TextField;
    var initialized:Bool = false;
	
	static var date = Date.now();

	static var instance:Monitor;

    public static function update(field:String, time:Float) {
        if (time > 0) {
			monitorMap.set(field, time);
			lastUpdated.set(field, Sys.time());
        }
    }

	static var lastLog:String = null;

	public static function log(string:String) {
		if (StringTools.trim(string) == "")
			return;

		date = Date.now();
		if (setCheckLastLog("[" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + "] " + string + "\n") == null)
			return;

		curLog += lastLog;

		if (instance != null && instance.logs != null) {
			instance.logs.appendText(lastLog);

			instance.logs.height = instance.logs.textHeight;
			instance.logs.y = (FlxG.height - instance.logs.height) - 20;
		}
	}

	static function setCheckLastLog(newLog:String) {
		if (newLog == lastLog) {
			return null;
		}
		return lastLog = newLog;
	}

    public function new() {
        super();

		instance = this;

		addEventListener(Event.ADDED_TO_STAGE, create);
    }

	static function getSwagDate() {
		date = Date.now();
		return '${date.getFullYear()}-${date.getMonth()}-${date.getDate()}_${date.getHours()}-${date.getMinutes()}-${date.getSeconds()}';
	}

	function create(?event:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE))
		    removeEventListener(Event.ADDED_TO_STAGE, create);

        visible = false;

		stage.addEventListener(KeyboardEvent.KEY_UP, (e) -> {
			if (e.keyCode == Keyboard.TAB) {
				visible = !visible;
			}
			if (e.ctrlKey && e.keyCode == Keyboard.DELETE) {
				if (!FileSystem.exists("logs/")) {
					FileSystem.createDirectory("logs/");
				}
				File.saveContent("logs/" + getSwagDate() + ".txt", curLog);
				curLog = "";
			}
		});

		var bg = new Bitmap(new BitmapData(Std.int(FlxG.width), Std.int(FlxG.height), true, FlxColor.BLACK));
		bg.alpha = 0.4;
        addChild(bg);
        
		text = new TextField();
		text.defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr.ttf")).fontName, 20, FlxColor.WHITE);
        text.textColor = FlxColor.WHITE;
		text.x = 70 + 700;
		text.y = 40;
		text.height = FlxG.height;
		text.width = FlxG.width;
		text.text = "";
		addChild(text);

		// logs = new TextField();
		// logs.defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr.ttf")).fontName, 13, FlxColor.WHITE);
		// logs.textColor = FlxColor.WHITE;
		// logs.y = 40;
		// logs.width = FlxG.width;
		// logs.text = "";
		// addChild(logs);

		initialized = true;
    }

	var lagLevel:Map<String, Float> = [];
	var curTime = 0.;

	var lastCallStack = "";

    override function __enterFrame(delta:Int) {
		super.__enterFrame(delta);
        
		if (!visible || !initialized) {
            return;
        }

		curTime = Sys.time();
		lagLevel.clear();

        // >:(
        //monitorMap.sort();

		text.text = "";
		for (field => time in monitorMap) {
			if (lastUpdated.get(field) < curTime - (300 * FlxG.elapsed)) {
				monitorMap.remove(field);
				lastUpdated.remove(field);
                continue;
            }
			if (time >= 0.015) {
				text.appendText("[!] ");
				lagLevel.set(field, time);
			}
			text.appendText(field + " : " + FlxMath.roundDecimal(time, 5) + "s\n");
		}
		text.textColor = FlxColor.WHITE;
		if (lagLevel.iterator().hasNext()) {
			log("Found lagging methods: " + lagLevel);
			text.textColor = FlxColor.YELLOW;
		}

		var stack:String = CallStack.callStack()[CallStack.callStack().length - 1] + "";

		if (lastCallStack != stack) {
			log(stack);
		}

		lastCallStack = stack;
    }
}
package;

import Controls.KeyType;
import Controls.KeyBind;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxTimer;
import sys.FileSystem;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class OptionsSubState extends FlxSubState {

	var options = [
		'Gameplay',
		'Preferences'
	];
	var optionsItems = new FlxTypedGroup<Alphabet>();
	var curSelected:Int = 0;
	var inGame:Bool;

	public static var optionsCamera:FlxCamera;

	public function new(?inGame = false) {
		super();

		if (inGame)
			optionsCamera = PlayState.camOptions;
		else
			optionsCamera = FlxG.camera;

		this.inGame = inGame;

		optionsCamera.follow(null);

		optionsCamera.scroll.x = 0;
		optionsCamera.scroll.y = 0;

		//if (inGame)
			//optionsCamera.zoom = 0.7;

		var bg = new Background(FlxColor.ORANGE);
		add(bg);

		var curY = 0.0;
		var curIndex = -1;
		for (s in options) {
			curIndex++;
			var option = new Alphabet(0, 0, s, true);
			option.ID = curIndex;
			option.scrollFactor.set();
			option.screenCenter(XY);
			option.y += curY;
			curY += option.height;

			optionsItems.add(option);
		}
		for (item in optionsItems) {
			item.y -= curY / 2;
		}
		add(optionsItems);
		
		cameras = [optionsCamera];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.check(UI_UP)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected -= 1;
		}

		if (Controls.check(UI_DOWN)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected += 1;
		}

		if (curSelected < 0)
			curSelected = optionsItems.length - 1;

		if (curSelected >= optionsItems.length)
			curSelected = 0;

		optionsItems.forEach(function(alphab:Alphabet) {
			alphab.alpha = 0.6;

			if (alphab.ID == curSelected) {
				alphab.alpha = 1;
			}
		});

		if (Controls.check(ACCEPT)) {
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			if (options[curSelected] == options[0] || options[curSelected] == "Gameplay") {
				closeSubState();
				FlxG.state.openSubState(new OptionsGameplaySubState(inGame));
			}
			else if (options[curSelected] == options[1] || options[curSelected] == "Preferences") {
				closeSubState();
				FlxG.state.openSubState(new OptionsPrefencesSubState(inGame));
			}
		}

		if (Controls.check(BACK)) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MainMenuState.selectedSomethin = false;
			PlayState.openSettings = false;
			PlayState.cancelGameResume = true;
			if (inGame) {
				close();
				PlayState.instance.pauseGame(true, 3);
			}
			else 
				FlxG.switchState(new MainMenuState(true));
		}
	}
}

class OptionsPrefencesSubState extends OptionSubState {
	public function new(inGame) {
		var items = [
			new OptionItem('FPS Limit: ' + Options.framerate, "FPS Limit"),
			new OptionItem('Show FPS', "Whatever or not to show FPS Counter", true, Options.showFPS, value -> Options.showFPS = value),
			new OptionItem('Borderless Window', "Should the game window be borderless or not", true, Options.borderless, value -> Options.borderless = value),
			new OptionItem('Background Dimness: ' + Options.bgDimness, "Background dimness from 0.0 to 1.0"),
			new OptionItem('Background Blur: ' + Options.bgBlur + "XY", "Amount of blur applied to the game (except gui)"),
			new OptionItem('Discord Rich Presence', "If enabled discord game status will be enabled", true, Options.discordRPC, value -> Options.discordRPC = value),
			new OptionItem('Disable Crash Handler', "If disabled game dumps logs into console", true, Options.disableCrashHandler, value -> Options.disableCrashHandler = value),
			new OptionItem('Song Debug mode (for mod makers)', "Shows warnings, errors when in song", true, Options.songDebugMode, value -> Options.songDebugMode = value),
			new OptionItem('Update Checker', "Should the game check if there's a newer version?", true, Options.updateChecker, value -> Options.updateChecker = value),
			new OptionItem('Freeplay Listen to Vocals', "Should there be vocals in Freeplay", true, Options.freeplayListenVocals, value -> Options.freeplayListenVocals = value),
			new OptionItem('BF Skin', "Skins for boyfriend"),
			new OptionItem('GF Skin', "Skins for Girlfriend"),
			new OptionItem('Dad Skin', "Skins for Opponent")
			#if debug
			,new OptionItem('Customize Note', "shit piss fart, crashes the game")
			#end
		];
		super(items, inGame);
	}
	
	override public function update(elapsed) {
		super.update(elapsed);

		if (Controls.check(ACCEPT)) {
			if (itemList[curSelected].text == "Customize Note") {
				closeSubState();
				FlxG.state.openSubState(new NoteOption(inGame));
			}
		}

		if (Controls.check(UI_RIGHT) || Controls.check(UI_LEFT)) {
			if (Controls.check(UI_LEFT)) {
				if (itemList[curSelected].text.startsWith("FPS Limit")) {
					if (Options.framerate > 5)
						Options.framerate -= 5;
					setOptionText(curSelected, "FPS Limit: " + Options.framerate);
				}
				else if (itemList[curSelected].text.startsWith("Background Dimness")) {
					if (Options.bgDimness > 0.0)
						Options.bgDimness -= 0.05;
					Options.bgDimness = CoolUtil.roundFloat(Options.bgDimness);
					setOptionText(curSelected, "Background Dimness: " + Options.bgDimness);
				}
				else if (itemList[curSelected].text.startsWith("Background Blur")) {
					if (Options.bgBlur > 0)
						Options.bgBlur -= 1;
					Options.bgBlur = CoolUtil.roundFloat(Options.bgBlur);
					setOptionText(curSelected, "Background Blur: " + Options.bgBlur + "XY");
				}
			}
			if (Controls.check(UI_RIGHT)) {
				if (itemList[curSelected].text.startsWith("FPS Limit")) {
					if (Options.framerate < 240)
						Options.framerate += 5;
					setOptionText(curSelected, "FPS Limit: " + Options.framerate);
				}
				else if (itemList[curSelected].text.startsWith("Background Dimness")) {
					if (Options.bgDimness < 1.0) 
						Options.bgDimness += 0.05;
					Options.bgDimness = CoolUtil.roundFloat(Options.bgDimness);
					setOptionText(curSelected, "Background Dimness: " + Options.bgDimness);
				}
				else if (itemList[curSelected].text.startsWith("Background Blur")) {
					if (Options.bgBlur < 255)
						Options.bgBlur += 1;
					Options.bgBlur = CoolUtil.roundFloat(Options.bgBlur);
					setOptionText(curSelected, "Background Blur: " + Options.bgBlur + "XY");
				}
			}
		}

		if (Controls.check(ACCEPT)) {
			switch (itemList[curSelected].text) {
				case "BF Skin":
					closeSubState();
					FlxG.state.openSubState(new OptionsSkinSubState("bf", inGame));
				case "GF Skin":
					closeSubState();
					FlxG.state.openSubState(new OptionsSkinSubState("gf", inGame));
				case "Dad Skin":
					closeSubState();
					FlxG.state.openSubState(new OptionsSkinSubState("dad", inGame));	
			}
		}
	}
}

class OptionsGameplaySubState extends OptionSubState {
	public function new(inGame) {
		var items = [
			new OptionItem("Controls", "The game binds"),
			new OptionItem("Accuracy Type: " + Options.accuracyType.getName(), "How accuracy will be judged"),
			// deleting ghost tapping for idk what time bcs it fucks up and no one fucking disables it
			//new OptionItem("Ghost Tapping", true, Options.ghostTapping, value -> Options.ghostTapping = value),
			new OptionItem("Downscroll", "If enabled notes go down instead of up", true, Options.downscroll, value -> Options.downscroll = value),
			new OptionItem("Disable Spam Checker (pussy mode)", "Feature for Matt mod fans", true, Options.disableSpamChecker, value -> Options.disableSpamChecker = value),
			new OptionItem("Disable New Combo System", "If enabled Combo sprites are enabled", true, Options.disableNewComboSystem, value -> {
				Options.disableNewComboSystem = value;
				PlayState.instance.combo.clearComboTimer = new FlxTimer();
				if (value) {
					PlayState.instance.combo.clearComboTimer = null;
				}
				else {
					PlayState.instance.combo.initTimer();
				}
			}),
			new OptionItem("Chill Mode", "Removes hurt notes from the chart", true, Options.chillMode, value -> Options.chillMode = value),
			new OptionItem("Hit Sounds", "osu moment", true, Options.hitSounds, value -> Options.hitSounds = value),
			new OptionItem("Splashes", "Should splashes be enabled?", true, Options.enabledSplashes, value -> Options.enabledSplashes = value),
		];
		super(items, inGame);
	}
	
	override public function update(elapsed) {
		super.update(elapsed);

		if (Controls.check(ACCEPT)) {
			if (itemList[curSelected].text == "Controls") {
				closeSubState();
				FlxG.state.openSubState(new OptionsControlsSubstate(inGame));
			}
		}
		if (itemList[curSelected].text.startsWith("Accuracy Type")) {
			if (Controls.check(UI_LEFT)) {
				Options.accuracyType--;
				itemList[curSelected].text = "Accuracy Type: " + Options.accuracyType.getName();
			}
			if (Controls.check(UI_RIGHT)) {
				Options.accuracyType++;
				itemList[curSelected].text = "Accuracy Type: " + Options.accuracyType.getName();
			}
		}
	}
}





class OptionSubState extends FlxSubState {
	private var itemList:Array<OptionItem>;

	public var items = new FlxTypedGroup<OptionItem>();
	public var checkboxes = new FlxTypedGroup<Checkbox>();

	public var curSelected(default, set):Int = 0;
	var inGame:Bool;

	public var tooltipBackground:FlxSprite;
	public var tooltip:FlxText;

	public function new(itemList, inGame) {
		super();
		
		this.inGame = inGame;
		this.itemList = itemList;

		var bg = new Background(FlxColor.MAGENTA);
		bg.setGraphicSize(Std.int(bg.width * (1 + (itemList.length * 0.01))), Std.int(bg.height * (1 + (itemList.length * 0.01))));
		bg.updateHitbox();
		add(bg);

		var curY = 0.0;
		var curIndex = -1;
		for (option in itemList) {
			curIndex++;
			option.ID = curIndex;
			option.y += curY + (curIndex * 15);
			curY += option.height + 25;
			option.scrollFactor.set(1, 1);
			items.add(option);

			if (option.hasCheckBox) {
				option.checkbox.x = option.x + option.width + 10;
				option.checkbox.y = option.y - 50;
				option.checkbox.ID = curIndex;
				option.checkbox.scrollFactor.set(option.scrollFactor.x, option.scrollFactor.y);
				checkboxes.add(option.checkbox);
			}
		}
		add(items);
		add(checkboxes);

		tooltipBackground = new FlxSprite(0, 0);
		tooltipBackground.makeGraphic(1,1);
		tooltipBackground.scrollFactor.set();
		tooltipBackground.alpha = 0.7;
		add(tooltipBackground);

		tooltip = new FlxText(0, FlxG.height * 0.9, 0, "", 25);
		tooltip.setFormat(Paths.font("vcr.ttf"), tooltip.size, FlxColor.WHITE);
		tooltip.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		tooltip.scrollFactor.set(0, 0);
		updateTooltip();
		add(tooltip);

		//if (inGame)
			//cameras = [PlayState.camStatic];

		cameras = [OptionsSubState.optionsCamera];

		camFollow = new FlxObject(FlxG.width / 2, 0, 0, 0);
		OptionsSubState.optionsCamera.follow(camFollow, LOCKON, 0.15);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.check(UI_UP)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected -= 1;
			updateTooltip();
		}

		if (Controls.check(UI_DOWN)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected += 1;
			updateTooltip();
		}

		items.forEach(function(alphab:Alphabet) {
			alphab.alpha = 0.6;

			if (alphab.ID == curSelected) {
				alphab.alpha = 1;
				camFollow.y = alphab.y + 100;
			}
		});

		if (Controls.check(ACCEPT)) {
			for (checkbox in checkboxes) {
				if (checkbox.ID == curSelected) {
					checkOption(curSelected);
					break;
				}
			}
		}

		if (Controls.check(BACK)) {
			Options.saveAll();
			Options.applyAll();
			closeSubState();
			FlxG.state.openSubState(new OptionsSubState(inGame));
		}
	}

	public function updateTooltip() {
		tooltip.text = itemList[curSelected].description;
		tooltip.screenCenter(X);

		tooltipBackground.makeGraphic(tooltip.frameWidth + 20, tooltip.frameHeight + 20, FlxColor.BLACK);
		tooltipBackground.setPosition(tooltip.x - 10, tooltip.y - 10);
	}

	public function setOptionText(i:Int, s:String) {
		for (alphab in items) {
			if (alphab.ID == i) {
				alphab.text = s;
				alphab.screenCenter(X);
				break;
			}
		}
	}

	public function checkOption(i:Int) {
		for (checkbox in checkboxes) {
			if (checkbox.ID == i) {
				checkbox.triggerChecked();
				break;
			}
		}
	}

	public var camFollow:FlxObject;

	function set_curSelected(value:Int):Int {
		if (value < 0)
			value = items.length - 1;

		if (value >= items.length)
			value = 0;
		return curSelected = value;
	}
}

class OptionItem extends Alphabet {
	public var checkbox:Checkbox;
	public var hasCheckBox:Bool;
	public var description:String;

	public function new(text, description, ?hasCheckBox = false, ?checkBoxValue = false, ?checkBoxCallback:(value:Bool) -> Void) {
		super(0, 0, text);
		this.description = description;

		this.hasCheckBox = hasCheckBox;
		scrollFactor.set();
		screenCenter(X);
		
		if (hasCheckBox) {
			checkbox = new Checkbox(x + width + 10, y, checkBoxValue);
			checkbox.hitCallback = checkBoxCallback;
			checkbox.scrollFactor.set();
		}
	}
}

class Checkbox extends AnimatedSprite {
	private var checked = false;

	public var hitCallback:(value:Bool) -> Void;

	public function new(X, Y, ?checked:Bool = false) {
		super(X, Y);

		this.checked = checked;

		frames = Paths.getSparrowAtlas('checkboxThingie');
		antialiasing = true;
		setGraphicSize(Std.int(frameWidth * 0.75));
        updateHitbox();

		animation.addByPrefix("unselected", "Check Box unselected", 24);
		animation.addByPrefix("selecting", "Check Box selecting animation", 24, false);
		animation.addByPrefix("selected", "Check Box Selected Static", 24);

		setOffset("unselected", 0, -25);
		setOffset("selecting", 19, 50);
		setOffset("selected", 10, 28);

		if (checked) playAnim("selected");
		else playAnim("unselected");

		animation.finishCallback = function(name:String) {
			if (name == "selecting")
				playAnim("selected");
		};
	}

	public function triggerChecked() {
		checked = !checked;
		trace("checking " + checked);
		hitCallback(checked);
		if (checked)
			playAnim("selecting");
		else
			playAnim("unselected");
	}
}

class Background extends FlxSprite {
	public function new(Color:FlxColor, ?onlyColor:Bool = false) {
		super(-80);

		loadGraphic(Paths.image('menuDesat'));
		if (onlyColor) {
			makeGraphic(frameWidth, frameHeight, Color);
		}
		scrollFactor.set(0, 0.15);
		setGraphicSize(Std.int(width * 1.1));
		updateHitbox();
		screenCenter();
		antialiasing = true;
		color = Color;
	}
}

class OptionsSkinSubState extends FlxSubState {
	var inGame = false;
	
	var skinPaths:Array<String> = [];

	override public function new(character, ?inGame) {
		super();

		this.inGame = inGame;
		this.character = character;

		var bg = new Background(FlxColor.BLACK, true);
		bg.alpha = 0.7;
		add(bg);

		grpTexts = new FlxTypedGroup<Alphabet>();
		grpIcons = new FlxTypedGroup<HealthIcon>();

		character_path = Paths.modsLoc + "/skins/" + character + "/";

		skinPaths = [];

		var i = 0;
		addText(i, "Vanilla", 20, 20, false, character);
		for (file in FileSystem.readDirectory(character_path)) {
			var path = haxe.io.Path.join([character_path, file]);
			if (FileSystem.isDirectory(path)) {
				i++;
				addText(i, file, grpIcons.members[0].x, grpIcons.members[0].y + (100 * i), true, path + "/icon.png");
			}
		}
		add(grpIcons);
		add(grpTexts);

		curSelected = 0;

		CoolUtil.resetCameraScroll();

		if (inGame)
			cameras = [PlayState.camStatic];
	}

	function addText(index:Int, name:String, x:Float, y:Float, isPath:Bool = true, arg:String) {
		if (name == "Vanilla") {
			skinPaths.push(null);
		}
		else {
			skinPaths.push(name);
		}

		var icon = new HealthIcon(null);
		icon.ID = index;
		if (isPath) {
			icon.setCharFromPath(arg);
		}
		else {
			icon.setChar(arg);
		}
		icon.setPosition(x, y);
		icon.setGraphicSize(Std.int(icon.width * 0.8));
		icon.updateHitbox();
		grpIcons.add(icon);

		var alphabet = new Alphabet(icon.x + icon.width + 10, icon.y + (icon.height / 4), name, false, false, 0.8);
		alphabet.ID = index;
		alphabet.fontColor = FlxColor.WHITE;
		grpTexts.add(alphabet);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.check(UI_UP)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected--;
		}

		if (Controls.check(UI_DOWN)) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected++;
		}

		if (Controls.check(BACK)) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			closeSubState();
			FlxG.state.openSubState(new OptionsPrefencesSubState(inGame));
		}

		if (Controls.check(ACCEPT)) {
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			if (grpTexts.members[curSelected].text == "Vanilla") {
				switch (character) {
					case "bf":
						Options.customBf = false;
						if (inGame)
							PlayState.bf = new Boyfriend(PlayState.bf.x, PlayState.bf.y, PlayState.SONG.player1);
					case "gf":
						Options.customGf = false;
						if (inGame)
							PlayState.gf = new Character(PlayState.gf.x, PlayState.gf.y, PlayState.gfVersion);
					case "dad":
						Options.customDad = false;
						if (inGame)
							PlayState.dad = new Character(PlayState.dad.x, PlayState.dad.y, PlayState.SONG.player2);
				}
			}
			else {
				switch (character) {
					case "bf":
						Options.customBf = true;
						Options.customBfPath = character_path + skinPaths[curSelected] + "/";
						if (inGame) {
							PlayState.bf = new Boyfriend(PlayState.bf.x, PlayState.bf.y, "bf-custom", true);
							PlayState.instance.updateCharPos(character);
						}
					case "gf":
						Options.customGf = true;
						Options.customGfPath = character_path + skinPaths[curSelected] + "/";
						if (inGame) {
							PlayState.gf = new Character(PlayState.gf.x, PlayState.gf.y, "gf-custom", false, false, true);
							PlayState.instance.updateCharPos(character);
						}
					case "dad":
						Options.customDad = true;
						Options.customDadPath = character_path + skinPaths[curSelected] + "/";
						if (inGame) {
							PlayState.dad = new Character(PlayState.dad.x, PlayState.dad.y, "dad-custom", false, false, true);
							PlayState.instance.updateCharPos(character);
						}
				}
			}
			Options.saveAll();
			if (inGame) {
				PlayState.instance.updateChar(character);
			}
		}
	}

	var curSelected(default, set):Int;

	function set_curSelected(value:Int):Int {
		if (value < 0)
			value = grpTexts.length - 1;

		if (value >= grpTexts.length)
			value = 0;

		grpTexts.forEach(function(txt:Alphabet) {
			if (txt.ID == value)
				txt.fontColor = FlxColor.YELLOW;
			else
				txt.fontColor = FlxColor.WHITE;
		});
		
		return curSelected = value;
	}

	var grpTexts:FlxTypedGroup<Alphabet>;
	var grpIcons:FlxTypedGroup<HealthIcon>;

	var character_path:String;

	var character:String;
}

class ControlsItem extends FlxTypedSpriteGroup<Alphabet> {
	public var key:Alphabet;
	public var bind1:Alphabet;
	public var bind2:Alphabet;

	public function new(keyText:String, bind1Text:String, bind2Text:String) {
		super();

		key = new Alphabet(0, 0, keyText, true);
		key.scrollFactor.set();
		key.x += 150;

		bind1 = new Alphabet(key.x + 450, 0, bind1Text, false);
		bind1.scrollFactor.set();

		bind2 = new Alphabet(bind1.x + 300, 0, bind2Text, false);
		bind2.scrollFactor.set();

		add(key);
		add(bind1);
		add(bind2);
	}
}

class OptionsControlsSubstate extends FlxSubState {
	public var items = new FlxTypedGroup<ControlsItem>();

	public var curSelected:Int = 0;
	public var curTab:Int = 0;
	var inGame:Bool;

	var camFollow:FlxObject;
	var thisCamera:FlxCamera;

	var waiting:Bool;
	var inputText:FlxText;

	public function new(inGame) {
		super();
		
		this.inGame = inGame;

		var bg = new Background(FlxColor.MAGENTA);
		bg.scrollFactor.y = 0.1;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var curY = 400.0;
		var curIndex = -1;
		for (keyType in Type.allEnums(KeyType)) {
			curIndex++;

			var name = keyType.getName();
			var bind1:String = KeyBind.fromType(keyType)[0];
			var bind2:String = KeyBind.fromType(keyType)[1];

			if (bind1 == null)
				bind1 = "---";
			if (bind2 == null)
				bind2 = "---";
			
			var shit = new ControlsItem(name, bind1, bind2);
			shit.ID = curIndex;
			shit.y += curY;
			curY += shit.key.height + 25;
			items.add(shit);
		}
		add(items);

		items.forEach(function(item:ControlsItem) {
			if (item.ID == 0) {
				var keyText = new Alphabet(item.key.x, item.bind1.y - item.bind1.height * 1.5, "Key", true);
				var bindsText = new Alphabet( item.bind1.x + ((item.bind2.x - item.bind1.x) / 2) , item.bind1.y - item.bind1.height * 1.5, "Binds", true);

				add(keyText);
				add(bindsText);
			}
		});

		inputText = new FlxText(0, 0, 0, "Waiting for input...");
		inputText.scrollFactor.set();
		inputText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputText.screenCenter();
		inputText.visible = false;
		add(inputText);
		
		thisCamera = new FlxCamera();

		FlxG.cameras.add(thisCamera, false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 0, 0);
		thisCamera.follow(camFollow, LOCKON, 0.04);

		cameras = [thisCamera];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		inputText.visible = waiting;

		if (waiting) {
			waitForInput();
		} 
		else {
			if (Controls.check(UI_UP)) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected -= 1;
			}
	
			if (Controls.check(UI_DOWN)) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected += 1;
			}

			if (Controls.check(ACCEPT)) {
				waiting = true;
			}

			if (Controls.check(UI_RIGHT))
				curTab = 1;
	
			if (Controls.check(UI_LEFT))
				curTab = 0;

			if (Controls.check(BACK)) {
				Options.saveAll();
				Options.applyAll();
				closeSubState();
				FlxG.cameras.remove(thisCamera);
				FlxG.state.openSubState(new OptionsGameplaySubState(inGame));
			}
		}

		if (curSelected < 0)
			curSelected = items.length - 1;

		if (curSelected >= items.length)
			curSelected = 0;

		items.forEach(function(item:ControlsItem) {
			item.key.alpha = 0.5;
			item.bind1.alpha = 0.5;
			item.bind2.alpha = 0.5;

			if (item.ID == curSelected) {
				camFollow.y = item.y + 100;

				item.key.alpha = 1;

				if (curTab == 0)
					item.bind1.alpha = 1;
				else
					item.bind2.alpha = 1;
			}
		});
	}

	function waitForInput() {
		waiting = true;

		items.forEach(function(item:ControlsItem) {
			if (item.ID == curSelected) {
				if (curTab == 0)
					item.bind1.text = "...";
				else
					item.bind2.text = "...";

				if (FlxG.keys.anyJustPressed([ANY])) {
					waiting = false;
					var curKey = FlxG.keys.getIsDown()[0].ID;
					Controls.bind(KeyBind.typeFromString(item.key.text), curKey, curTab);
					if (curTab == 0)
						item.bind1.text = curKey.toString();
					else
						item.bind2.text = curKey.toString();
				}
			}
		});
	}
}

class NoteOption extends FlxSubState {
	public var notes:FlxSpriteGroup;
	public var colors:Array<FixedHSLFlxColorShit> = [];

	public function new(inGame:Bool) {
		super();
		this.inGame = inGame;
	}
	
	override public function create() {
		var bg = new Background(FlxColor.MAGENTA);
		add(bg);

		notes = new FlxSpriteGroup();

		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, 0);
			babyArrow.ID = i + 1;
			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'green0');
			babyArrow.animation.addByPrefix('blue', 'blue0');
			babyArrow.animation.addByPrefix('purple', 'purple0');
			babyArrow.animation.addByPrefix('red', 'red0');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.sizeShit));
			
			switch (i) {
				case 0:
					babyArrow.animation.play('purple');
				case 1:
					babyArrow.animation.play('blue');
				case 2:
					babyArrow.animation.play('green');
				case 3:
					babyArrow.animation.play('red');
			}
			babyArrow.updateHitbox();
			babyArrow.x += (Note.getSwagWidth(4) - (4 > 5 ? 2 * (4 - 5) : 0)) * i;
			colors.push(new FixedHSLFlxColorShit(babyArrow.color.hue, babyArrow.color.saturation, babyArrow.color.brightness));
			notes.add(babyArrow);
		}
		add(blackSqr);
		add(notes);
		notes.screenCenter(X);
		notes.y += 100;

		curSelected = 0;

		notes.members[0].shader = new ColorShader();

		CoolUtil.resetCameraScroll();

		super.create();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.check(UI_RIGHT))
			curSelected++;

		if (Controls.check(UI_LEFT))
			curSelected--;

		if (Controls.check(BACK)) {
			Options.saveAll();
			Options.applyAll();
			closeSubState();
			FlxG.state.openSubState(new OptionsPrefencesSubState(inGame));
		}

		if (FlxG.keys.pressed.Y)
			notes.members[curSelected].colorTransform.redOffset += 1;
		if (FlxG.keys.pressed.H)
			notes.members[curSelected].colorTransform.redOffset -= 1;

		if (FlxG.keys.pressed.U)
			notes.members[curSelected].colorTransform.greenOffset += 0.01;
		if (FlxG.keys.pressed.J)
			notes.members[curSelected].colorTransform.greenOffset -= 0.01;

		if (FlxG.keys.pressed.I)
			notes.members[curSelected].colorTransform.blueOffset += 0.01;
		if (FlxG.keys.pressed.K)
			notes.members[curSelected].colorTransform.blueOffset -= 0.01;

		/*
		if (FlxG.keys.pressed.O)
			colors[curSelected].alpha++;
		if (FlxG.keys.pressed.L)
			colors[curSelected].alpha--;
		*/
	}

	var blackSqr:FlxSprite = new FlxSprite();

	var curSelected(default, set):Int;

	function set_curSelected(value:Int):Int {
		if (value < 0)
			value = notes.length - 1;

		if (value >= notes.length)
			value = 0;
		curSelected = value;

		blackSqr.makeGraphic(Std.int(notes.members[curSelected].width), Std.int(notes.members[curSelected].height), FlxColor.BLACK);
		blackSqr.alpha = 0.6;
		blackSqr.setPosition(notes.members[curSelected].x, notes.members[curSelected].y);

		return curSelected;
	}

	var inGame:Bool;
}


/**
 * fuck, typo
 * unused
 */
class FixedHSLFlxColorShit {
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 1;

	public function new(hue:Float = 0, saturation:Float = 0, brightness:Float = 1) {
		this.hue = hue;
		this.saturation = saturation;
		this.brightness = brightness;
	}

	function set_hue(value:Float):Float {
		if (value > 360)
			value = 360;
		if (value < 0)
			value = 0;
		return hue = value;
	}

	function set_saturation(value:Float):Float {
		if (value > 1)
			value = 1;
		if (value < 0)
			value = 0;
		return saturation = value;
	}

	function set_brightness(value:Float):Float {
		if (value > 1)
			value = 1;
		if (value < 0)
			value = 0;
		return brightness = value;
	}

	public function getColor():FlxColor {
		return FlxColor.fromHSB(hue, saturation, brightness);
	}
}
package;

import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import lime.media.openal.ALBuffer;
import lime.media.openal.AL;
import lime.media.openal.ALC;
import lime.media.AudioManager;
import Main.Notification;
import flixel.FlxSubState;
import multiplayer.Lobby.LobbySelectorState;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState {
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options', 'multiplayer'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var skipTrans:Bool;

	public function new(?skipTrans:Bool = false) {
		super();

		this.skipTrans = skipTrans;
	}

	override function create() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (TitleState.isFridayNight)
			Achievement.unlock("fridayNight");

		if (!skipTrans) {
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
		} else {
			transIn = new TransitionData(NONE);
			transOut = new TransitionData(NONE);
		}

		selectedSomethin = false;

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.2 - (optionShit.length / 100) * 1.7;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = bg.scrollFactor.y;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(0, -50 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0.3);
			menuItem.antialiasing = true;
		}

		var engineVer:FlxText = new FlxText(5, FlxG.height - (18 * 2), 0, '${Main.ENGINE_NAME} ${Main.ENGINE_VER}', 12);
		engineVer.scrollFactor.set();
		engineVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(engineVer);

		var versionShit:FlxText = new FlxText(5, FlxG.height - (18 * 1), 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();

		FlxG.camera.follow(camFollow, null, 0.15);
	}

	public static var selectedSomethin:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin) {
			if (Controls.check(UI_UP, JUST_PRESSED)) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (Controls.check(UI_DOWN, JUST_PRESSED)) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (Controls.check(BACK, JUST_PRESSED)) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new TitleState());
			}

			if (Controls.check(ACCEPT, JUST_PRESSED)) {
				switch (optionShit[curSelected]) {
					case 'donate':
						#if linux
						Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
						#else
						FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
						#end
					default:
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));

						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

						menuItems.forEach(function(spr:FlxSprite) {
							if (curSelected != spr.ID) {
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween) {
										spr.kill();
									}
								});
							}
							else {
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
									var daChoice:String = optionShit[curSelected];

									switch (daChoice) {
										case 'story mode':
											FlxG.switchState(new StoryMenuState());
										case 'freeplay':
											FlxG.switchState(new FreeplayState());
										case 'options':
											transOut = new TransitionData(NONE);
											openSubState(new OptionsSubState());
										case 'multiplayer':
											FlxG.switchState(new LobbySelectorState());
									}
								});
							}
						});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});
	}

	override public function onFocusLost():Void {
		super.onFocusLost();
		
		FlxG.autoPause = false;
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}

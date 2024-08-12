package;

import openfl.media.Sound;
import Alphabet.AlphaCharacter;
import OptionsSubState.Background;
import clipboard.Clipboard;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import sys.FileSystem;
import sys.io.File;

class DBox extends DialogueBoxOg {
    public var dialogues:Array<Alphabet>;

    public function new(Text:String) {
        super(null, false);

        var splittedDialogue = ["coolSwag"];

        dialogues = new Array<Alphabet>();

        var index = 0;
        for (dialogue in splittedDialogue) {
            dialogues[index] = new Alphabet(box.x + 40, box.y + 90, Text, false, false, 0.7);
            add(dialogues[0]);
            index++;
        }
    }
}

class DialogueBoxEditor extends FlxState {
    public var dBox:DBox;

    private var texts:Array<String> = ["coolswag"];
    public var curIndex:Int = -1;
    public var textsProperties:Array<String> = ["dad,false,normal"];

    var dialoguePath:String = "";

    var hasFocus = false;

    public function new() {
        super();

        if (PlayState.SONG != null) {
            dialoguePath = Paths.getSongPath(PlayState.SONG.song, true) + "dialogue.txt";

            if (FileSystem.exists(dialoguePath)) {
                var fileContent = File.getContent(dialoguePath);
                var index = -1;
                for (line in fileContent.split("\n")) {
                    index++;
                    var splitName:Array<String> = line.split(":");
                    textsProperties[index] = splitName[1];
                    texts[index] = line.substr(splitName[1].length + 2).trim();
                }
            }
            /*
            //repair outdated dialogue
            for (i in 0...textsProperties.length) {
                if (arrayProperties(i)[2] == null) {
                    changePropertiesValue(2, "normal", i);
                }
            }
            */
        }
        trace(textsProperties);
        curIndex = 0;

        var bg = new Background(FlxColor.WHITE);
        add(bg);

        dBox = new DBox(texts[curIndex]);
        dBox.scrollFactor.set();
        add(dBox);

		uiBox = new UIWindow(0, 20, 300, 400, "Dialogue ToolBar");
		uiBox.x = FlxG.width - uiBox.width - 20;
        uiBox.scrollFactor.set(0, 0);
		add(uiBox);

        addGeneralUI();

        var info:FlxText = new FlxText(0, 0, 0, "", 15);
		info.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		info.text = 
        "CTRL + ENTER - Reposition Text\n" +
        "CTRL + S - Save the dialogue\n" +
        "CTRL + F - Flip the box\n" +
        "CTRL + ARROWS - Change the dialogues\n'"
        ;
		// flx text is bugged with \n
		info.scrollFactor.set();
		info.y = 20;
		info.x = 10;
		add(info);

		FlxG.sound.music.stop();
		if (Sound.fromFile(Paths.PEinst('test')) != null) {
			FlxG.sound.playMusic(Sound.fromFile(Paths.PEinst('test')));
			Conductor.changeBPM(150);
		}
    }

    function updateGUI() {
        if (arrayProperties()[2] == null) {
            changePropertiesValue(2, "normal");
        }
        inputChar.text = arrayProperties()[0];
        dialogStyle.selectedLabel = arrayProperties()[2];
        dBox.box.animation.play(arrayProperties()[2]);
    }

    function updateShit() {
        dBox.style = arrayProperties()[2];
        dBox.talkingRight = CoolUtil.strToBool(arrayProperties()[1]);
        dBox.curCharacter = arrayProperties()[0];
        dBox.updatePortraits();
        dBox.box.flipX = !dBox.talkingRight;
    }

    var backspaceTime = 0;

    override function update(elapsed) {
        //hasFocus is updated here
        super.update(elapsed);
        
        deleteDialogue.visible = (curIndex == texts.length - 1 && texts.length > 1);

		backspaceTime = (FlxG.keys.pressed.BACKSPACE ? backspaceTime + 1 : 0);

		if (backspaceTime >= 100 && backspaceTime % 5 == 0) {
			texts[curIndex] = texts[curIndex].substring(0, texts[curIndex].length - 1);
			dBox.dialogues[0].remFromText();
        }

        FlxG.mouse.visible = true;

        updateShit();

        if (!hasFocus) {
            if (FlxG.keys.pressed.CONTROL) {
                if (FlxG.keys.justPressed.LEFT && curIndex >= 1) {
                    curIndex--;
                    dBox.dialogues[0].text = texts[curIndex];
                    updateGUI();
                    updateShit();
                }
                if (FlxG.keys.justPressed.RIGHT) {
                    curIndex++;
                    if (texts.length <= curIndex) {
                        texts[curIndex] = "coolswag" + curIndex;
                        textsProperties[curIndex] = "dad,false,normal";
                        trace("creating dialogue at " + curIndex);
                    }
					trace(texts[curIndex]);
                    dBox.dialogues[0].text = texts[curIndex];
                    updateGUI();
                    updateShit();
                }
                if (FlxG.keys.justPressed.F) {
                    var bool:Bool = !CoolUtil.strToBool(arrayProperties()[1]);
                    changePropertiesValue(1, bool);
                }
                if (FlxG.keys.justPressed.ENTER) {
                    dBox.dialogues[0].text = texts[curIndex];
                    updateShit();
                }
                if (FlxG.keys.justPressed.S) {
                    var finalDialogueFile = "";
                    var index = -1;
                    for (text in texts) {
                        index++;
                        var formattedText = text.replace("\n", "\\n");
                        finalDialogueFile += ':${textsProperties[index]}:${formattedText}';
                        if (index < texts.length - 1) {
                            finalDialogueFile += "\n";
                        }
                    }
                    CoolUtil.writeToFile(dialoguePath, finalDialogueFile);
                }
            }
            else {
                if (FlxG.keys.justPressed.ANY) {
                    var char = null;

                    var isDownArray = FlxG.keys.getIsDown();
                    for (key in isDownArray) {
                        if (key.ID.toString() == "SHIFT") {
							isDownArray.remove(key);
                        }
                    }

					if (isDownArray.length > 0) {
						if (AlphaCharacter.alphabet.indexOf(isDownArray[0].ID.toString().toLowerCase()) != -1) {
							if (FlxG.keys.pressed.SHIFT) {
								char = isDownArray[0].ID.toString().toUpperCase();
							}
							else {
								char = isDownArray[0].ID.toString().toLowerCase();
							}
						}
						switch (isDownArray[0].ID.toString()) {
							case "ONE":
								char = !FlxG.keys.pressed.SHIFT ? "1" : "!";
							case "TWO":
								char = !FlxG.keys.pressed.SHIFT ? "2" : "@";
							case "THREE":
								char = !FlxG.keys.pressed.SHIFT ? "3" : "#";
							case "FOUR":
								char = !FlxG.keys.pressed.SHIFT ? "4" : "$";
							case "FIVE":
								char = !FlxG.keys.pressed.SHIFT ? "5" : "%";
							case "SIX":
								char = !FlxG.keys.pressed.SHIFT ? "6" : "^";
							case "SEVEN":
								if (!FlxG.keys.pressed.SHIFT)
									char = "7";
							case "EIGHT":
								char = !FlxG.keys.pressed.SHIFT ? "8" : "*";
							case "NINE":
								char = !FlxG.keys.pressed.SHIFT ? "9" : "(";
							case "ZERO":
								char = !FlxG.keys.pressed.SHIFT ? "0" : ")";
							case "BACKSLASH":
								if (FlxG.keys.pressed.SHIFT)
									char = "|";
							case "GRAVEACCENT":
								if (FlxG.keys.pressed.SHIFT)
									char = "~";
                            case "PLUS":
								char = !FlxG.keys.pressed.SHIFT ? "=" : "+";
							case "MINUS":
								char = !FlxG.keys.pressed.SHIFT ? "-" : "_";
							case "SEMICOLON":
								char = !FlxG.keys.pressed.SHIFT ? ";" : ":";
							case "COMMA":
								char = !FlxG.keys.pressed.SHIFT ? "," : "<";
							case "PERIOD":
								char = !FlxG.keys.pressed.SHIFT ? "." : ">";
							case "LBRACKET":
								if (!FlxG.keys.pressed.SHIFT)
									char = "[";
							case "RBRACKET":
								if (!FlxG.keys.pressed.SHIFT)
									char = "]";
							case "QUOTE":
								if (!FlxG.keys.pressed.SHIFT)
									char = "'";
                            case "SLASH":
								if (FlxG.keys.pressed.SHIFT)
									char = "?";
						}
						if (char != null) {
							texts[curIndex] += char;
							dBox.dialogues[0].text += char;
						}
                    }
                }
    
                if (FlxG.keys.justPressed.BACKSPACE) {
                    texts[curIndex] = texts[curIndex].substring(0, texts[curIndex].length - 1);
                    dBox.dialogues[0].remFromText();
                }
        
                if (FlxG.keys.justPressed.SPACE) {
                    texts[curIndex] += " ";
                    dBox.dialogues[0].text += " ";
                }
        
                if (FlxG.keys.justPressed.ENTER) {
                    texts[curIndex] += "\n";
                    dBox.dialogues[0].text += "\n";
                }
        
                if (FlxG.keys.pressed.ESCAPE) {
                    var playstate = new PlayState();
                    playstate.forceDialogueBox = true;
                    LoadingState.loadAndSwitchState(playstate);
                }
            }
        }
        hasFocus = false;
    }

    function arrayProperties(?propertIndex = null):Array<String> {
        if (propertIndex == null) propertIndex = curIndex;
        return textsProperties[propertIndex].split(",");
    }

    function changePropertiesValue(index:Int, value:Dynamic, ?propertIndex = null) {
        if (propertIndex == null) propertIndex = curIndex;
        value = Std.string(value);
        var array:Array<String> = arrayProperties();
        var finalString = "";
        var indexx = -1;
        for (item in array) {
            indexx++;
            if (indexx == index) {
                finalString += value;
            }
            else {
                finalString += item;
            }
            if (indexx < array.length - 1) {
                finalString += ",";
            }
        }
        textsProperties[propertIndex] = finalString;
        if (propertIndex == curIndex)
            updateShit();
        trace(textsProperties[propertIndex]);
    }

    function addGeneralUI():Void {
        inputChar = new UIInputText(10, 20, 85 * 2, arrayProperties()[0], 8);
		inputChar.callback = function onType(s, enter) {
            changePropertiesValue(0, s);
            hasFocus = true;
		}
		var text = new FlxText(inputChar.x, inputChar.y - 15, 0, "Character:");

        dialogStyle = new UIDropDownMenu(inputChar.x, 20 + inputChar.height + inputChar.y, ["normal", "loud"], (s, i) -> {
            changePropertiesValue(2, s);
            updateShit();
            updateGUI();
        }, 2);
        dialogStyle.selectedLabel = arrayProperties()[2];
		var text2 = new FlxText(dialogStyle.x, dialogStyle.y - 15, 0, "Box Style:");

		deleteDialogue = new FlxButton(dialogStyle.x, dialogStyle.y + 60, "Delete Dialogue", () -> {
			texts.pop();

			curIndex--;
			dBox.dialogues[0].text = texts[curIndex];
			updateGUI();
			updateShit();
        });

        uiBox.add(inputChar);
        uiBox.add(text);
        uiBox.add(dialogStyle);
        uiBox.add(text2);
		uiBox.add(deleteDialogue);
	}

    var inputChar:UIInputText;

	var uiBox:UIWindow;

	var dialogStyle:UIDropDownMenu;

	var deleteDialogue:FlxButton;
}
package;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

enum KeyType {
	LEFT;
	DOWN;
	UP;
	RIGHT;
	UI_LEFT;
	UI_DOWN;
	UI_UP;
	UI_RIGHT;

	ACCEPT;
	BACK;
	PAUSE;
}

class KeyBind {
	public static var controlsMap:Map<KeyType, Array<FlxKey>> = new Map<KeyType, Array<FlxKey>>();

	public static function setToDefault():Void {
		controlsMap.set(UP, [W, FlxKey.UP]);
		controlsMap.set(LEFT, [A, FlxKey.LEFT]);
		controlsMap.set(RIGHT, [D, FlxKey.RIGHT]);
		controlsMap.set(DOWN, [S, FlxKey.DOWN]);
		controlsMap.set(UI_UP, [W, FlxKey.UP]);
		controlsMap.set(UI_LEFT, [A, FlxKey.LEFT]);
		controlsMap.set(UI_RIGHT, [D, FlxKey.RIGHT]);
		controlsMap.set(UI_DOWN, [S, FlxKey.DOWN]);
		controlsMap.set(ACCEPT, [ENTER, SPACE]);
		controlsMap.set(BACK, [ESCAPE, BACKSPACE]);
		controlsMap.set(PAUSE, [ENTER, ESCAPE]);
	}

	public static function fromType(keyType:KeyType):Array<FlxKey> {
		return controlsMap.get(keyType);
	}

	public static function typeFromString(s:String):KeyType {
		return (((Reflect.field(KeyType, s))):KeyType);
	}
}

class Controls {
	/**
	 * Bind key to keyType
	 * @param keyType the type of the key ex. `UP` is for `UP` arrow and `UI_UP` is for going up in menu
	 * @param newKey the new key it should be something like `<key>` or `FlxKey.<key>`
	 * @param arrayIndex the index that should be replaced. for example `PAUSE` has two array keys in it, the first one is `0` and 2nd is `1` and so on
	 */
	public static function bind(keyType:KeyType, newKey:FlxKey, ?arrayIndex:Int = 0) {
		var shit = KeyBind.fromType(keyType);
		shit[arrayIndex] = newKey;
		KeyBind.controlsMap.set(keyType, shit);
    }

    /**
     * Check if specific key is pressed
     * @param keyType the type of the key ex. `UP` is for up arrow and `UI_UP` is for going up in menu
     * @param action the status of `keyType` to check if is `true`
     */
    public static function check(keyType:KeyType, ?action:FlxInputState = JUST_PRESSED) {
		var finalValue = false;
		switch (keyType) {
			case UI_UP:
				if (FlxG.mouse.wheel == 1)
					return true;
			case UI_DOWN:
				if (FlxG.mouse.wheel == -1)
					return true;
			// case ACCEPT:
			// 	if (FlxG.mouse.justPressed)
			// 		return true;
			// case BACK:
			// 	if (FlxG.mouse.justPressedRight)
			// 		return true;
			default:
		}
		for (key in KeyBind.fromType(keyType)) {
			finalValue = FlxG.keys.checkStatus(key, action);
			if (finalValue)
				return true;
		}
		return finalValue;
    }
}
import lime.system.System;
import lime.app.IModule;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Mouse;
import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.events.Event;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Sprite;

//this is where the magic happens

class BorderlessWindowShit extends Sprite {
    public var minimalize:Bitmap;
	public var full:Bitmap;
	public var close:Bitmap;

	private var oldMousePos:Array<Float> = [0, 0];

    var secondSinceLastMessage = 0;

	private var isMousePressed:Bool;

    public function new() {
        super();

		addEventListener(Event.ADDED_TO_STAGE, create);
    }

    function create(e) {
		minimalize = new Bitmap(Assets.getBitmapData(Paths.image("minimalize", "exclude")));
		minimalize.scaleX = 0.4;
		minimalize.scaleY = 0.4;
        minimalize.alpha = 0.5;
        minimalize.visible = false;

		full = new Bitmap(Assets.getBitmapData(Paths.image("full", "exclude")));
		full.scaleX = 0.4;
		full.scaleY = 0.4;
		full.alpha = 0.5;
		full.visible = false;

		close = new Bitmap(Assets.getBitmapData(Paths.image("close", "exclude")));
		close.scaleX = 0.4;
		close.scaleY = 0.4;
		close.alpha = 0.5;
		close.visible = false;

		addChild(minimalize);
		addChild(full);
		addChild(close);

		stage.addEventListener(MouseEvent.CLICK, onMousePressed);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, e -> isMousePressed = false);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, e -> isMousePressed = true);
    }

	override public function __enterFrame(deltaTime) {
		super.__enterFrame(deltaTime);

		if (!Lib.application.window.borderless) {
			close.visible = false;
			full.visible = false;
			minimalize.visible = false;
			return;
        }

		close.x = Lib.application.window.width - close.width;
		full.x = close.x - full.width;
		minimalize.x = full.x - minimalize.width;
        
        close.visible = collapsesMouse(close);
		full.visible = collapsesMouse(full);
		minimalize.visible = collapsesMouse(minimalize);
    }

	function onMouseMove(event:MouseEvent) {
        if (!Lib.application.window.borderless)
            return;

		if (Lib.current.mouseY < Lib.application.window.y + close.height) {
			Mouse.show();

			if (isMousePressed) {
				Lib.application.window.move(
                    Std.int(Lib.application.window.x + (Lib.current.mouseX - oldMousePos[0])),
					Std.int(Lib.application.window.y + (Lib.current.mouseY - oldMousePos[1]))
                );
			}
        }
        else
            Mouse.hide();

		oldMousePos = [Lib.current.mouseX, Lib.current.mouseY];
    }

    function onMousePressed(event:MouseEvent) {
		if (!Lib.application.window.borderless)
			return;
        
        if (close.visible)
            Lib.application.window.close();
        else if (full.visible)
			Lib.application.window.maximized = !Lib.application.window.maximized;
        else if (minimalize.visible)
            Lib.application.window.minimized = true;
    }

	static function collapsesMouse(bitmap:Bitmap) {
		return Lib.current.mouseX > bitmap.x && Lib.current.mouseX < (bitmap.width + bitmap.x)
			&& Lib.current.mouseY > bitmap.y && Lib.current.mouseY < (bitmap.height + bitmap.y);
    }
    
    function sendDebug(msg:String) {
		if (secondSinceLastMessage != Date.now().getSeconds())
            Sys.print("\n[ " + Date.now().toString() + " ] : " + msg);
        else
            Sys.print(msg);

		secondSinceLastMessage = Date.now().getSeconds();
    }
}
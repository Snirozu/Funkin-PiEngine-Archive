package;

import haxe.macro.Context;
import haxe.macro.Expr;

class MonitorMacro {
	public static macro function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		var pos:Position = Context.currentPos();
		/*
		untyped {
			fields = Context.getBuildFields();
			pos = Context.currentPos();
		}
		*/

		var daFields = [];
        for (field in fields) {
			if (field.kind.getName() == "FFun") {
				fields.remove(field);

				//var func:Function = Type.enumParameters(field.kind)[0];
				var func:Function = field.kind.getParameters()[0];

				func.expr = macro {
					var ___callTime = Sys.time();
					${func.expr}
					Monitor.update($v{Context.getLocalClass().get().name} + "." + $v{field.name}, Sys.time() - ___callTime);
				};

				field.kind = FFun(func);
				daFields.push(field);
            }
        }
		return fields.concat(daFields);
    }
}
package;

import flixel.math.FlxMath;

class Accuracy {
    //this is not the best accuracy system but it works fine

    private var songNotesCount:Int = 0;

    private var notesAccuracySum:Float = 0;

    public function new(?songNotesCount:Int = 0) {
        this.songNotesCount = songNotesCount * 4;
        notesAccuracySum = this.songNotesCount;
    }

    public function addNote() {
        songNotesCount += 4;
		notesAccuracySum += 4;
    }

    public function judge(accuracy:String, ?sussyLength:Float = 1) {
        if (accuracy != null) {
			if (Options.accuracyType == PROGRESSIVE)
				addNote();
            switch accuracy {
                case "missSus":
                    notesAccuracySum -= 4;
                case "miss":
                    notesAccuracySum -= 4;
                case "shit":
                    notesAccuracySum -= 3;
                case "bad":
                    notesAccuracySum -= 2;
                case "good":
                    notesAccuracySum -= 1;
                case "sick":
                    notesAccuracySum -= 0;
            }
        }
        PlayState.instance.sendMultiplayerMessage('ACC::${getAccuracyPercent()}');
    }
    public function getAccuracyPercent():String {
        return FlxMath.roundDecimal(notesAccuracySum / songNotesCount, 4) * 100 + "%";
    }
}

enum abstract AccuracyType(Int) from Int to Int {
    var REGRESSIVE = 0;
    var PROGRESSIVE = 1;

    public function getName():String {
        switch (this) {
            case REGRESSIVE:
                return "Regressive";
            case PROGRESSIVE:
                return "Progressive";
        }
        return null;
    }
}
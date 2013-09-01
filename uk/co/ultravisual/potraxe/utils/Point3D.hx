package uk.co.ultravisual.potraxe.utils;
import flash.errors.IllegalOperationError;

class Point3D {
    private var pointsArray:Array<Float>;

    public function new(x:Float = 0.0, y:Float = 0.0, z:Float = 0.0):Void {
        pointsArray = [x, y, z];
    }

    public function getProperty(name:Dynamic):Dynamic {
        if (name == 0 || name == "x") return pointsArray[0];
        if (name == 1 || name == "y") return pointsArray[1];
        if (name == 2 || name == "z") return pointsArray[2];
        return null;
    }

    public function hasProperty(name:Dynamic):Bool {
        return getProperty(name) != null;
    }

    public function setProperty(name:Dynamic, value:Dynamic):Void {
        if (name == 0 || name == "x") {pointsArray[0] = value; return;}
        if (name == 1 || name == "y") {pointsArray[1] = value; return;}
        if (name == 2 || name == "z") {pointsArray[2] = value; return;}
        throw new IllegalOperationError();
    }

    public function toString():String {
        return "(" + pointsArray[0] + "," + pointsArray[1] + "," + pointsArray[2] + ")";
    }
}
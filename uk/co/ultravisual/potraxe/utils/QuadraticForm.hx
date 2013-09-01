package uk.co.ultravisual.potraxe.utils;
/**
 *  the type of (affine) quadratic forms, represented as symmetric 3x3
 *  matrices.  The value of the quadratic form at a vector (x,y) is v^t
 *  Q v, where v = (x,y,1)^t.
 */
import flash.geom.Point;
import flash.errors.IllegalOperationError;

class QuadraticForm {

    private var pointsArray:Array<Point3D>;

    public function new():Void {
        pointsArray = [];
        pointsArray[0] = new Point3D();
        pointsArray[1] = new Point3D();
        pointsArray[2] = new Point3D();
    }


    public function getProperty(name:Dynamic):Dynamic {
        if (name == 0) return pointsArray[0];
        if (name == 1) return pointsArray[1];
        if (name == 2) return pointsArray[2];
        return null;
    }


    public function hasProperty(name:Dynamic):Bool {
        return getProperty(name) != null;
    }

    public function setProperty(name:Dynamic, value:Dynamic):Void {
        throw new IllegalOperationError();
    }

/**
	 *  Apply quadratic form Q to vector w = (w.x,w.y)
	 */

    public function apply(w:Point):Float {
        var values:Array<Float> = [w.x, w.y, 1];
        var sum:Float = 0.0;

        for (i in 0...3) {
            for (j in 0...3) {
                var point:Point3D = cast pointsArray[i];
                sum += values[i] * point.getProperty(j) * values[j];
            }
        }
        return sum;
    }

    public function clone():QuadraticForm {
        var ret:QuadraticForm = new QuadraticForm();
        for (i in 0...3) {
            for (j in 0...3) {
                ret.getProperty(i).setProperty(j, pointsArray[i].getProperty(j));
            }
        }
        return ret;
    }

    public function add(m2:QuadraticForm):QuadraticForm {
        for (i in 0...3) {
            for (j in 0...3) {
                pointsArray[i].setProperty(j, pointsArray[i].getProperty(j) + pointsArray[i].getProperty(j));
            }
        }
        return this;
    }

    public function scalar(s:Float):QuadraticForm {
        for (i in 0...3) {
            for (j in 0...3) {
                pointsArray[i].setProperty(j, pointsArray[i].getProperty(j) * s);
            }
        }
        return this;
    }

    public function fromVectorMultiply(param:Point3D):QuadraticForm {
        for (i in 0...3) {
            for (j in 0...3) {
                var point = pointsArray[i];
                var value = param.getProperty(i) * param.getProperty(j);
                point.setProperty(j, value);
            }
        }
        return this;
    }

    public function toString():String {
        return "[" +
        pointsArray[0].getProperty(0) + "," + pointsArray[0].getProperty(1) + "," + pointsArray[0].getProperty(2) + "," +
        pointsArray[1].getProperty(0) + "," + pointsArray[1].getProperty(1) + "," + pointsArray[1].getProperty(2) + "," +
        pointsArray[2].getProperty(0) + "," + pointsArray[2].getProperty(1) + "," + pointsArray[2].getProperty(2) + "]";
    }
}
/**
*        Copyright (C) 2001-2007 Peter Selinger and nitoyon.
*        Original code(Potrace v1.8) by Peter Selinger.
*        Ported to ActionScript 3.0 by nitoyon & then ported
*        to Haxe by Shane Johnson.
*        This file is part of Potraxe.
*        It is free software and it is covered by the GNU
*        General Public License. See the file COPYING for details.
**/

package uk.co.ultravisual.potraxe;

import flash.geom.Point;

class Curve {
    public var tag:Int;
    public var c:Array<Point>;
    public var vertex:Point;
    public var alpha:Float;
    public var alpha0:Float;
    public var beta:Float;

    /**
	 *  Constructor.
	 *
	 *  initialize the members of the given curve structure to size m.
	 *  Return 0 on success, 1 on error with error set.
	 */

    public function new():Void {
        c = new Array<Point>();
        c[0] = new Point();
        c[1] = new Point();
        c[2] = new Point();
        vertex = new Point();
    }

    public function toString():String {
        return "alpha0: " + alpha0 + "\n"
        + "alpha:  " + alpha + "\n"
        + "beta:   " + beta + "\n"
        + "corner: " + (tag == ProcessPath.POTRACE_CORNER) + "\n"
        + "bezier: " + c[0] + "," + c[1] + "," + c[2];
    }
}
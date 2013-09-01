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
import flash.display.Graphics;

class ClosedPath {

    public var curveArray:Array<Curve>;

    /**
	 *  Constructor.
	 *
	 *  initialize the members of the given curve structure to size m.
	 *  Return 0 on success, 1 on error with error set.
	 */

    public function new(?array:Array<Curve> = null):Void {
        curveArray = array != null ? array : [];
    }

    public function draw(g:Graphics):Void {
        var pt:Point = curveArray[curveArray.length - 1].c[2];
        g.moveTo(pt.x, pt.y);

        for (i in 0...curveArray.length) {
            var c:Curve = curveArray[i];

            if (c.tag == ProcessPath.POTRACE_CORNER) {
                g.lineTo(c.c[1].x, c.c[1].y);
                g.lineTo(c.c[2].x, c.c[2].y);
            }
            else {
                var t:Float = 0;
                while ((t += 0.02) < 1.0) {
                    var p:Point = getBezierPoint(pt, c.c[0], c.c[1], c.c[2], t);
                    g.lineTo(p.x, p.y);
                }
                g.lineTo(c.c[2].x, c.c[2].y);
            }
            pt = c.c[2];

        }
    }

    private function getBezierPoint(p0:Point, p1:Point, p2:Point, p3:Point, t:Float):Point {
        return new Point(Math.pow(1 - t, 3) * p0.x + 3 * t * Math.pow(1 - t, 2) * p1.x
        + 3 * t * t * (1 - t) * p2.x + t * t * t * p3.x,
        Math.pow(1 - t, 3) * p0.y + 3 * t * Math.pow(1 - t, 2) * p1.y
        + 3 * t * t * (1 - t) * p2.y + t * t * t * p3.y);
    }
}
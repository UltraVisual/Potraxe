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

import Std;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.filters.ColorMatrixFilter;

class PathList {
/**
		 * Decompose the given bitmap Into paths.
		 *
		 * @param bitmapData BitmapData to create paths.
		 * @return paths.
		 */
    public static function create(bitmapData:BitmapData):Array<Dynamic> {
        var pathList:Array<Dynamic> = [];
        var y:Int = 0;

        var bmdCopy:BitmapData = bitmapData.clone();
        var param:Dynamic = {turdSize : 3};

        var filter:ColorMatrixFilter = new ColorMatrixFilter([
        -1, 0, 0, 0, 255,
        -1, 0, 0, 0, 255,
        -1, 0, 0, 0, 255,
        0, 0, 0, 1, 0
        ]);

        var point:Point = new Point();
        while (findNext(bmdCopy, point)) {
            var xInt = Std.int(point.x);
            var yInt = Std.int(point.y);
            var sign:String = bmdCopy.getPixel(xInt, yInt) == 0 ? '+' : '-';

            var p:Dynamic = findPath(bmdCopy, new Point(xInt, yInt - 1), sign, param.turnPolicy);
            if (!p) {
                pathList = null;
                break;
            }

            xorPath(bmdCopy, p, filter);

            if (p.area > param.turdSize) {
                pathList.push(p);
            }
        }

        bmdCopy.dispose();
        return pathList;
    }

/**
		 * find the next set pixel in a row <= y.
		 *
		 * <p>Pixels are searched first left-to-right, then top-down.</p>
		 *
		 * <p>If found, return Point object. Else return null.</p>
		 */

    private static function findNext(bmd:BitmapData, pt:Point):Bool {

        for (y in 0...bmd.height) {
            for (x in 0...bmd.width) {
                if (bmd.getPixel(x, y) == 0x000000) {
                    pt.x = x;
                    pt.y = y;
                    return true;
                }
            }
        }
        return false;
    }

        /**
		 * compute a path in the given pixmap, separating black from white.
		 *
		 * <p>Start path at the <code>startPoint</code>, which must be an upper
		 * left corner of the path.
		 * Also compute the area enclosed by the path. Return a
		 * new path object. (note that a legitimate path
		 * cannot have length 0).</p>
		 *
		 * @param sign Required for correct Interpretation of turn policies.
		 */

    private static function findPath(bmd:BitmapData, startPoint:Point, sign:String, turnpolicy:Int):Dynamic {
        var area:Int = 0;
        var pointList:Array<Point> = [];

        var pt:Point = startPoint.clone();
        var dir:Point = new Point(0, 1);

        var rotateRight:Matrix = new Matrix(0, -1, 1, 0);
        var rotateLeft:Matrix = new Matrix(0, 1, -1, 0);

        while (true) {
            pointList.push(pt.clone());

            pt.offset(dir.x, dir.y);
            var int = Std.int(pt.x * -dir.y);
            area += int;

            if (pt.equals(startPoint)) {
                break;
            }

            var c:Bool = Std.int(bmd.getPixel32(Std.int(pt.x + (dir.x - dir.y - 1) / 2), Std.int(pt.y + (dir.y + dir.x + 1) / 2))) == 0xff000000;
            var d:Bool = Std.int(bmd.getPixel32(Std.int(pt.x + (dir.x + dir.y - 1) / 2), Std.int(pt.y + (dir.y - dir.x + 1) / 2))) == 0xff000000;

            if (c && !d) {
                if (true) {
                    dir = rotateLeft.transformPoint(dir);
                }
                else {
                    dir = rotateRight.transformPoint(dir);
                }
            }
            else if (c) {
                dir = rotateLeft.transformPoint(dir);
            }
            else if (!d) {
                dir = rotateRight.transformPoint(dir);
            }
        }

        var path:Dynamic = {};
        path.priv = pointList;
        path.area = area;
        path.sign = sign;

        return path;
    }

/**
		 *  xor the given pixmap with the Interior of the given path. 
		 *  Note: the path must be within the dimensions of the pixmap.
		 */

    private static function xorPath(bm:BitmapData, p:Dynamic, filter:ColorMatrixFilter):Void {
        var priv:Array<Dynamic> = cast p.priv;
        var len:Int = priv.length;

        var minX:Float = 99999;
        for (i in 0...len) {
            minX = Math.min(minX, priv[i].x);
        }

        var y1:Int = priv[len - 1].y;
        var pt:Point = new Point();
        var rect:Rectangle = new Rectangle();
        for(i in 0...len)
        {
            var x:Int = priv[i].x;
            var y:Int = priv[i].y;

            if (y != y1) {
                var y2:Float = Math.max(y, y1);
                pt.x = minX; pt.y = y2;
                rect.x = minX; rect.y = y2; rect.width = x - minX; rect.height = 1;
                bm.applyFilter(bm, rect, pt, filter);
                y1 = y;
            }
        }
    }
}
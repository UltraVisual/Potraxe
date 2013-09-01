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

import uk.co.ultravisual.potraxe.utils.QuadraticForm;
import uk.co.ultravisual.potraxe.utils.Point3D;
import uk.co.ultravisual.potraxe.utils.Sums;
import uk.co.ultravisual.potraxe.utils.Sums;
import uk.co.ultravisual.potraxe.utils.Sums;
import flash.geom.Point;

class ProcessPath {

    @final private static var INFTY:Int = 10000000;
    @final public static var POTRACE_CURVETO:Int = 1;
    @final public static var POTRACE_CORNER:Int = 2;


    public static function processPath(pathList:Array<Dynamic>):ClosedPathList {
        var curveList:ClosedPathList = new ClosedPathList();

        for (i in 0...pathList.length) {
            var sums:Array<Sums> = cast ProcessPath.calcSums(cast pathList[i].priv);
            var lons:Array<Int> = ProcessPath.calcLon(cast pathList[i].priv);
            var polygons:Array<Int> = ProcessPath.bestPolygon(cast pathList[i].priv, lons, sums);
            var vertex:Array<Point> = ProcessPath.adjustVertices(cast pathList[i].priv, sums, polygons);
            var curve:ClosedPath = ProcessPath.smooth(vertex, pathList[i].sign, .9);

            curveList.pathArray.push(curve);
        }

        return curveList;
    }

    public static function calcSums(pt:Array<Point>):Array<Sums> {
        var n:Int = pt.length;

        var sums:Array<Sums> = new Array<Sums>();

        var x0:Float = pt[0].x;
        var y0:Float = pt[0].y;

        sums[0] = new Sums();
        sums[0].x2 = sums[0].xy = sums[0].y2 = sums[0].x = sums[0].y = 0;
        for (i in 0...n) {
            var x:Float = pt[i].x - x0;
            var y:Float = pt[i].y - y0;
            sums[i + 1] = new Sums();
            sums[i + 1].x = sums[i].x + x;
            sums[i + 1].y = sums[i].y + y;
            sums[i + 1].x2 = sums[i].x2 + x * x;
            sums[i + 1].xy = sums[i].xy + x * y;
            sums[i + 1].y2 = sums[i].y2 + y * y;
        }


        return sums;
    }

    public static function calcLon(pt:Array<Point>):Array<Int> {
        var lon:Array<Int> = [];
        var n:Int = pt.length;
        var j:Int;
        var nc:Array<Int> = [];
        var k:Int = 0;
        var i = n - 1;
        while (i >= 0) {
            if (pt[i].x != pt[k].x && pt[i].y != pt[k].y) {
                k = i + 1;
            }
            nc[i] = k;
            i--;
        }

        var pivk:Array<Int> = [];
        var ct:Array<Int>;
        var dir:Int;
        var k1:Int;
        var constraint0:Point = new Point();
        var constraint1:Point = new Point();
        var cur:Point = new Point();
        var off:Point = new Point();
        var dk:Point = new Point();
        i = n - 1;
        while (i > 0) {
            ct = [0, 0, 0, 0];

            dir = Std.int((3 + 3 * (pt[mod(i + 1, n)].x - pt[i].x) + (pt[mod(i + 1, n)].y - pt[i].y)) / 2);
            ct[dir] += 1;
            constraint0.x = constraint0.y = constraint1.x = constraint1.y = 0;

            k = nc[i];
            k1 = i;
            var foundk:Bool = false;
            while (true) {
                dir = Std.int((3 + 3 * sign(pt[k].x - pt[k1].x) + sign(pt[k].y - pt[k1].y)) / 2);
                ct[dir] += 1;

                if (ct[0] > 0 && ct[1] > 0 && ct[2] > 0 && ct[3] > 0) {
                    pivk[i] = k1;
                    foundk = true;
                    break;
                }

                cur.x = pt[k].x - pt[i].x;
                cur.y = pt[k].y - pt[i].y;

                if (xprod(constraint0, cur) > 0 || xprod(constraint1, cur) < 0) {
                    break;
                }

                if (Math.abs(cur.x) <= 1 && Math.abs(cur.y) <= 1) {
                }
                else {
                    off.x = cur.x + ((-cur.y >= 0 && ( -cur.y > 0 || cur.x < 0)) ? 1 : -1);
                    off.y = cur.y + (( -cur.x <= 0 && ( -cur.x < 0 || cur.y < 0)) ? 1 : -1);
                    if (xprod(constraint0, off) <= 0) {
                        constraint0.x = off.x;
                        constraint0.y = off.y;
                    }

                    off.x = cur.x + ((-cur.y <= 0 && ( -cur.y < 0 || cur.x < 0)) ? 1 : -1);
                    off.y = cur.y + (( -cur.x >= 0 && ( -cur.x > 0 || cur.y < 0)) ? 1 : -1);
                    if (xprod(constraint1, off) >= 0) {
                        constraint1.x = off.x;
                        constraint1.y = off.y;
                    }
                }

                k1 = k;
                k = nc[k1];
                if (!cyclic(k, i, k1)) {
                    break;
                }
            }

            if (!foundk) {
                dk.x = sign(pt[k].x - pt[k1].x);
                dk.y = sign(pt[k].y - pt[k1].y);
                cur.x = pt[k1].x - pt[i].x;
                cur.y = pt[k1].y - pt[i].y;

                var a:Int = xprod(constraint0, cur);
                var b:Int = xprod(constraint0, dk);
                var c:Int = xprod(constraint1, cur);
                var d:Int = xprod(constraint1, dk);

                j = INFTY;
                if (b > 0) {
                    j = floordiv(-a, b);
                }
                if (d < 0) {
                    var flt:Float = cast j;
                    j = Std.int(Math.min(flt, floordiv(c, -d)));
                }
                var int:Int = Std.int(k1 + j);
                pivk[i] = mod(int, n);
            }
            i--;
        }

        j = pivk[n - 1];
        lon[n - 1] = j;
        i = n - 2;
        while (i >= 0) {
            if (cyclic(i + 1, pivk[i], j)) {
                j = pivk[i];
            }
            lon[i] = j;
            i--;
        }
        i = n - 1;
        while (cyclic(mod(i + 1, n), j, lon[i])) {
            lon[i] = j;
            i--;
        }

        return lon;
    }

    public static function bestPolygon(pt:Array<Point>, lon:Array<Int>, sums:Array<Sums>):Array<Int> {
        var i:Int, j:Int, k:Int;
        var n:Int = pt.length;

        var clip0:Array<Int> = new Array<Int>();
        var clip1:Array<Int> = new Array<Int>();

        for (i in 0...n) {
            var mod1 = mod(i - 1, n);
            var n1 = lon[mod1] - 1;
            var int = Std.int(n1);
            var c:Int = mod(int, n);
            if (c == i) {
                c = mod(i + 1, n);
            }
            if (c < i) {
                clip0[i] = n;
            }
            else {
                clip0[i] = c;
            }
        }

        j = 1;
        for (i in 0...n) {
            var clip = clip0[i];
            while (j <= clip) {
                clip1[j] = i;
                j++;
            }
        }

        var seg0:Array<Int> = new Array<Int>();
        var seg1:Array<Int> = new Array<Int>();

        i = 0;
        j = 0;
        while (i < n) {
            seg0[j] = i;
            i = clip0[i];
            j++;
        }
        seg0[j] = n;
        var m:Int = j;

        i = n;
        j = m;
        while (j > 0) {
            seg1[j] = i;
            i = clip1[i];
            j--;
        }
        seg1[0] = 0;

        var pen:Array<Int> = new Array<Int>();
        var prev:Array<Int> = new Array<Int>();
        var thispen:Float = 0.0;
        pen[0] = 0;
        j = 1;
        while (j <= m) {
            i = seg1[j];
            while (i <= seg0[j]) {
                var best:Float = -1;
                k = seg0[j - 1];
                while (k >= clip1[i]) {
                    thispen = penalty3(pt, k, i, sums) + pen[k];
                    if (best < 0 || thispen < best) {
                        prev[i] = k;
                        best = thispen;
                    }
                    k--;
                }
                pen[i] = Std.int(best);
                i++;
            }
            j++;
        }

        var po:Array<Int> = new Array<Int>();
        i = n;
        j = m - 1;
        while (i > 0) {
            po[j] = i = prev[i];
            j--;
        }

        return po;
    }

    private static function penalty3(pt:Array<Point>, i:Int, j:Int, sums:Array<Sums>):Float {
        var n:Int = pt.length;
        var r:Int = 0;

        if (j >= n) {
            j -= n;
            r += 1;
        }

        var x:Float = sums[j + 1].x - sums[i].x + r * sums[n].x;
        var y:Float = sums[j + 1].y - sums[i].y + r * sums[n].y;
        var x2:Float = sums[j + 1].x2 - sums[i].x2 + r * sums[n].x2;
        var xy:Float = sums[j + 1].xy - sums[i].xy + r * sums[n].xy;
        var y2:Float = sums[j + 1].y2 - sums[i].y2 + r * sums[n].y2;
        var k:Float = j + 1 - i + r * n;

        var px:Float = (pt[i].x + pt[j].x) / 2.0 - pt[0].x;
        var py:Float = (pt[i].y + pt[j].y) / 2.0 - pt[0].y;
        var ey:Float = (pt[j].x - pt[i].x);
        var ex:Float = -(pt[j].y - pt[i].y);

        var a:Float = ((x2 - 2 * x * px) / k + px * px);
        var b:Float = ((xy - x * py - y * px) / k + px * py);
        var c:Float = ((y2 - 2 * y * py) / k + py * py);

        var s:Float = ex * ex * a + 2 * ex * ey * b + ey * ey * c;

        return Math.sqrt(s);
    }

    public static function adjustVertices(pt:Array<Point>, sums:Array<Sums>, po:Array<Int>):Array<Point> {
        var m:Int = po.length;
        var n:Int = pt.length;

        var i:Int;
        var j:Int;
        var k:Int;
        var l:Int;
        var q:Array<QuadraticForm> = [];
        var v:Point3D = new Point3D();
        var ctr:Point = new Point();
        var dir:Point = new Point();
        i = 0;
        while (i < m) {
            j = po[(i + 1) % m];
            var int = Std.int(j - po[i]);
            j = Std.int(mod(int, n) + po[i]);
            ctr.x = ctr.y = dir.x = dir.y = 0;
            pointslope(pt, sums, po[i], j, ctr, dir);

            q[i] = new QuadraticForm();
            var d1:Float = dir.x * dir.x + dir.y * dir.y;
            if (d1 != 0) {
                v.setProperty(0, dir.y);
                v.setProperty(1, -dir.x);
                v.setProperty(2, -v.getProperty(1) * ctr.y - v.getProperty(0) * ctr.x);
                q[i].fromVectorMultiply(v).scalar(1 / d1);
            }
            i++;
        }

        var vertex:Array<Point> = [];
        var p0:Point = pt[0].clone();
        var s:Point = new Point();
        var w:Point = new Point();
        var _q:QuadraticForm = new QuadraticForm();
        var minCoord:Point = new Point();
        for (i in 0...m) {
            var z:Int;
            vertex[i] = new Point();

            s.x = pt[po[i]].x - p0.x;
            s.y = pt[po[i]].y - p0.y;
            j = mod(i - 1, m);
            var quadraticForm:QuadraticForm = q[j].clone().add(q[i]);
            var q00:Float = roundToDec(quadraticForm.getProperty(0).getProperty(0));
            var q11:Float = roundToDec(quadraticForm.getProperty(1).getProperty(1));
            var q01:Float = roundToDec(quadraticForm.getProperty(0).getProperty(1));
            var q10:Float = roundToDec(quadraticForm.getProperty(1).getProperty(0));
            var q02:Float = roundToDec(quadraticForm.getProperty(0).getProperty(2));
            var q12:Float = roundToDec(quadraticForm.getProperty(1).getProperty(2));
            while (true) {
                var det:Float = q00 * q11 - q01 * q10;
                if (det != 0.0) {
                    w.x = ( -q02 * q11 + q12 * q01) / det;
                    w.y = ( q02 * q10 - q12 * q00) / det;
                    break;
                }
                if (q00 > q11) {
                    v.setProperty(0, -q01);
                    v.setProperty(1, q00);
                }
                else if (q11 > 0) {
                    v.setProperty(0, -q11);
                    v.setProperty(1, q10);
                }
                else {
                    v.setProperty(0, 1);
                    v.setProperty(1, 0);
                }

                var d:Float = v.getProperty(0) * v.getProperty(0) + v.getProperty(1) * v.getProperty(1);
                v.setProperty(2, -v.getProperty(1) * s.y - v.getProperty(0) * s.x);
                quadraticForm.add(_q.fromVectorMultiply(v)).scalar(1 / d);
                break;
            }

            var dx:Float = Math.abs(w.x - s.x);
            var dy:Float = Math.abs(w.y - s.y);
            if (dx <= 0.5 && dy <= 0.5) {
                vertex[i].x = w.x + p0.x;
                vertex[i].y = w.y + p0.y;
                continue;
            }

            var min:Float, cand:Float;
            minCoord.x = s.x; minCoord.y = s.y;
            min = quadraticForm.apply(s);

            if (q00 != 0.0) {
                for (z in 0...2) {
                    w.y = s.y - 0.5 + z;
                    w.x = -(q01 * w.y + q02) / q00;
                    dx = (w.x - s.x > 0 ? w.x - s.x : s.x - w.x);
                    cand = quadraticForm.apply(w);
                    if (dx <= .5 && cand < min) {
                        min = cand;
                        minCoord.x = w.x; minCoord.y = w.y;
                    }
                }
            }

            if (q11 != 0.0) {
                for (z in 0...2) {
                    w.x = s.x - 0.5 + z;
                    w.y = -(q10 * w.x + q12) / q11;
                    dy = (w.y - s.y > 0 ? w.y - s.y : s.y - w.y);
                    cand = quadraticForm.apply(w);
                    if (dy <= .5 && cand < min) {
                        min = cand;
                        minCoord.x = w.x; minCoord.y = w.y;
                    }
                }
            }
            for (l in 0...2) {
                for (k in 0...2) {
                    w.x = s.x - 0.5 + l;
                    w.y = s.y - 0.5 + k;
                    cand = quadraticForm.apply(w);
                    if (cand < min) {
                        min = cand;
                        minCoord.x = w.x; minCoord.y = w.y;
                    }
                }
            }

            vertex[i].x = minCoord.x + p0.x;
            vertex[i].y = minCoord.y + p0.y;
            continue;
        }
        return vertex;
    }

    public static function smooth(vertex:Array<Dynamic>, sign:String, alphamax:Float = 1.0):ClosedPath {
        var m:Int = vertex.length;
        var closedPath:ClosedPath = new ClosedPath();

        var i:Int;
        var j:Int;
        if (sign == '-') {
            var tmp:Point;
            i = 0; j = m - 1;
            while (i < j) {
                tmp = vertex[i];
                vertex[i] = vertex[j];
                vertex[j] = tmp;
                i++; j--;
            }
        }

        var p2:Point = new Point();
        var p3:Point = new Point();
        var p4:Point = new Point();
        i = 0;
        while (i < m) {
            var j:Int = (i + 1) % m;
            var k:Int = (i + 2) % m;
            Interval(1 / 2.0, vertex[k], vertex[j], p4);

            var curve:Curve = new Curve();
            curve.vertex.x = vertex[j].x;
            curve.vertex.y = vertex[j].y;

            var denom:Float = ddenom(vertex[i], vertex[k]);
            var alpha:Float;
            if (denom != 0.0) {
                var dd:Float = dpara(vertex[i], vertex[j], vertex[k]) / denom;
                dd = dd < 0 ? -dd : dd;
                alpha = dd > 1 ? (1 - 1.0 / dd) / 0.75 : 0;
            }
            else {
                alpha = 4 / 3.0;
            }
            curve.alpha0 = alpha;

            if (alpha > alphamax) {
                curve.tag = POTRACE_CORNER;
                curve.c[0].x = 0; curve.c[0].y = 0;
                curve.c[1].x = vertex[j].x; curve.c[1].y = vertex[j].y;
                curve.c[2].x = p4.x; curve.c[2].y = p4.y;
            }
            else {
                if (alpha < 0.55) {
                    alpha = 0.55;
                }
                else if (alpha > 1) {
                    alpha = 1;
                }
                Interval(.5 + .5 * alpha, vertex[i], vertex[j], p2);
                Interval(.5 + .5 * alpha, vertex[k], vertex[j], p3);
                curve.tag = POTRACE_CURVETO;
                curve.c[0].x = p2.x; curve.c[0].y = p2.y;
                curve.c[1].x = p3.x; curve.c[1].y = p3.y;
                curve.c[2].x = p4.x; curve.c[2].y = p4.y;
            }
            curve.alpha = alpha;
            curve.beta = 0.5;

            closedPath.curveArray[j] = curve;
            i++;
        }

        return closedPath;
    }

    public static function pointslope(pt:Array<Point>, sums:Array<Sums>, i:Int, j:Int, ctr:Point, dir:Point):Void {
        var n:Int = pt.length;

        var x:Float, y:Float, x2:Float, xy:Float, y2:Float;
        var k:Float;
        var a:Float, b:Float, c:Float, lambda2:Float, l:Float;
        var r:Int = 0;

        while (j >= n) {
            j -= n;
            r += 1;
        }
        while (i >= n) {
            i -= n;
            r -= 1;
        }
        while (j < 0) {
            j += n;
            r -= 1;
        }
        while (i < 0) {
            i += n;
            r += 1;
        }

        x = sums[j + 1].x - sums[i].x + r * sums[n].x;
        y = sums[j + 1].y - sums[i].y + r * sums[n].y;
        x2 = sums[j + 1].x2 - sums[i].x2 + r * sums[n].x2;
        xy = sums[j + 1].xy - sums[i].xy + r * sums[n].xy;
        y2 = sums[j + 1].y2 - sums[i].y2 + r * sums[n].y2;
        k = j + 1 - i + r * n;

        ctr.x = x / k;
        ctr.y = y / k;

        a = (x2 - x * x / k) / k;
        b = (xy - x * y / k) / k;
        c = (y2 - y * y / k) / k;

        lambda2 = (a + c + Math.sqrt((a - c) * (a - c) + 4 * b * b)) / 2; // larger e.value

        a -= lambda2;
        c -= lambda2;

        if (Math.abs(a) >= Math.abs(c)) {
            l = Math.sqrt(a * a + b * b);
            if (l != 0) {
                dir.x = -b / l;
                dir.y = a / l;
            }
        }
        else {
            l = Math.sqrt(c * c + b * b);
            if (l != 0) {
                dir.x = -c / l;
                dir.y = b / l;
            }
        }
        if (l == 0) {
            dir.x = dir.y = 0;
        }
    }

    public static function Interval(lambda:Float, a:Point, b:Point, ret:Point):Void {
        ret.x = a.x + lambda * (b.x - a.x);
        ret.y = a.y + lambda * (b.y - a.y);
    }

    private static function mod(a:Int, n:Int):Int {
        return a >= n ? a % n : a >= 0 ? a : n - 1 - ( -1 - a) % n;
    }

    private static function floordiv(a:Int, n:Int):Int {
        return Std.int(a >= 0 ? a / n : -1 - ( -1 - a) / n);
    }

    private static function roundToDec(a:Float, ?prec:Int = 10):Float{
        return Math.round(a * Math.pow(10, prec)) / Math.pow(10, prec);
    }

    private static function xprod(p1:Point, p2:Point):Int {
        return Std.int(p1.x * p2.y - p1.y * p2.x);
    }

    private static function sign(x:Float):Int {
        return (x > 0 ? 1 : x < 0 ? -1 : 0);
    }

    public static function dorth_infty(p0:Point, p2:Point):Point {
        return new Point(
        sign(p2.x - p0.x),
        -sign(p2.y - p0.y)
        );
    }

    static public function dpara(p0:Point, p1:Point, p2:Point):Float {
        var x1:Float = p1.x - p0.x;
        var y1:Float = p1.y - p0.y;
        var x2:Float = p2.x - p0.x;
        var y2:Float = p2.y - p0.y;

        return x1 * y2 - x2 * y1;
    }

    public static function ddenom(p0:Point, p2:Point):Float {
        var r:Point = dorth_infty(p0, p2);
        return r.y * (p2.x - p0.x) - r.x * (p2.y - p0.y);
    }

    private static function cyclic(a:Int, b:Int, c:Int):Bool {
        if (a <= c) {
            return (a <= b) && (b < c);
        }
        else {
            return (a <= b) || (b < c);
        }
    }
}




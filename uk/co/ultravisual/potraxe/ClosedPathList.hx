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

import flash.display.Graphics;
import flash.display.BitmapData;

class ClosedPathList {

    public var pathArray:Array<ClosedPath>;


    public function new():Void {
        pathArray = [];
    }

    public static function trace(bmpdata:BitmapData):ClosedPathList {
        var pathList:Array<Dynamic> = PathList.create(bmpdata);
        return ProcessPath.processPath(pathList);
    }

    public function draw(g:Graphics):Void {
        for (_path in pathArray) {
            if (Std.is(_path, ClosedPath))
            {
                var path:ClosedPath = cast _path;
                path.draw(g);
            }
        }
    }
}
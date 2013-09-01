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

import flash.display.Sprite;
import flash.text.TextFieldAutoSize;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 *  The Potraxe class is an all-static class with methods for working with tracing <code>BitmapData</code> and letters.
 */
class Potraxe {
    /**
	 *  Traces the given BitmapData.
	 *
	 *  @param sourceBitmapData The input image to use. The source image must be binarized 
	 *  (only 0xffffffff and 0xff000000 are allowed).
	 *  @return A ClosedPathList object that represents trace result.
	 *  @see also ClosedPathList
	 */
    public static function traceBitmap(sourceBitmapData:BitmapData):ClosedPathList {
        var pathList:Array<Dynamic> = PathList.create(sourceBitmapData);
        return ProcessPath.processPath(pathList);
    }

    /**
	 *  Traces the String with fontsize <code>fontSize</code>.
	 */

    public static function traceLetter(letter:String, fontSize:Int, fontName:String):ClosedPathList {
        var tf:TextFormat = new TextFormat();
        tf.size = fontSize;
        tf.font = fontName;
        var text:TextField = new TextField();
        text.defaultTextFormat = tf;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.text = letter;

        var width = Std.int(fontSize * letter.length);
        var height = Std.int(fontSize * 1.2);
        var bmdtmp:BitmapData = new BitmapData(width, height, true);
        var bitmapdata:BitmapData = bmdtmp.clone();
        bmdtmp.draw(text);
        bitmapdata.threshold(bmdtmp, bmdtmp.rect, new Point(), "<", 0xffdddddd, 0xff000000);

        var pathList:Array<Dynamic> = PathList.create(bitmapdata);
        var c:ClosedPathList = ProcessPath.processPath(pathList);

        bmdtmp.dispose();
        bitmapdata.dispose();
        return c;
    }

    public static function drawLetter(letter:String, fontSize:Int, fontName:String, lineThickness:Float, lineColour:Int, fillColour:Int, fillOpacity:Float):Sprite{
        var curvesList:ClosedPathList = traceLetter(letter, fontSize, fontName);
        var sprite:Sprite = new Sprite();
        sprite.graphics.lineStyle(lineThickness, lineColour);
        sprite.graphics.beginFill(fillColour, fillOpacity);
        curvesList.draw(sprite.graphics);
        sprite.graphics.endFill();
        return sprite;
    }
}
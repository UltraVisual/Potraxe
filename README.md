Potraxe
=======

Haxe port of potrace - http://potrace.sourceforge.net/

Install via haxelib with

```
haxelib git https://github.com/UltraVisual/Potraxe

```
Basic trace text example - note the huge font size - this is for better precision as smaller font sizes look
less precise in the final drawing but larger ones take up more computation times.

![Text tracing](https://github.com/UltraVisual/Potraxe/raw/master/src/common/images/potraxe.png "Text tracing")

```
package ;
import flash.Lib;
import flash.display.Sprite;
import uk.co.ultravisual.potraxe.Potraxe;
import flash.display.Sprite;

class TextSample extends Sprite {

    private static var xPos:Float = 0;

    @final private static var PADDING:Float = 30;
    @final private static var SCALE:Float = 0.45;

    public function new():Void {
        super();

        addChild(drawWord('Potraxe'));
    }

    private function drawWord(word:String):Sprite {
        var container:Sprite = new Sprite();
        for (i in 0...word.length) {
            var sprite:Sprite = Potraxe.drawLetter(word.charAt(i), 600, 'Arial', 0.5, 0xff6600, 0xff6600, 0.4);
            sprite.x = xPos;
            xPos += sprite.width + PADDING;
            container.addChild(sprite);
        }
        container.scaleX = container.scaleY = SCALE;
        container.x = ((Lib.current.stage.stageWidth - container.width) * 0.5) - 20;
        return container;
    }
}

```

![Bitmap tracing](https://github.com/UltraVisual/Potraxe/raw/master/src/common/images/manga.png "Bitmap tracing")

Basic trace bitmap example

```
package ;

import flash.display.Sprite;
import uk.co.ultravisual.potraxe.Potraxe;
import uk.co.ultravisual.potraxe.ClosedPathList;
import flash.display.Bitmap;
import flash.display.BitmapData;

@:bitmap("assets/manga.png") class HaxeImage extends BitmapData {}

class BitmapSample extends Sprite{

    public function new() {
        super();
        var bmp:Bitmap = new Bitmap();
        var bmd:BitmapData = new HaxeImage(263, 357);
        bmp.bitmapData = bmd;
        addChild(bmp);
        bmp.alpha = 0.5;

        var curvesList:ClosedPathList = Potraxe.traceBitmap(bmp.bitmapData);

        var sprite:Sprite = new Sprite();
        sprite.graphics.lineStyle(0.5, 0x0066ff);
        sprite.graphics.beginFill(0x0066ff, 0.4);
        curvesList.draw(sprite.graphics);
        sprite.graphics.endFill();
        sprite.x = bmp.width;
        addChild(sprite);
    }
}


```

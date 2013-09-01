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

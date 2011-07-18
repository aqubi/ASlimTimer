
package skin {

import mx.skins.halo.ButtonSkin;
import mx.utils.ColorUtil;

public class SelectOverButtonSkin extends ButtonSkin {

	override protected function updateDisplayList(w:Number, h:Number):void {
		super.updateDisplayList(w, h);

		var cornerRadius:Number = getStyle("cornerRadius");
		var fillColors:Array = getStyle("fillColors");
//		var fill0Darker:Number =
//			ColorUtil.adjustBrightness2(fillColors[0], -10);
		var fill0Darker:Number =0xFFFFFF;
		var fill1Darker:Number =
			ColorUtil.adjustBrightness2(fillColors[1], -30);
		var cr:Number = Math.max(0, cornerRadius);
		var cr1:Number = Math.max(0, cornerRadius - 1);
		var cr2:Number = Math.max(0, cornerRadius - 2);

		drawRoundRect(
			1, 1, w - 2, h - 2, cr1,
			[ fill0Darker, fill1Darker ], 1,
			verticalGradientMatrix(0, 0, w - 2, h - 2));
			
	}
}

}

package theme {
import mx.utils.ColorUtil;
public class AquaTheme implements ThemeInterface {

	public function toString():String {
		return "AQUA";
	}

	public function get backDarkColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, -50);
	}
	
	public function get backMiddleColor():uint {
		return 0xa0d8ef;
	}
	
	public function get backLightColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, 50);
	}
	
	public function get textForeColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, -200);
	}
	
	public function get labelForeColor():uint {
		return textForeColor;
	}

	public function get panelForeColor():uint {
		return textForeColor;
	}
}
}
package theme {
import mx.utils.ColorUtil;

public class AzukiTheme implements ThemeInterface {
	public function toString():String {
		return "小豆";
	}

	public function get backDarkColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, -50);
	}
	
	public function get backMiddleColor():uint {
		return 0x96514D;
	}
	
	public function get backLightColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, 150);
	}
	
	public function get textForeColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, -110);
	}
	
	public function get labelForeColor():uint {
		return textForeColor;
	}
	
	public function get panelForeColor():uint {
		return textForeColor;
	}

}
}
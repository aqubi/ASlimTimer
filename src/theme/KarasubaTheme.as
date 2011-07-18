package theme {
import mx.utils.ColorUtil;
public class KarasubaTheme implements ThemeInterface {
	private var WINDOW_BACK_COLORS:Array = [0x180614, 0x460e44];
	private var TITLE_BAR_COLORS:Array = [0xFFFFFF, 0x180614];
	private var BACK_COLOR:uint = 0x180614;
	private var FORE_COLOR:uint = 0xFFFFFF;
	private var TITLE_BACK_COLOR:uint = 0x180614;
	private var LIST_COLORS:Array = [0x460e44, 0x180614];
	
	public function toString():String {
		return "烏羽";
	}
	public function get backDarkColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, -10);
	}
	
	public function get backMiddleColor():uint {
		return 0x180614;
	}

	public function get backLightColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, 200);
	}
	
	public function get textForeColor():uint {
		return backMiddleColor;
	}
	
	public function get labelForeColor():uint {
		return backMiddleColor;
	}
	
	public function get panelForeColor():uint {
		return ColorUtil.adjustBrightness(backMiddleColor, 120);
	}

}
}
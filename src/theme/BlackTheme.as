package theme {


public class BlackTheme implements ThemeInterface {
	private var WINDOW_BACK_COLORS:Array = [0x000000, 0x000000];
	private var TITLE_BAR_COLORS:Array = [0xFFFFFF, 0x4F4F4F];
	private var BACK_COLOR:uint = 0x000000;
	private var FORE_COLOR:uint = 0xFFFFFF;
	private var LIST_COLORS:Array = [0x000000, 0x4F4F4F];
		
	public function toString():String {
		return "BLACK";
	}
	
	public function get backDarkColor():uint {
		return 0x000000;
	}
	
	public function get backMiddleColor():uint {
		return 0x000000;
	}
	
	public function get backLightColor():uint {
		return 0x9fa0a0;
	}
	
	public function get textForeColor():uint {
		return 0x000000;
	}
	
	public function get labelForeColor():uint {
		return 0xFFFFFF;
	}

	public function get panelForeColor():uint {
		return 0xFFFFFF;
	}

}
}
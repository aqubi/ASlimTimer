import mx.managers.PopUpManager;
import flash.ui.Keyboard;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import controller.WindowController;


private var _oldNetworkMode:int;
private var _window:ASlimTimer;
private var _callback:Function
/*
 * Networkの設定用Dialog
 */
 
public function init(mainWindow:ASlimTimer, callback:Function):void {
	_window = mainWindow;
	_callback = callback;
	addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ESCAPE) {
            cancel();
        }
    });
    
    WindowController.changeDialogTheme(this);
    _oldNetworkMode = ASlimTimer.ST_SETTING.networkMode;
    mode.selectedValue = _oldNetworkMode;
	
}

/* OK押されたとき */
protected function ok():void {
	_callback(_window, _oldNetworkMode, mode.selectedValue);
	PopUpManager.removePopUp(this);
}

/* CANCEL押されたとき */
protected function cancel():void {
	PopUpManager.removePopUp(this);
}



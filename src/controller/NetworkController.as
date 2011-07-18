package controller {

import flash.desktop.NativeApplication;
import flash.net.SharedObject;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;


import view.NetworkDialog;

/*
 * Network情報を制御するController
 */
public class NetworkController {
	
	/*　ダイアログを表示する */
	public function showDialog(window:ASlimTimer):void {
        var network:NetworkDialog = NetworkDialog(
    		PopUpManager.createPopUp(window, NetworkDialog , false, PopUpManagerChildList.POPUP));
	
		PopUpManager.centerPopUp(network);
    	network.init(window, onDialogOk);
	}
	
	/* DialogのOKボタンが押されたとき */
	private function onDialogOk(window:ASlimTimer, oldNetworkMode:int, mode:int):void {
		if (oldNetworkMode != mode) {
			ASlimTimer.ST_SETTING.networkMode = mode;
			trace("NetworkModelが変更されました。" + oldNetworkMode + "→" + mode);
			window.refreshNetwork();
			oldNetworkMode = mode;
		}
	}
	
}
}
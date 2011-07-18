import model.STAlarm;
import http.LoadResult;
import view.CreateAlarm;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import flash.desktop.NativeApplication;

protected function onDelete():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	Alert.show(window.rb("IsThisAlarmDelete?"), data.name, Alert.YES|Alert.NO, null, 
	function (event:CloseEvent):void {
		if (event.detail == Alert.YES) {
			ASlimTimer.ALARM_CONTROLLER.deleteAlarm( data as STAlarm);
		}
	}
	);
}


protected function onEdit():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	window.showAlarmEditDialog(data as STAlarm);

}


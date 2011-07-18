import mx.events.CloseEvent;
import mx.controls.Alert;
import model.STTimeEntry;
import mx.managers.PopUpManager;

protected function onDelete():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	var title:String;
	if (data.task != null) {
		title = data.task.name;
	} else {
		title = '';
	}

	Alert.show(window.rb("IsThisTimeEntryDelete?"), title, Alert.YES|Alert.NO, null, 
	function (event:CloseEvent):void {
		if (event.detail == Alert.YES) {
			window.checkDeleteTimeEntry(STTimeEntry(data));
			ASlimTimer.TASKS_CONTROLLER.executeDeleteTimeEntry(STTimeEntry(data));
		}
	}
	);
}

protected function onEdit():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	window.showTimeEditDialog(data as STTimeEntry);
}
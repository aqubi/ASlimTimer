import model.STTask;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import flash.desktop.NativeApplication;

protected function onDelete():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	Alert.show(window.rb("IsThisTaskDelete?"), data.name, Alert.YES|Alert.NO, null, 
	function (event:CloseEvent):void {
		if (event.detail == Alert.YES) {
			window.checkDeleteTask(data as STTask);
			ASlimTimer.TASKS_CONTROLLER.deleteTask(function():void {
				ASlimTimer.TASKS_CONTROLLER.getTaskList();
			}, data as STTask);
		}
	}
	);
}


protected function onEdit():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	window.showTaskEditDialog(data as STTask);
}

protected function onCompleted():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	Alert.show(window.rb("IsThisTaskComplete?"), data.name, Alert.YES|Alert.NO, null, 
	function (event:CloseEvent):void {
		if (event.detail == Alert.YES) {
			data.completedOn = new Date();
			ASlimTimer.TASKS_CONTROLLER.updateTask(
			function():void {
				ASlimTimer.TASKS_CONTROLLER.getTaskList();
			}
			, data as STTask);
		}
	}
	);
	
}

protected function onStart():void {
	var window:ASlimTimer = parentDocument as ASlimTimer;
	window.startTask(data as STTask);
}
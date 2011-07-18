import flash.ui.Keyboard;
import mx.managers.PopUpManager;
import mx.controls.Alert;

import model.STTask;
import controller.WindowController;
import http.LoadResult;

public var returnFunction:Function;

public function init():void {
	addEventListener(KeyboardEvent.KEY_DOWN, 
		function(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.ESCAPE) {
                cancel();
            }
        });
    WindowController.changeDialogTheme(this);
	txtName.setFocus();
}

protected function ok():void {
	var task:STTask = new STTask();
	task.name = txtName.text;
	task.createdAt = new Date();
	task.tags = txtTags.text;
	PopUpManager.removePopUp(this);
	
	ASlimTimer.TASKS_CONTROLLER.createTask(
	function(result:LoadResult):void {
		if (result.isSuccess) {
			returnFunction(task);
			ASlimTimer.TASKS_CONTROLLER.getTaskList();
		} else {
			Alert.show("Error! " + result.message);
		}
	}, task);

}

public function cancel():void {
	PopUpManager.removePopUp(this);
}
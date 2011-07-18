import flash.ui.Keyboard;
import mx.managers.PopUpManager;
import mx.controls.Alert;

import controller.WindowController;
import model.STTask;
import http.LoadResult;

protected var task:STTask;

public function init(updateTask:STTask):void {
	task = updateTask;
	txtName.text = task.name;
	txtTags.text = task.tags;
	addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ESCAPE) {
            cancel();
        }
    });
    WindowController.changeDialogTheme(this);
    WindowController.changeTextAlpha([txtName, txtTags]);
	txtTags.setFocus();
}

protected function ok():void {
	task.name = txtName.text;
	task.tags = txtTags.text;

	ASlimTimer.TASKS_CONTROLLER.updateTask(
	function(result:LoadResult):void {
		if (result.isSuccess) {
			ASlimTimer.TASKS_CONTROLLER.getTaskList();
		} else {
			Alert.show(result.message, "ERROR");
		}
	}, task);
	cancel();

}

public function cancel():void {
	PopUpManager.removePopUp(this);
	//task = null;
}
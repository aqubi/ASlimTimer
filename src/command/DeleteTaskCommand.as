/**
* Taskを削除するCommand
* @author ogawahideko
*/
package command {
	import model.STTask;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class DeleteTaskCommand implements ICommand {
		private var _task:STTask;
		public function set task(task:STTask):void { _task = task; }
		public function get task():STTask { return _task; }

		public function DeleteTaskCommand(task:STTask) {
			_task = task;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			_task.isUpdated = false;
			sqLiteController.deleteTask(_task, ASlimTimer.ST_TOKEN,
			function (result:LoadResult):void {
				var index:int = ASlimTimer.TASKS_CONTROLLER.tasks.getItemIndex(task);
				if (index >=0) {
					ASlimTimer.TASKS_CONTROLLER.tasks.removeItemAt(index);
				}
				result.targetCommand = getInstance();
				callback(result);
			});

		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			slimTimerController.executeDeleteTask(
			function (result:LoadResult):void {
				if (result.isSuccess) {
					task.isUpdated = true;
					task.isCreated = false;
					sqLiteController.deleteTask(task, ASlimTimer.ST_TOKEN);
				}
				result.targetCommand = getInstance();
				callback(result);
			}, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN, _task);
		}
	}
}

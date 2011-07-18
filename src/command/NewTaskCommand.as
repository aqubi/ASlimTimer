/**
* 新しいTaskを作成するCommand
* @author ogawahideko
*/
package command {
	import model.STTask;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class NewTaskCommand implements ICommand {
		private var _task:STTask;
		public function set task(task:STTask):void { _task = task; }
		public function get task():STTask { return _task; }

		public function NewTaskCommand(task:STTask) {
			_task = task;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			_task.isCreated = false;
			_task.isUpdated = false;
			_task.id = ASlimTimer.ST_SETTING.nextLocalTaskId;
			_task.ownerId = ASlimTimer.ST_TOKEN.userId;
			sqLiteController.insertTask(_task, ASlimTimer.ST_TOKEN, 
			function(result:LoadResult):void {
				ASlimTimer.TASKS_CONTROLLER.tasks.addItemAt(task, 0);//一覧に追加
				result.targetCommand = getInstance();
				callback(result);
			});
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			slimTimerController.executeCreateTask(
			function myFunc(result:LoadResult):void {
				trace("task追加 result=" + result.isSuccess);
				if (result.isSuccess) {
					var oldId:Number = _task.id;
					_task.id = Number(result.xml.id);
					_task.isCreated = true; //タスクは常にDBに保存しておく
					_task.isUpdated = true;
					ASlimTimer.TICK_CONTROLLER.updateTaskId(oldId, _task.id);
					sqLiteController.updateIdTask(_task, oldId, ASlimTimer.ST_TOKEN);
					sqLiteController.updateTimeEntryToTaskId(oldId, _task.id, ASlimTimer.ST_TOKEN);
				}
				result.targetCommand = getInstance();
				callback(result);	

			}, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN, _task);
		}
	}
}
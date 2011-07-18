/**
* Taskを更新するCommand
* @author ogawahideko
*/
package command {
	import model.STTask;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;

	/**
	* Taskを更新するコマンド
	*/
	public class UpdateTaskCommand implements ICommand {
		private var _task:STTask;
		public function set task(task:STTask):void { _task = task; }
		public function get task():STTask { return _task; }

		public function UpdateTaskCommand(task:STTask) {
			_task = task;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			_task.isUpdated = false;
			_task.isCreated = true;
			sqLiteController.updateTask(_task, ASlimTimer.ST_TOKEN, 
			function(result:LoadResult):void {
				result.targetCommand = getInstance();
				callback(result);
			});
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			slimTimerController.executeUpdateTask(_task, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN,
			function myFunc(result:LoadResult):void {
				if (result.isSuccess) {
					_task.isUpdated = true;
					_task.isCreated = true;
					//				    	if (ASlimTimer.TICK_CONTROLLER.selectedItem != null) {
					//				    		ASlimTimer.TICK_CONTROLLER.selectedItem.isUpdated = true;
					//				    	}
					sqLiteController.updateTask(_task, ASlimTimer.ST_TOKEN, null);
				}
				result.targetCommand = getInstance();
				callback(result);
			});
		}
	}
}

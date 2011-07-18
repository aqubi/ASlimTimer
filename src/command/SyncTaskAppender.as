/**
* TaskのDB情報をServiceへ更新して同期処理をするコマンド
* @author ogawahideko
*/
package command {

	import mx.collections.ArrayCollection;
	import model.STTask;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class SyncTaskAppender implements ICommand {
		private var _updater:ServiceUpdater;

		public function SyncTaskAppender(updater:ServiceUpdater):void {
			_updater = updater;
		}

		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			//新規Task処理を追加
			var tasksList:ArrayCollection = sqLiteController.getSynchroNewTasks(ASlimTimer.ST_TOKEN);
			for each (var task:STTask in tasksList) {
				var newCommand:NewTaskCommand = new NewTaskCommand(task);
				_updater.addSyncCommand(newCommand);
			}
			tasksList.removeAll();

			//更新Task処理を追加
			tasksList = sqLiteController.getSynchroUpdateTasks(ASlimTimer.ST_TOKEN);
			for each (var task2:STTask in tasksList) {
				var updateCommand:UpdateTaskCommand = new UpdateTaskCommand(task2);
				_updater.addSyncCommand(updateCommand);
			}
			tasksList.removeAll();

			//削除Task処理を追加
			tasksList = sqLiteController.getSynchroDeleteTasks(ASlimTimer.ST_TOKEN);
			for each (var task3:STTask in tasksList) {
				var deleteCommand:DeleteTaskCommand = new DeleteTaskCommand(task3);
				_updater.addSyncCommand(deleteCommand);
			}

			_updater.addCommand(new GetTaskListCommand());
			_updater.addCommand(new SyncTimeEntryAppender(_updater));

			callback(createLoadResult());
		}

		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			callback(createLoadResult());
		}

		private function createLoadResult():LoadResult {
			var result:LoadResult = new LoadResult();
			result.targetCommand = this;
			return result;
		}
	}
}

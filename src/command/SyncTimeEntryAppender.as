/**
* TimeEntryのDB情報をServiceへ更新して同期処理をするコマンド
* @author ogawahideko
*/
package command {

	import mx.collections.ArrayCollection;
	import model.STTimeEntry;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class SyncTimeEntryAppender implements ICommand {
		private var _updater:ServiceUpdater;

		public function SyncTimeEntryAppender(updater:ServiceUpdater):void {
			_updater = updater;
		}

		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			callback(createLoadResult());
		}

		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			var timesList:ArrayCollection = sqLiteController.getSelectTimeEntry(ASlimTimer.ST_TOKEN);
			for each (var time:STTimeEntry in timesList) {
				if (time.isUpdated) {
					continue;
				} else if (time.id < 0) {
					var addCom:NewTimeEntryCommand = new NewTimeEntryCommand(time);
					_updater.addSyncCommand(addCom);
				} else if (time.isOfflineDeleted) {
					var delCom:DeleteTimeEntryCommand = new DeleteTimeEntryCommand(time);
					_updater.addSyncCommand(delCom);
				} else {
					var com:UpdateTimeEntryCommand = new UpdateTimeEntryCommand(time);
					_updater.addSyncCommand(com);
				}
			}
			callback(createLoadResult());
		}

		private function createLoadResult():LoadResult {
			var result:LoadResult = new LoadResult();
			result.targetCommand = this;
			return result;
		}
	}
}
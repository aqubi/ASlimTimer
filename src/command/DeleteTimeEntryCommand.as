/**
* TimeEntryを削除するCommand
* @author ogawahideko
*/
package command {
	import model.STTimeEntry;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class DeleteTimeEntryCommand implements ICommand{
		private var _timeEntry:STTimeEntry;
		[Bindable]
		public function set timeEntry(timeEntry:STTimeEntry):void { _timeEntry = timeEntry; }
		public function get timeEntry():STTimeEntry { return _timeEntry; }

		public function DeleteTimeEntryCommand(timeEntry:STTimeEntry) {
			_timeEntry = timeEntry;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			_timeEntry.isUpdated = false;
			sqLiteController.deleteTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
			//一覧から削除
			var i:int = ASlimTimer.TASKS_CONTROLLER.timeEntries.getItemIndex(timeEntry);
			ASlimTimer.TASKS_CONTROLLER.timeEntries.removeItemAt(i);
			ASlimTimer.TASKS_CONTROLLER.timeEntries.refresh(); 

			var result:LoadResult = new LoadResult();
			result.targetCommand = getInstance();
			callback(result);	
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			slimTimerController.executeDeleteTimeEntry(_timeEntry.id, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN,
			function(result:LoadResult):void {
				if (result.isSuccess) {
					_timeEntry.isCreated = false;
					_timeEntry.isUpdated = true;
					sqLiteController.deleteTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
				}
				result.targetCommand = getInstance();
				callback(result);
			});
		}
	}
}

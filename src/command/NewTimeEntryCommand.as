/**
* 新しいTimeEntryを作成するCommand
* @author ogawahideko
*/
package command {
	import model.STTimeEntry;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.TasksController;

	public class NewTimeEntryCommand implements ICommand{
		private var _timeEntry:STTimeEntry;
		[Bindable]
		public function set timeEntry(timeEntry:STTimeEntry):void { _timeEntry = timeEntry; }
		public function get timeEntry():STTimeEntry { return _timeEntry; }

		public function NewTimeEntryCommand(timeEntry:STTimeEntry) {
			_timeEntry = timeEntry;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(db:SQLiteController, callback:Function):void {
			_timeEntry.isCreated = false;
			_timeEntry.isUpdated = false;
			_timeEntry.id = ASlimTimer.ST_SETTING.nextLocalTimeEntryId;
			db.insertTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN, 
			function(result:LoadResult):void {
				ASlimTimer.TASKS_CONTROLLER.timeEntries.addItem(_timeEntry);
				result.targetCommand = getInstance();
				callback(result);
			});
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			var result:LoadResult = new LoadResult();
			result.targetCommand = this;
			if (_timeEntry == null) {
				callback(result);
				return;
			}

			if (_timeEntry.task == null || _timeEntry.task.id < 0) {
				trace("taskの登録が未だのため、timeEntryはサーバーに更新されませんでした。");
				callback(result);
				return;			
			}
			
			slimTimerController.executeCreateTimeEntry(
			function(result:LoadResult):void {
				if (result.isSuccess) {
					var oldId:Number = _timeEntry.id;
					var newId:Number = Number(result.xml.id);
					if (oldId < 0) {
						_timeEntry.isCreated = false; 
						_timeEntry.isUpdated = true;
						sqLiteController.deleteTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
						ASlimTimer.TICK_CONTROLLER.updateTimeEntryId(oldId, newId);
					}
					//新しいIDとして再登録する
					_timeEntry.id = newId;
					_timeEntry.isCreated = true;
					sqLiteController.updateTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
				}
				result.targetCommand = getInstance();
				callback(result);
			},
			ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN, timeEntry);
		}
	}
}

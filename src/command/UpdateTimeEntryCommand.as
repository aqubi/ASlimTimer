/**
* TimeEntryを更新するCommand
* @author ogawahideko
*/
package command {
	import model.STTimeEntry;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;

	public class UpdateTimeEntryCommand implements ICommand{
		private var _timeEntry:STTimeEntry;
		[Bindable]
		public function set timeEntry(timeEntry:STTimeEntry):void { _timeEntry = timeEntry; }
		public function get timeEntry():STTimeEntry { return _timeEntry; }

		public function UpdateTimeEntryCommand(timeEntry:STTimeEntry) {
			_timeEntry = timeEntry;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			_timeEntry.isUpdated = false;
			sqLiteController.updateTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN, 
			function(result:LoadResult):void {
				result.targetCommand = getInstance();
				callback(result);
			});
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			var result:LoadResult = new LoadResult();
			result.targetCommand = this;
			if (_timeEntry == null  || _timeEntry.isUpdated) {
				callback(result);
				return;
			}

			if (_timeEntry.task == null || _timeEntry.task.id < 0) {
				trace("taskの登録が未だのため、timeEntryはサーバーに更新されませんでした。");
				callback(result);
				return;			
			}
trace("executeUpdateTimeEntry:" + _timeEntry.id);
			slimTimerController.executeUpdateTimeEntry(_timeEntry, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN,
			function(result:LoadResult):void {
				if (result.isSuccess) {
					//更新に成功したらDBからは削除しておく
					if (_timeEntry.id < 0) {
						_timeEntry.isCreated = false;
						sqLiteController.deleteTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
					}
					_timeEntry.isUpdated = true;
					sqLiteController.updateTimeEntry(_timeEntry, ASlimTimer.ST_TOKEN);
				}
				result.targetCommand = getInstance();
				callback(result);
			});
		}
	}
}

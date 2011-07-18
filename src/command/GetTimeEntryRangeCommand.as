/**
 * TimeEntryの期間指定一覧を取得するコマンド
 * @author ogawahideko
 */
package command {
	
import mx.collections.ArrayCollection;
import model.STTask;
import model.STTimeEntry;
import http.LoadResult;
import controller.SlimTimerController;
import controller.SQLiteController;
import controller.TasksController;


public class GetTimeEntryRangeCommand implements ICommand {

	private var _start:String;
	private var _end:String;
	private var _isWork:Boolean;
	private var _callback:Function;
	
	public function GetTimeEntryRangeCommand(rangeStart:String, rangeEnd:String, callback:Function, isWork:Boolean=false) {
		_start = rangeStart;
		_end = rangeEnd;
		_isWork = isWork;
		_callback = callback;
	}

	private function getInstance():ICommand {
		return this;
	}

	/* DBから取得 */
	public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
		var list:ArrayCollection = sqLiteController.getSelectTimeEntryByDate(_start, _end, ASlimTimer.ST_TOKEN);
		if (_isWork) {
			ASlimTimer.TASKS_CONTROLLER.workTimeEntries = list;
		} else {
			ASlimTimer.TASKS_CONTROLLER.timeEntries = list;
		}
		var result:LoadResult = new LoadResult();
		result.targetCommand = getInstance();
		callback(result);
		if (_callback != null) {
			_callback();
		}
	}
	
	/* SlimTimerのServiceに更新する */
	public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
		slimTimerController.executeGetTimeEntries(_start, _end, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN, 
				function(result:LoadResult, work:ArrayCollection):void {
					for each(var time:STTimeEntry in work) {
						time.isCreated = true;
						time.isUpdated = true;
						sqLiteController.updateTimeEntry(time, ASlimTimer.ST_TOKEN);
					}
					
					if (_isWork) {
						ASlimTimer.TASKS_CONTROLLER.workTimeEntries = work;
					} else {
						ASlimTimer.TASKS_CONTROLLER.timeEntries = work;
					}
					if (callback != null) {
						result.targetCommand = getInstance();
						callback(result);
					}
					if (_callback != null) {
						_callback();
					}
				}
			);
	}

}
}
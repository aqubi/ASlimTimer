/**
 * 新しいAlarmを作成するCommand
 * @author ogawahideko
 */
package command {
import model.STAlarm;
import http.LoadResult;
import controller.SlimTimerController;
import controller.SQLiteController;
import controller.AlarmController;

/**
 * TimeEntryを新規作成するコマンド
 */
public class NewAlarmCommand implements ICommand {
	private var _alarm:STAlarm;
	public function set alarm(alarm:STAlarm):void { _alarm = alarm; }
	public function get alarm():STAlarm { return _alarm; }

	public function NewAlarmCommand(alarm:STAlarm) {
		_alarm = alarm;
	}

	private function getInstance():ICommand {
		return this;
	}

	/* DBに更新する */
	public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
		alarm.id = ASlimTimer.ST_SETTING.nextLocalAlarmId;
    	sqLiteController.insertAlarm(alarm, 
    		function myFunc(result:LoadResult):void {
    				result.targetCommand = getInstance();
    				callback(result);
	    			ASlimTimer.ALARM_CONTROLLER.alarms.addItem(alarm); //一覧に追加
	    		});
	}
	
	/* SlimTimerのServiceに更新する */
	public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
		//サーバの更新はなし
		var result:LoadResult = new LoadResult();
		result.targetCommand = getInstance();
	    callback(result);	
	}
	

}
}
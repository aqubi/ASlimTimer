/**
 * Alartの一覧を取得するコマンド
 * @author ogawahideko
 */
package command {

import http.LoadResult;
import controller.SlimTimerController;
import controller.SQLiteController;
import controller.AlarmController;


public class GetAlarmListCommand implements ICommand {

	/* DBから取得 */
	public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
		ASlimTimer.ALARM_CONTROLLER.alarms = sqLiteController.loadAlarm();
		callback(createLoadResult());
	}
	
	/* SlimTimerのServiceに更新する */
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
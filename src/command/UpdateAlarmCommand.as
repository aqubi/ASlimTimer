/**
* Alarmを更新するCommand
* @author ogawahideko
*/
package command {
	import model.STAlarm;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.AlarmController;

	public class UpdateAlarmCommand implements ICommand {
		private var _alarm:STAlarm;
		public function set alarm(alarm:STAlarm):void { _alarm = alarm; }
		public function get alarm():STAlarm { return _alarm; }

		public function UpdateAlarmCommand(alarm:STAlarm) {
			_alarm = alarm;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			sqLiteController.updateAlarm(_alarm,
			function myFunc(result:LoadResult):void {
				result.targetCommand = getInstance();
				callback(result);
			});
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			//サーバの更新はなし
			var result:LoadResult = new LoadResult();
			result.targetCommand = this;
			callback(result);	
		}
	}
}

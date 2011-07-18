/**
* Alarmを削除するCommand
* @author ogawahideko
*/
package command {
	import mx.collections.ArrayCollection;

	import model.STAlarm;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.AlarmController;

	public class DeleteAlarmCommand implements ICommand {
		private var _alarm:STAlarm;
		public function set alarm(alarm:STAlarm):void { _alarm = alarm; }
		public function get alarm():STAlarm { return _alarm; }

		public function DeleteAlarmCommand(alarm:STAlarm) {
			_alarm = alarm;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			sqLiteController.deleteAlarm(_alarm,
			function myFunc(result:LoadResult):void {
				var alarms:ArrayCollection = ASlimTimer.ALARM_CONTROLLER.alarms;
				var i:int = alarms.getItemIndex(alarm);
				alarms.removeItemAt(i);
				alarms.refresh();
				result.targetCommand = getInstance();	
				callback(result);

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

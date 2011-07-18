/**
* 認証を行なうCommand
* @author ogawahideko
*/
package command {
	import mx.collections.ArrayCollection;

	import model.STAlarm;
	import http.LoadResult;
	import controller.SlimTimerController;
	import controller.SQLiteController;
	import controller.AlarmController;

	public class AuthCommand implements ICommand {

		private var callbackFunction:Function;

		public function AuthCommand(callback:Function) {
			callbackFunction = callback;
		}

		private function getInstance():ICommand {
			return this;
		}

		/* DBに更新する */
		public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
			//DBの更新はなし
			var result:LoadResult = new LoadResult();
			result.targetCommand = getInstance();
			callback(result);	
		}

		/* SlimTimerのServiceに更新する */
		public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
			slimTimerController.auth(ASlimTimer.ST_USER, 
			function(result:LoadResult):void {
				result.targetCommand = getInstance();
				callbackFunction(result);
				callback(result);
			});
		}
	}
}

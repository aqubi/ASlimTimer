/**
 * Taskの一覧を取得するコマンド
 * @author ogawahideko
 */
package command {
	
import mx.collections.ArrayCollection;
import model.STTask;
import http.LoadResult;
import controller.SlimTimerController;
import controller.SQLiteController;
import controller.TasksController;

import flash.utils.describeType;
public class GetTaskListCommand implements ICommand {

	private function getInstance():ICommand {
		return this;
	}

	/* DBから取得 */
	public function updateDB(sqLiteController:SQLiteController, callback:Function):void {
		var myInstance:ICommand = this;
		sqLiteController.selectTasks(ASlimTimer.ST_TOKEN, 
		function(result:LoadResult, work:ArrayCollection):void {
			ASlimTimer.TASKS_CONTROLLER.tasks = work;
			if (callback != null) { 
				result.targetCommand = getInstance();
				callback(result); }
		});
	}
	
	/* SlimTimerのServiceに更新する */
	public function updateService(sqLiteController:SQLiteController, slimTimerController:SlimTimerController, callback:Function):void {
		slimTimerController.executeGetTasks(
    		function(result:LoadResult, works:ArrayCollection):void { 
    			if (result.isSuccess) {
			       sqLiteController.deleteInsertTasks(works, ASlimTimer.ST_TOKEN);
			       //ASlimTimer.TASKS_CONTROLLER.tasks = works;
			       updateDB(sqLiteController, callback);
			       return;
		       } else {
					trace("error! completeGetTasksFromNetwork");
		       }
		       result.targetCommand = getInstance();
		       if (callback != null) { callback(result); }
    		}, ASlimTimer.ST_USER, ASlimTimer.ST_TOKEN, 'yes');
	}

}
}
/**
 * @author ogawahideko
 */
package command {
import controller.SlimTimerController;
import controller.SQLiteController;

public interface ICommand {
	function updateDB(db:SQLiteController, callback:Function):void;
	
	function updateService(sqLiteController:SQLiteController, service:SlimTimerController, callback:Function):void;
	

}
}
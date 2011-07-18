/**
 * @author ogawahideko
 */
package export {
	
import flash.display.*;
import flash.text.*;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.events.MouseEvent;
import flash.events.Event;
import mx.controls.Alert;

import model.*;
public class DataExpoort {
public function DataExpoort() {
	
}

public function export():void {
	exportTask();
	exportTimeEntry();
	Alert.show("出力完了.\nUTFにて出力しています。\n"
	 + "出力場所はアプリケーションディレクトリ内の \nexport_task.xml, export_timeentry.xml です。");
}

public function exportTask():void {
	var _file:File = File.applicationStorageDirectory;
	_file = _file.resolvePath("export_task.xml");
	var _stream:FileStream = new FileStream();
	_stream.open(_file, FileMode.WRITE);
	try {
	
	 for each (var task:STTask in ASlimTimer.TASKS_CONTROLLER.tasks) {
	 		_stream.writeUTFBytes(
	 		task.id 
	 		+ "\t" + task.name 
	 		+ "\t" + task.tags 
	 		+ "\t" + task.hours + "\n");
	 }
	 } catch (error:Error) {
		trace("ERROR "+ error.message);
     } finally{
        _stream.close();
     }
}

public function exportTimeEntry():void {
	var _file:File = File.applicationStorageDirectory;
	_file = _file.resolvePath("export_timeentry.xml");
	var _stream:FileStream = new FileStream();
	_stream.open(_file, FileMode.WRITE);
	try {
	
	 for each (var time:STTimeEntry in ASlimTimer.TASKS_CONTROLLER.timeEntries) {
	 		_stream.writeUTFBytes(time.id  
	 		+ "\t" + time.task 
	 		+ "\t" + getDateString(time.startTime)
	 		+ "\t" + getDateString(time.endTime)
	 		+ "\t" + time.tags
	 		+ "\t" + time.comments + "\n");
	 }
	 } catch (error:Error) {
		trace("ERROR "+ error.message);
     } finally{
        _stream.close();
     }
}

private function getDateString(date:Date):String {
	return String(date.fullYear) + (date.month + 1) + String(date.date)
	+ String(date.hours + 1) + String(date.minutes) + String(date.seconds);
}

}

}
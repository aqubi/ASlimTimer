/**
 * @author ogawahideko
 */
package controller {
import model.STBatchTimeEntry;
import model.STTask;
import view.BatchPreview;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;

import mx.controls.TextArea;

public class BatchController {

	public function parseString(list:String, selectedDate:Date, parent:ASlimTimer, callback:Function):void {
		var lines:Array = list.split("\r\n");
		if (lines.length == 1) {
			lines = list.split("\n");
		}
		if (lines.length == 1) {
			lines = list.split("\r")
		}
//		trace(list);
//		for (var i:int = 0; i < list.length; i++) {
//			trace(i + ":" + list.charCodeAt(i));
//		}

//		var area:TextArea = new TextArea();
//		area.text = "a\r\nb";
//		trace("area.text=" + area.text, ", area.text.length=" + area.text.length);
		var updateTasks:Object = new Object();
		var updateTimeEntries:ArrayCollection = new ArrayCollection();
		var isError:Boolean = false;
		
		var tabSplitClosure:Function = function(item:String, index:Number, arr:Array):void{
			if (item.length == 0) {
				return;
			}
			var patternStr:String = "^(.+) (\\d\\d:\\d\\d) (\\d\\d:\\d\\d)[ ]*(.*)$";
	        var pattern:RegExp = new RegExp(patternStr, "i") ; 
	        var result:Array = pattern.exec(item);
	        trace(result);
	        if (result == null) {
	        	return;
	        }
			//arr[index] = item.split(" ");
			var timeEntry:STBatchTimeEntry = createBatchTimeEntry(result, updateTasks, selectedDate);
			updateTimeEntries.addItem(timeEntry);
			if (timeEntry.status == STBatchTimeEntry.STATUS_ERROR) {
				isError = true;
			}
		}
		lines.forEach(tabSplitClosure);

		if (updateTimeEntries.length > 0) {
			var window:BatchPreview = BatchPreview(
			PopUpManager.createPopUp(parent, BatchPreview , true));
			window.init(updateTimeEntries, updateTasks, selectedDate, isError, callback);
			PopUpManager.centerPopUp(window);
		}
		
	}
	
	public function createBatchTimeEntry(items:Array, updateTasks:Object, selectedDate:Date):STBatchTimeEntry {
		var timeEntry:STBatchTimeEntry = new STBatchTimeEntry();
		
		var taskName:String = items[1];
		timeEntry.task = ASlimTimer.TASKS_CONTROLLER.getTask(NaN, taskName);
		
		var newEntryTask:STTask = null; //新しく追加するタスク
		if (timeEntry.task == null) {
			//Taskが見つからなかった時新しく作成する用に用意する
			var newTask:STTask = updateTasks[taskName];
			if (newTask == null) {
				newTask = new STTask();
				newTask.name = taskName;
				newTask.id = NaN;
				newEntryTask = newTask;
			}
			timeEntry.task = newTask;
		}

		if (items.length > 2) {
			var startTime:String = items[2];
		}
		if (items.length > 3) {
			var endTime:String = items[3];
		}
		
		if (items.length < 4 ){
			timeEntry.status = STBatchTimeEntry.STATUS_ERROR;
			timeEntry.statusMessage = "The format is illegal. ";
			return timeEntry;
		}
		
		var comment:String = "";
		if (items.length >=5 ) {
			comment = items[4];
		}

		timeEntry.comments = comment;
		var start:Date = formatTimeToDate(startTime, selectedDate);
		
		if (start == null) {
			timeEntry.status = STBatchTimeEntry.STATUS_ERROR;
			timeEntry.statusMessage = "It was not parse starttime. ";
			return timeEntry;		
		} else {
			timeEntry.startTime = start;
		}
		
		var end:Date = formatTimeToDate(endTime, selectedDate);
		if (end == null) {
			timeEntry.status = STBatchTimeEntry.STATUS_ERROR;
			timeEntry.statusMessage = "It was not parse endtime. ";
			return timeEntry;		
		} else {
			timeEntry.endTime = end;
		}
		
		timeEntry.durationInSeconds = int((timeEntry.endTime.time - timeEntry.startTime.time) / 1000);
		
		if (newEntryTask != null) {
			timeEntry.statusMessage = "Task and TimeEntry are added. ";
			//新規作成タスクを追加用に保持
			updateTasks[taskName] = newEntryTask;

		} else {
			timeEntry.statusMessage = "TimeEntry is added. ";
		}
		
		timeEntry.status = STBatchTimeEntry.STATUS_OK;
		timeEntry.inProgress = false;
		timeEntry.createdAt = start;
		
		
		return timeEntry;
	}


	private function formatTimeToDate(value:String, selectedDate:Date):Date {
		if (value == null || value.length == 0) {
			return null;
		}
		var patternStr:String = "(\\d{2}):(\\d{2})";
        var pattern:RegExp = new RegExp(patternStr, "i") ; 
        var result:Array = pattern.exec(value);
		var date:Date = new Date();
		date.fullYear = selectedDate.fullYear;
		date.month = selectedDate.month;
		date.date = selectedDate.date;
		if (result != null && result.length > 2) {
	        date.hours = result[1];
	        date.minutes = result[2];
	        date.seconds = 00;
	        return date;
		} else {
			return null;
		}

 	}
}
}
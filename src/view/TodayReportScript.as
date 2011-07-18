
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import flash.net.*;
import flash.events.*;
import flash.ui.Keyboard;

import controller.WindowController;
import model.STTimeEntry;
import model.STTask;


[Bindable]
private var text:String;
private var tasks:ArrayCollection;
private var times:ArrayCollection;

public function init(window:ASlimTimer):void {
	text = "wait a minutes....";
	addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ESCAPE) {
            onClose();
        }
    });
    WindowController.changeDialogTheme(this);
    WindowController.changeTextAlpha([body]);
 
//    ASlimTimer.TASKS_CONTROLLER.refreshTaskAllListFromNetwork(
//    	function(gettasks:ArrayCollection):void {
//    		tasks = gettasks;
//    		ASlimTimer.TASKS_CONTROLLER.getTodayTimeEntry(
//	    	function(getTimes:ArrayCollection):void {
//		    		times = getTimes;
//		    		parse();
//		    	}
//		    );
//    	}
//    );
}

private function parse():void {
    var still:String = "";
    var completed:String = "";
    var created:String = "";
    var sumTime:Object = new Object();
    var taskIds:Object = new Object();
    
     for (var i:Number = 0; i < times.length; i++) {
     	var taskId:Number = times[i].taskId;
     	var seconds:Number = times[i].durationInSeconds;
     	sumTime[taskId] = (sumTime[taskId] == null) ? seconds : sumTime[taskId] + seconds;
     	taskIds[taskId] = taskId;
     }
 
     for each (var id:Number in taskIds) {
     	var task:STTask = getTask(id);
    	if (task == null) { continue;}
    	var sum:Number = sumTime[id];
    	var sumStr:String = Number(sum / 3600).toFixed(2) + " h";
    	if (isToday(task.completedOn)) {
    		completed = completed + task.name + " " + sumStr + " \n";
    	} else {
    		still = still + task.name + " " + sumStr  + "\n";
    	}
    	if (isToday(task.createdAt)) {
    		created = created + task.name + "\n";
    	}
     }
	text = "≪IN≫\n" + created + "≪OUT≫\n" + completed + "≪STILL≫\n" + still;
}



protected function onClose():void {
	PopUpManager.removePopUp(this);
}

private function isToday(date:Date):Boolean {
	if (date == null) {
		return false;
	}
	var today:Date =  new Date();
	if (date.fullYear == today.fullYear
		&& date.month == today.month
		&& date.date == today.date) {
		return true;
	} else {
		//trace(date + " is not today." + today);
		return false;
    }	
}

/* TimeEntryから関連するTaskを取得する */
public function getTask(id:Number):STTask {
	for	each (var task:STTask in tasks) {
		if (task.id == id) {
			return task;
		}
	}
	return null;
}

package model {
import model.STTask;
import mx.collections.ArrayCollection;
public class STAlarm {
	[Bindable]
	public var sounds:Array = ["no sound", "bell-1", "bell-2"];
	public var mp3s:Array = ["", "../mp3/alarm1.mp3", "../mp3/chime1s.mp3"];
	

	private var _id:Number;
	private var _name:String;
	private var _hours:Number = 0;
	private var _minutes:Number = 0;
	private var _date:Date;
	private var _mp3:String = sounds[0];
	private var _taskId:Number;
	private var _oneTimeOnly:Boolean = false;
	
	[Bindable] 
	public function set id(id:Number):void { _id = id; }
	public function get id():Number { return _id; }
	[Bindable] 
	public function set name(name:String):void { _name = name; }
	public function get name():String { return _name; }
	[Bindable] 
	public function set hours(hours:Number):void { _hours = hours; }
	public function get hours():Number { return _hours; }
	[Bindable] 
	public function set minutes(minutes:Number):void { _minutes = minutes; }
	public function get minutes():Number { return _minutes; }
	[Bindable] 
	public function set date(date:Date):void { _date = date; }
	public function get date():Date { return _date; }
	[Bindable] 
	public function set mp3(mp3:String):void { _mp3 = mp3; }
	public function get mp3():String { return _mp3; }
	[Bindable] 
	public function set taskId(taskId:Number):void { _taskId = taskId; }
	public function get taskId():Number { return _taskId; }
	[Bindable]
	public function set oneTimeOnly(oneTimeOnly:Boolean):void { _oneTimeOnly = oneTimeOnly; }
	public function get oneTimeOnly():Boolean { return _oneTimeOnly; }
	
	// ------------
	[Bindable ("readonly")]
	public function get tasks():ArrayCollection {
		return ASlimTimer.TASKS_CONTROLLER.tasks;
	}

	[Bindable ("readonly")]
	public function get time():String {
		var value:String = '';
		if (date != null) {
			value = date.fullYear + "/" + get2LengthValue(date.month + 1) + "/" 
			+ get2LengthValue(date.date) + " ";
		}
		return value + get2LengthValue(hours) + ":" + get2LengthValue(minutes);
	}
	
	private function get2LengthValue(number:int):String {
		if (String(number).length == 1) {
			return '0' + String(number);
		} else {
			return String(number);
		}
	}
	
	[Bindable ("readonly")]
	public function get taskSelectedIndex():int {
		var index:int = 0;
		for each(var task:STTask in ASlimTimer.TASKS_CONTROLLER.tasks) {
			if (task.id == taskId) {
				return index;
			} else {
				index++;
			}
		}
		if (ASlimTimer.TASKS_CONTROLLER.tasks.length > 0) {
			return 0;
		}
		return -1;
	}
	
	[Bindable ("readonly")]
	public function get mp3SelectedIndex():int {
		for (var i:int = 0; i < mp3s.length; i++) {
			if (mp3 == mp3s[i]) {
				return i;
			}
		}
		return 1;
	}
	
	[Bindable ("readonly")]
	public function get isDateSelected():Boolean {
		return (date != null);
	}
	
	[Bindable ("readonly")]
	public function get dateString():String {
		if (date == null) {
			return '';
		} else {
			return date.fullYear + "/" + (date.month + 1) + "/" + date.date;
		}
	}
	
	public function getMp3(index:int):String {
		return mp3s[index];
	}
		

}
}
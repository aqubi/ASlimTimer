package http {
import flash.events.Event;
import flash.events.SQLEvent;
import command.ICommand;

public class LoadResult {
	private var _httpStatus:Number = 200;;
	private var _message:String;
	private var _xml:XML;
	private var _sqlEvent:SQLEvent;
	private var _targetCommand:ICommand;
	
	
	[Bindable]
	public function set httpStatus(httpStatus:Number):void { _httpStatus = httpStatus; }
	public function get httpStatus():Number { return _httpStatus; }
	
	[Bindable]
	public function set message(message:String):void { _message = message; }
	public function get message():String { 
		if (_message != null) {
			return _message;
		} else if (_sqlEvent != null) {
			return String(_sqlEvent);
		} else {	
			return '';
		} 
	}
	
	[Bindable]
	public function set xml(xml:XML):void { _xml = xml; }
	public function get xml():XML { return _xml; }
	
	[Bindable]
	public function set sqlEvent(sqlEvent:SQLEvent):void { _sqlEvent = sqlEvent; }
	public function get sqlEvent():SQLEvent { return _sqlEvent; }
	
	[Bindable]
	public function set targetCommand(targetCommand:ICommand):void { _targetCommand = targetCommand; }
	public function get targetCommand():ICommand { return _targetCommand; }

	
	public function get isSuccess():Boolean { 
		if (_httpStatus == 200) {
			return true;
		} else {
			return false;
		}
	}
	
}
} 
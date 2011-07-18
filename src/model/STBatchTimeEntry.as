/**
 * @author ogawahideko
 */
package model {
public class STBatchTimeEntry extends STTimeEntry{
	public static const STATUS_OK:String = "OK";
	public static const STATUS_ERROR:String = "ERROR";
	
	private var _status:String;
	[Bindable]
	public function set status(status:String):void { _status = status; }
	public function get status():String { return _status; }
	
	private var _statusMessage:String;
	[Bindable]
	public function set statusMessage(statusMessage:String):void { _statusMessage = statusMessage; }
	public function get statusMessage():String { return _statusMessage; }


	override public function get startTimeString():String {
		if (startTime == null) {
			return "";
		} else {
			return startTime.hours + ":" + startTime.minutes;
		}
	}
	
	override public function get endTimeString():String {
		if (endTime == null) {
			return "";
		} else {
			var ret:String;
			return endTime.hours + ":" + endTime.minutes;
		}
	}
	
}

}
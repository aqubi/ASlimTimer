package model {
public class STToken {

	private var _userId:Number;
	private var _accessToken:String;
	
	[Bindable] 
	public function set userId(userId:Number):void { _userId = userId; }
	public function get userId():Number { return _userId; }
	[Bindable] 
	public function set accessToken(accessToken:String):void { _accessToken = accessToken; }
	public function get accessToken():String { return _accessToken; }
}
}
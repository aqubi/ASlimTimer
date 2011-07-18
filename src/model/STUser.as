package model {
public class STUser {

	private var _email:String;
	private var _password:String;
	private var _apiKey:String;
	
	[Bindable] 
	public function set email(email:String):void { _email = email; }
	public function get email():String { return _email; }
	[Bindable] 
	public function set password(password:String):void { _password = password; }
	public function get password():String { return _password; }
	[Bindable] 
	public function set apiKey(apiKey:String):void { _apiKey = apiKey; }
	public function get apiKey():String { return _apiKey; }
}
}

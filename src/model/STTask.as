package model {
public class STTask {

	private var _id:Number;
	private var _name:String;
	private var _tags:String;
	private var _hours:Number = 0;
	private var _role:String;
	private var _updatedAt:Date;
	private var _completedOn:Date;
	private var _createdAt:Date;
	private var _ownerId:Number;
	private var _isCreated:Boolean = false;
	private var _isUpdated:Boolean = false;
	private var _isOfflineDeleted:Boolean = false;
	
	private var _isStar:Boolean;
	private var _isRest:Boolean;
	private var _isExcludeIdleCheck:Boolean;
	
	[Bindable] 
	public function set id(id:Number):void { _id = id; }
	public function get id():Number { return _id; }
	[Bindable] 
	public function set name(name:String):void { _name = name; }
	public function get name():String { return _name; }
	[Bindable] 
	public function set tags(tags:String):void { _tags = tags; }
	public function get tags():String { return _tags; }
	[Bindable] 
	public function set hours(hours:Number):void { _hours = hours; }
	public function get hours():Number { return _hours; }
	[Bindable] 
	public function set role(role:String):void { _role = role; }
	public function get role():String { return _role; }
	[Bindable] 
	public function set createdAt(createdAt:Date):void { _createdAt = createdAt; }
	public function get createdAt():Date { return _createdAt; }
	[Bindable] 
	public function set updatedAt(updateAt:Date):void { _updatedAt = updatedAt; }
	public function get updatedAt():Date { return _updatedAt; }
	[Bindable] 
	public function set completedOn(completedOn:Date):void { _completedOn = completedOn; }
	public function get completedOn():Date { return _completedOn; }
	[Bindable]
	public function set ownerId(ownerId:Number):void { _ownerId = ownerId; }
	public function get ownerId():Number { return _ownerId; }
	[Bindable] //SlimTimerのサーバに登録している情報かどうか
	public function set isCreated(isCreated:Boolean):void { _isCreated = isCreated; }
	public function get isCreated():Boolean { return _isCreated; }
	[Bindable] //SlimTimerのサーバに更新している情報かどうか
	public function set isUpdated(isUpdated:Boolean):void { _isUpdated = isUpdated; }
	public function get isUpdated():Boolean { return _isUpdated; }
	[Bindable] //Offlineで削除されているかどうか
	public function set isOfflineDeleted(isOfflineDeleted:Boolean):void {_isOfflineDeleted = isOfflineDeleted;}
	public function get isOfflineDeleted():Boolean {return _isOfflineDeleted; }

	[Bindable] //Starのマークがあるかどうか
	public function set isStar(isStar:Boolean):void { _isStar = isStar; }
	public function get isStar():Boolean { return _isStar; }
	[Bindable] //Restのマークがあるかどうか
	public function set isRest(isRest:Boolean):void { _isRest = isRest; }
	public function get isRest():Boolean { return _isRest; }
	[Bindable] //IdleCheckの例外にする
	public function set isExcludeIdleCheck(isExcludeIdleCheck:Boolean):void { _isExcludeIdleCheck = isExcludeIdleCheck; }
	public function get isExcludeIdleCheck():Boolean { return _isExcludeIdleCheck; }
	
	public function toString():String {
		return name;
	}
}
}
package model {
	import model.STTask;
	public class STTimeEntry {

		private var _id:Number;
		private var _startTime:Date;
		private var _endTime:Date;
		private var _durationInSeconds:Number;
		private var _tags:String;
		private var _comments:String;
		private var _inProgress:Boolean;
		private var _taskId:Number;
		private var _taskName:String;
		private var _task:STTask;
		private var _updatedAt:Date;
		private var _createdAt:Date;
		private var _isCreated:Boolean;
		private var _isUpdated:Boolean;
		private var _isOfflineDeleted:Boolean = false;

		[Bindable] 
		public function set id(id:Number):void { _id = id; }
		public function get id():Number { return _id; }
		[Bindable] 
		public function set startTime(startTime:Date):void { _startTime = startTime; }
		public function get startTime():Date { return _startTime; }
		[Bindable] 
		public function set endTime(endTime:Date):void { _endTime = endTime; }
		public function get endTime():Date { return _endTime; }
		[Bindable] 
		public function set durationInSeconds(durationInSeconds:Number):void { _durationInSeconds = durationInSeconds; }
		public function get durationInSeconds():Number { return _durationInSeconds; }
		[Bindable] 
		public function set tags(tags:String):void { _tags = tags; }
		public function get tags():String { return _tags; }
		[Bindable] 
		public function set comments(comments:String):void { _comments = comments; }
		public function get comments():String { return _comments; }
		[Bindable] 
		public function set inProgress(inProgress:Boolean):void { _inProgress = inProgress; }
		public function get inProgress():Boolean { return _inProgress; }
		[Bindable]
		public function set task(task:STTask):void { _task = task; }
		public function get task():STTask { return _task; }
		[Bindable] 
		public function set updatedAt(updatedAt:Date):void { _updatedAt = updatedAt;}
		public function get updatedAt():Date { return _updatedAt; }
		[Bindable] 
		public function set createdAt(createdAt:Date):void { _createdAt = createdAt; }
		public function get createdAt():Date { return _createdAt; }
		public function get createdAtString():String { return _createdAt.toLocaleTimeString(); }
		[Bindable] //SlimTimerのサーバに登録している情報かどうか
		public function set isCreated(isCreated:Boolean):void { _isCreated = isCreated; }
		public function get isCreated():Boolean { return _isCreated; }
		[Bindable] //SlimTimerのサーバに更新している情報かどうか
		public function set isUpdated(isUpdated:Boolean):void { _isUpdated = isUpdated; }
		public function get isUpdated():Boolean { return _isUpdated; }
		[Bindable] //Offlineで削除されているかどうか
		public function set isOfflineDeleted(isOfflineDeleted:Boolean):void {_isOfflineDeleted = isOfflineDeleted;}
		public function get isOfflineDeleted():Boolean {return _isOfflineDeleted; }


		[Bindable]
		public function get endTimeString():String { 
			return formatTimeToString(_endTime);
		}

		public function set endTimeString(time:String):void {
			if (_endTime == null) {
				_endTime = new Date();
			}
			formatTimeToDate(time, _endTime);
		}

		[Bindable]
		public function get startTimeString():String{ 
			return formatTimeToString(_startTime);
		}

		[Bindable(readonly)]
		public function get startDateString():String {
			return _startTime.fullYear + "/" + (_startTime.month + 1) + "/" + _startTime.date;
		}

		public function set startTimeString(time:String):void {
			formatTimeToDate(time, _startTime);
		}

		public function get durationInSecondsHour():String {
			return Number(_durationInSeconds / 3600).toFixed(2);
		}

		private function formatTimeToDate(value:String, date:Date):void {
			var patternStr:String = "(\\d{2}):(\\d{2}):(\\d{2})";
			var pattern:RegExp = new RegExp(patternStr, "i") ; 
			var result:Array = pattern.exec(value);

			date.hours = result[1];
			date.minutes = result[2];
			date.seconds = result[3];
		}

		private function formatTimeToString(date:Date):String {
			if (date == null) {
				return "";
			}
			var value:String = date.toTimeString(); 
			var patternStr:String = "(\\d{2}:\\d{2}:\\d{2}).*";
			var pattern:RegExp = new RegExp(patternStr, "i") ; 
			return value.replace(pattern, "$1");
		}
	}
}
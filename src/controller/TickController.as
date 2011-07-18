package controller {

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import model.STTask;
	import model.STTimeEntry;
	import http.LoadResult;
	import growl.DisplayManager;
	import growl.PriorityManager;

	/*
	* 経過時間を管理するController
	*/
	public class TickController {
		/* 時間を計測するTimer */
		protected var _tickTimer:Timer;
		protected var _startTime:Date;
		protected var _nowMinute:String;
		protected var _nowSecound:int;

		/* 登録対象のTimeEntry */
		protected var _timeEntry:STTimeEntry;

		/* 登録間の秒数 */
		protected var waitSecound:int;

		protected var currentTimeEntryId:Number;
		protected var currentTimeEntryTaskId:Number;

		protected var isCreated:Boolean;

		private var _todaySumTime:int = 0;
		[Bindable]
		public function set todaySumTime(todaySumTime:int):void { _todaySumTime = todaySumTime; }
		public function get todaySumTime():int { return _todaySumTime; }

		[Bindable]
		public var selectedItem:STTask;
		[Bindable]
		public function get tickTimer():Timer { return _tickTimer; }
		public function set tickTimer(tickTimer:Timer):void { _tickTimer = tickTimer; }
		[Bindable]
		public function get startTime():Date { return _startTime; }
		public function set startTime(time:Date):void { _startTime = time; }
		[Bindable]
		public function get nowMinute():String { return _nowMinute; }
		public function set nowMinute(minute:String):void { _nowMinute = minute; }
		[Bindable]
		public function get nowSecound():int { return _nowSecound; }
		public function set nowSecound(time:int):void { _nowSecound = time; }
		[Bindable]
		public function get timeEntry():STTimeEntry { return _timeEntry; }
		public function set timeEntry(timeEntry:STTimeEntry):void { _timeEntry = timeEntry; }

		private var displayManager:DisplayManager = new DisplayManager();

		private var notificationCaller:int;

		public function init():void {

		}

		public function clear():void {
			if (running) {
				stop();
			}
			this.selectedItem = null;
			startTime = null;
			nowMinute = '';
			nowSecound = 0;
		}

		/* Taskを開始(時間測定開始) */
		public function start(selectedItem:STTask):void {
			this.selectedItem = selectedItem;
			notificationCaller = 0;
			if (tickTimer == null) {
				tickTimer = new Timer(1000);
				tickTimer.addEventListener("timer", onTick);
			}

			tickTimer.reset();
			isCreated = false;
			timeEntry = new STTimeEntry();
			timeEntry.createdAt = new Date();
			timeEntry.startTime = new Date();
			timeEntry.task = selectedItem;
			timeEntry.inProgress = true;
			timeEntry.durationInSeconds = 1;
			tickTimer.start();
		}


		/* 1秒たったタイミングでのイベント */
		private function onTick(event:TimerEvent):void {
			updateProperty();
			var now:int = timeEntry.durationInSeconds + todaySumTime;

			nowSecound = now % 60;
			var sec:int = now / 60;
			var minute:int = sec % 60;
			var ho:int =  sec / 60;

			if (ho != 0) {
				nowMinute = ho + 'h  ';
			} else {
				nowMinute = '';
			}
			nowMinute = nowMinute + minute;

			waitSecound++;
			if (waitSecound > 10) {
				if (!isCreated) {
					createTime();
				} else {
					updateTime();
				}
				waitSecound = 0;
			}

			var minutePassed:int = timeEntry.durationInSeconds / 60 % 60;
			if (notificationCaller < minutePassed) {
				fireNotification(minutePassed);
				notificationCaller = minutePassed;
			}
		}

		private function fireNotification(minute:int):void {
			var message:String = String(minute);
			if (ASlimTimer.ST_SETTING.nfAlert > 0
			&& minute % ASlimTimer.ST_SETTING.nfAlert == 0) {
				displayManager.displayMessage(
				timeEntry.task.name, 
				message, 
				4,
				null);
				return;
			}

			if (ASlimTimer.ST_SETTING.nfWarning > 0
			&& minute % ASlimTimer.ST_SETTING.nfWarning == 0) {
				displayManager.displayMessage(
				timeEntry.task.name, 
				message, 
				3,
				null);
				return;
			}

			if (ASlimTimer.ST_SETTING.nfConfirm > 0
			&& minute % ASlimTimer.ST_SETTING.nfConfirm == 0) {
				displayManager.displayMessage(
				timeEntry.task.name, 
				message, 
				1,
				null);
				return;
			}
		}

		/* TimerEntryの属性を最新のものに変更 */
		private function updateProperty():void {
			timeEntry.updatedAt = new Date();
			timeEntry.endTime = new Date();
			timeEntry.durationInSeconds = int((timeEntry.endTime.time - timeEntry.startTime.time) / 1000);	
		}

		/* TimeEntryを作成　*/
		private function createTime():void {
			updateProperty();
			ASlimTimer.TASKS_CONTROLLER.executeCreateTimeEntry(onExecuteEnd, timeEntry);
			isCreated = true;
		}

		/* Entryが完了したタイミング */
		private function onExecuteEnd(result:LoadResult):void {
			if (!result.isSuccess || timeEntry.id == 0) {
				//不正なIDだった場合にはチェックを止める
				tickTimer.stop();
			}
		}

		/* TimeEntry途中の情報を更新 */
		private function updateTime():void {
			if (isNaN(timeEntry.id)) {
				return;//登録がまだだった場合には処理なし
			}
			ASlimTimer.TASKS_CONTROLLER.executeUpdateTimeEntry(onUpdateEnd, timeEntry);
		}

		/* 更新が完了したタイミング */
		private function onUpdateEnd(result:LoadResult):void {
			//trace("executeUpdateTimeEntry end:");
		}


		/* Taskを停止 */
		public function stop():void {
			if (tickTimer != null) {
				tickTimer.stop();
			}
			updateProperty();
			timeEntry.inProgress = false;
			notificationCaller = 0;
			if (isCreated) {
				ASlimTimer.TASKS_CONTROLLER.executeUpdateTimeEntry(onUpdateEnd, timeEntry);
			}
		}


		/* 現在Timerは動作しているか */
		public function get running():Boolean {
			if (tickTimer == null) {
				return false;
			}
			return tickTimer.running;
		}

		public function updateTaskId(oldTaskId:Number, newTaskId:Number):void {
			if (selectedItem != null && selectedItem.id == oldTaskId) {
				selectedItem.id = newTaskId;
				selectedItem.isCreated = true;
				selectedItem.isUpdated = true;
				trace("update task id " + oldTaskId + " → " + newTaskId);
			}
		}
		public function updateTimeEntryId(oldId:Number, newId:Number):void {
			if (_timeEntry != null && _timeEntry.id == oldId) {
				_timeEntry.id = newId;
				_timeEntry.isCreated = true;
				_timeEntry.isUpdated = true;
				trace("update timeentry id " + oldId + " → " + newId);
			}
		}
	}
}

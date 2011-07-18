package controller {

	import mx.controls.Alert;
	import mx.collections.ArrayCollection;
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.data.SQLResult;
	import flash.events.SQLEvent;
	import flash.events.SQLErrorEvent;
	import flash.filesystem.File;

	import http.LoadResult;
	import model.STTask;
	import model.STTimeEntry;
	import model.STBatchTimeEntry;
	import command.*;

	/*
	* Taskの制御
	*/
	public class TasksController {

		/* SlimTimerのServiceへ更新するクラス */
		private var _serviceUpdater:ServiceUpdater = new ServiceUpdater();
		[Bindable]
		public function set serviceUpdater(serviceUpdater:ServiceUpdater):void { _serviceUpdater = serviceUpdater; }
		public function get serviceUpdater():ServiceUpdater { return _serviceUpdater; }

		/* 起動画面 */
		protected var window:ASlimTimer;

		/* タスク一覧 */
		private var _tasks:ArrayCollection = new ArrayCollection();
		[Bindable]
		public function get tasks():ArrayCollection{return _tasks;}
		public function set tasks(tasks:ArrayCollection):void{
			_tasks = tasks;
			taskFilter(filterString);
		}

		/* TimeEntry一覧(画面上に表示するTimeEntry) */
		private var _timeEntries:ArrayCollection = new ArrayCollection();
		[Bindable]
		public function get timeEntries():ArrayCollection{return _timeEntries;}
		public function set timeEntries(timeEntries:ArrayCollection):void{
			// 開始中のTimeEntryに反映する
			if (ASlimTimer.TICK_CONTROLLER.timeEntry != null) {
				for each (var mytime:STTimeEntry in timeEntries) {
					if (mytime.id == ASlimTimer.TICK_CONTROLLER.timeEntry.id) {
						ASlimTimer.TICK_CONTROLLER.timeEntry = mytime;
					}
				}
			}
			_timeEntries = timeEntries;
			timeEntriesFilter();
		}

		/* Work用のTimeEntry一覧 */
		private var _workTimeEntries:ArrayCollection = new ArrayCollection();
		[Bindable]
		public function set workTimeEntries(workTimeEntries:ArrayCollection):void { _workTimeEntries = workTimeEntries; }
		public function get workTimeEntries():ArrayCollection { return _workTimeEntries; }

		/* 完了したタスクを表示するかどうか */
		protected var _showCompleted:String = new String("no");
		[Bindable]
		public function get showCompleted():String{return _showCompleted;}
		public function set showCompleted(showCompleted:String):void{_showCompleted = showCompleted;}

		/* 初期化 */
		public function init(slimTimer:ASlimTimer):void {
			window = slimTimer;
			//		ASlimTimer.NETWORK_CHECKER.addNetworkListener(onNetworkChanged);
		}

		// ****************************************
		// タスク一覧の取得
		// ****************************************
		/* タスクリストを取得する */
		public function getTaskList():void {
			var getTasksCommand:GetTaskListCommand = new GetTaskListCommand();
			serviceUpdater.addCommand(getTasksCommand);	
		}

		// ****************************************
		// タスクの追加,更新,削除
		// ****************************************
		/* タスクを追加する */
		public function createTask(callbackFunc:Function, task:STTask):void {
			var newTaskCommand:NewTaskCommand = new NewTaskCommand(task);
			serviceUpdater.addCommand(newTaskCommand);
		}    

		private function showAlertNotPossible():void {
			Alert.show(window.rb("ItIsNotPossibleToExecuteItInAnOffline"));
		}

		/* タスクを更新する */
		public function updateTask(callbackFunc:Function, task:STTask):void {
			var updateTaskCommand:UpdateTaskCommand = new UpdateTaskCommand(task);
			serviceUpdater.addCommand(updateTaskCommand);
		}

		/* タスクを削除する */
		public function deleteTask(callbackFunc:Function, task:STTask):void {
			serviceUpdater.addCommand(new DeleteTaskCommand(task));
			serviceUpdater.addCommand(new GetAlarmListCommand());
		}

		// ****************************************
		// TimeEntryの更新
		// ****************************************

		/* TimeEntryを作成する */
		public function executeCreateTimeEntry(callbackFunc:Function, timeEntry:STTimeEntry):void {
			var newTimeCommand:NewTimeEntryCommand = new NewTimeEntryCommand(timeEntry);
			serviceUpdater.addCommand(newTimeCommand);
		}

		/* TimeEntryを更新する */
		public function executeUpdateTimeEntry(callbackFunc:Function, timeEntry:STTimeEntry):void {
			var updateTimeEntryCommand:UpdateTimeEntryCommand = new UpdateTimeEntryCommand(timeEntry);
			serviceUpdater.addCommand(updateTimeEntryCommand);
		}

		/* TimeEntryを削除する */
		public function executeDeleteTimeEntry(timeEntry:STTimeEntry):void {
			var deleteTimeCommand:DeleteTimeEntryCommand = new DeleteTimeEntryCommand(timeEntry);
			serviceUpdater.addCommand(deleteTimeCommand);
		}

		/* TimeEntryを日付範囲指定で取得する */
		public function getTimeEntryRange(rangeStart:String, rangeEnd:String, onComplete:Function = null, isToday:Boolean = false):void {
			var getTimeEntryCommand:GetTimeEntryRangeCommand = new GetTimeEntryRangeCommand(rangeStart, rangeEnd, onComplete, isToday);
			serviceUpdater.addCommand(getTimeEntryCommand);
		}


		// ***********************************************
		// オンライン時の同期処理
		// ***********************************************

		/* DBの情報をサーバーに更新する同期処理 */
		public function sync():void {
			//if (tasks.length == 0) { return; }
			serviceUpdater.addCommand(new SyncTaskAppender(serviceUpdater));
		}

		/* 一括更新用の同期処理 */
		public function syncBatch(callback:Function, times:ArrayCollection, tasks:Object):Boolean {
			for each(var taskName:String in tasks) {
				var task:STTask = tasks[taskName];
				task.createdAt = new Date();
				task.tags = "";
				var newCommand:NewTaskCommand = new NewTaskCommand(task);
				serviceUpdater.addCommand(newCommand);
			}

			for each(var timeEntry:STBatchTimeEntry in times) {
				if (timeEntry.status == STBatchTimeEntry.STATUS_ERROR) {
					continue;
				}
				var newTimeCommand:NewTimeEntryCommand = new NewTimeEntryCommand(timeEntry);
				serviceUpdater.addCommand(newTimeCommand);
			}

			if (tasks.length > 0 || times.length > 0) {
				serviceUpdater.showProgressDialog();
				serviceUpdater.callback = callback;
			}
			return true;
		}


		// ************************************************
		// Filter
		// ************************************************
		private var filterString:String;
		public function taskFilter(value:String):void {
			filterString = value;
			_tasks.filterFunction = doFilter;
			_tasks.refresh();
		}

		public function doFilter(mydata:Object):Boolean {
			if (showCompleted == 'no' && mydata.completedOn != null) {
				return false;
			}
			if (showCompleted == 'only' && mydata.completedOn == null) {
				return false;
			}
			if (filterString == null || filterString.length == 0) {
				return true;
			} 
			var v:String = mydata.name;
			if (v.match(filterString)) {
				return true;
			} else {
				return false;
			}
		}

		private var timeFilterString:String;
		public function timeFilter(value:String):void {
			timeFilterString = value;
			timeEntriesFilter();
		}

		private function timeEntriesFilter():void {
			if (timeEntries == null) {
				return;
			}
			if (timeFilterString == null || timeFilterString.length == 0) {
				timeEntries.filterFunction = null;
			} else {
				timeEntries.filterFunction = doTimeFilter;
			}
			timeEntries.refresh();
		}

		private function doTimeFilter(mydata:Object):Boolean {
			var v:String = mydata.task.name;
			if (v.match(timeFilterString)) {
				return true;
			} else {
				return false;
			}
		}

		// ************************************************
		// Task,TimeEntryの情報を取得するメソッド
		// ************************************************
		/* Taskのオブジェクトを取得する */
		public function getTask(taskId:Number, taskName:String=null):STTask {
			for each(var task:STTask in _tasks.source) {
				if (!isNaN(taskId) && taskId == task.id) {
					return task;
				} else if (isNaN(taskId) && taskName == task.name) {
					return task;
				}
			}
			if (taskName != null) {
				for each(task in _tasks.source) {
					if (taskName == task.name) {
						return task;
					}
				}
			}
			trace("no task!! id=" + String(taskId) + ", name=" + taskName + ", task.length=" + _tasks.length);
			return null;
		}
	}
}
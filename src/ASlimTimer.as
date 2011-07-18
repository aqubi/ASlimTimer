import model.*;
import controller.*;
import view.*;
import air.update.events.UpdateEvent;

import mx.controls.Menu;
import mx.collections.ArrayCollection;
import mx.events.MenuEvent;
import flash.desktop.NotificationType;
import flash.events.Event;
import air.net.URLMonitor;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import mx.managers.CursorManager;

public static const ST_TOKEN:STToken = new STToken();
public static const ST_USER:STUser = new STUser();
public static const ST_SETTING:STSetting = new STSetting();

public static const TASKS_CONTROLLER:TasksController = new TasksController();
public static const NETWORK_CHECKER:NetworkChecker = new NetworkChecker();

[Bindable]
public static var TICK_CONTROLLER:TickController = new TickController();
[Bindable]
public static var ALARM_CONTROLLER:AlarmController;

public var accountController:AccountController;
private var networkController:NetworkController = new NetworkController();

public var windowController:WindowController = new WindowController();
public var menuController:MenuController = new MenuController();

[Bindable]
private function get selectedTask():STTask {
	return TICK_CONTROLLER.selectedItem;
}

private function set selectedTask(task:STTask):void {
	TICK_CONTROLLER.selectedItem = task;
}

[Embed(source='../icons/clock_play.png')] 
protected var imgPlay:Class 
[Embed(source='../icons/clock_stop.png')] 
protected var imgStop:Class 
[Embed(source='../icons/clock_pause.png')] 
protected var imgPause:Class 

[Embed(source='../icons/user_gray.png')] 
protected var imgUserDisabled:Class 
[Embed(source='../icons/user.png')] 
protected var imgUserEnabled:Class 

[Embed(source='../icons/transmit_blue.png')]
protected var imgNetworkConnect:Class;
[Embed(source='../icons/transmit_error.png')]
protected var imgNetworkDissconnect:Class;
[Embed(source='../icons/transmit_delete.png')]
protected var imgNetworkUnUsed:Class;

/* initializeのタイミング */
protected function onInitialize():void {
	accountController = new AccountController(this)
	windowController.init(this);
	TASKS_CONTROLLER.init(this);
	ALARM_CONTROLLER = new AlarmController();
	ALARM_CONTROLLER.init(this);
	NETWORK_CHECKER.addNetworkListener(function(isEnabled:Boolean):void {
		refreshNetwork();
	});
	accountController.loadAccount();//アカウント情報のLOAD
}

/* コンポーネントの生成完了時 */
protected function onApplicationComplete():void { 
	checkUpdate();
	menuController.init(this);//ネイティブメニューを作成      
	
	//TaskGridテーブルのKeyLitener設定
	grid.addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
		if (e.keyCode == Keyboard.SPACE) {
			dataGridRowClicked();
		}
	});	
	grid.addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
		if (e.keyCode == Keyboard.ENTER) {
			dataGridRowDoubleClicked();
		}
	});	
	windowController.onApplicationComplete();
}

//Updateのチェックを実行
private function checkUpdate():void {
	//    	var updater:ASlimTimerUpdater = new ASlimTimerUpdater();
	//    	updater.checkUpdate(checkUpdateDone);
	
	var appUpdater:UpdateManager = new UpdateManager(checkUpdateDone);
}

//Updateのチェックが終わったとき
protected function checkUpdateDone():void {
	updateAccount(); //Accountのチェック
}

//Windowの起動が完了したとき
protected function onWindowComplete():void {
	windowController.loadTaskGridTableCellWidth();
	grid.setFocus();
}

//Windowが終了しようとしたとき
private function onWindowClosing(event:Event):void {
	var mainWindow:WindowedApplication = this;
	windowController.saveXYPosition();
	event.preventDefault();
	
	var timer:Timer = new Timer(200, 0);
	timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
		if (!TASKS_CONTROLLER.serviceUpdater.isExecuting) {
			timer.stop();
			stage.nativeWindow.close(); 
			
		} else {
			mainWindow.alpha -= .05;
			TASKS_CONTROLLER.serviceUpdater.showProgressDialog();	
		}
	});
	timer.start();
}

// Networkの更新
public function refreshNetwork():void {
	var mode:int = ASlimTimer.ST_SETTING.networkMode;
	var isNetworkEnabled:Boolean = NETWORK_CHECKER.isNetworkEnabled;
	CursorManager.removeBusyCursor();
	
	if (mode == 1) { //Mode is Offline
		btnNetworkConnect.setStyle("icon", imgNetworkUnUsed);
		btnNetworkConnect.toolTip = rb('OfflineMode');
		
	} else if (isNetworkEnabled) {
		btnNetworkConnect.setStyle("icon", imgNetworkConnect);
		btnNetworkConnect.toolTip = rb('Online');
		TASKS_CONTROLLER.sync();
		
	} else {
		btnNetworkConnect.setStyle("icon", imgNetworkDissconnect);
		btnNetworkConnect.toolTip = rb('Offline');
	}
}

// *********************************************
// タスクの設定
// *********************************************

/* タスクリストを更新しなおす */
protected function refreshTaskList():void {
	TASKS_CONTROLLER.getTaskList();
}

protected function syncAndRefreshTask():void {
	var mode:int = ASlimTimer.ST_SETTING.networkMode;
	var isNetworkEnabled:Boolean = NETWORK_CHECKER.isNetworkEnabled;
	if (!isNetworkEnabled) {
		NETWORK_CHECKER.refresh();
	} else if (mode != 1) {
		TASKS_CONTROLLER.sync();
	}
	refreshTaskList();
}

/* タスクが選択されたとき */
private function onTaskSelected(selectedItem:STTask):void {
	if (selectedItem == null) {
		setSelectedTask(null);
		return;
	} else if (selectedTask == selectedItem && TICK_CONTROLLER.running) {
		stopTask();
	} else {
		if (selectedTask != null  && TICK_CONTROLLER.running){
			stopTask();
		}
		setSelectedTask(selectedItem);
		startTask(selectedItem);
	}
}

/* タスク名称をクリックしたとき */
protected function onTaskNameClicked():void {
	windowController.toggleWindowSize();
}

/* Expandボタンをクリックしたとき */
protected function onExpandClicked():void {
	windowController.toggleWindowSize();
}

/* タスク追加ダイアログを表示する */
public function showTaskCreateDialog():void {
	windowController.setNormalSize();
	var window:CreateTask = CreateTask(
	PopUpManager.createPopUp(this, CreateTask , true));
	window.returnFunction = function(task:STTask):void {
		if (!TICK_CONTROLLER.running) {
			TICK_CONTROLLER.clear();
			setSelectedTask(task);
		}
	}
	window.init();
	PopUpManager.centerPopUp(window);
}

/* show_completed のラジオボタン選択値が変わったとき */
private function onShowCompleted(completed:Button):void {
	TASKS_CONTROLLER.showCompleted = String(completed.data);
	completed.selected = true;
	if (completed != show_completed_only) {
		show_completed_only.selected = false;
	}
	if (completed != show_completed_yes) {
		show_completed_yes.selected = false;
	}
	if (completed != show_completed_no) {
		show_completed_no.selected = false;
	}
	doTaskFilter();
}

/* コメントの文字が変更されたとき */
private function commentChanged():void {
	if (TICK_CONTROLLER.timeEntry != null) {
		TICK_CONTROLLER.timeEntry.comments = comments.text;
	}
}

// *********************************************
// アカウントの設定
// *********************************************
/* アカウントダイアログを表示する */
protected function onAccountClicked():void {
	windowController.setNormalSize();
	accountController.showAccountDialog(this, updateAccount);
}

/* アカウント情報のチェックが完了したとき */
private function updateAccount():void {
	if (!ST_TOKEN.accessToken) {
		//アカウントが取得できていなかったとき
		btnAccount.setStyle("icon", imgUserDisabled);
		TASKS_CONTROLLER.tasks.removeAll();
		onAccountClicked();
		setCriticalNotification();
		
	} else {
		btnAccount.setStyle("icon", imgUserEnabled);
		if (TICK_CONTROLLER.running) {
			stopTask();
		}
		setSelectedTask(null);
		refreshTaskList();
		windowController.onTaskPanelVisible();
	}
}

// *********************************************
// ネットワークの設定
// *********************************************
protected function onNetworkClicked():void {
	windowController.setNormalSize();
	networkController.showDialog(this);
	
}

// *********************************************
// TaskとTimeEntryテーブルの設定
// *********************************************
/* DataGridクリック時の動作 */
protected function dataGridRowClicked():void {
	if (!TICK_CONTROLLER.running) {
		TICK_CONTROLLER.clear();
		setSelectedTask(STTask(grid.selectedItem));
	}
}

/* DataGridダブルクリック時の動作 */
protected function dataGridRowDoubleClicked():void {
	if (grid.selectedItem == null) {
		return;
	}
	setSelectedTask(grid.selectedItem as STTask);
	startTask(grid.selectedItem as STTask);
	
}

/* タスクの修正画面を表示する　*/
public function editTask():void {
	if (selectedTask != null) {
		windowController.setNormalSize();
		showTaskEditDialog(selectedTask);
	}	
}

/* Task編集ダイアログを表示する */
public function showTaskEditDialog(task:STTask):void {
	var window:EditTask = EditTask(
	PopUpManager.createPopUp(this, EditTask , true));
	window.init(task);
	PopUpManager.centerPopUp(window);
}

/* タスクを削除してもいいかどうかのチェック。選択中、実行中であれば処理をする */
public function checkDeleteTask(task:STTask):void {
	if (selectedTask == null) {
		return;
	} else if (selectedTask == task) {
		setSelectedTask(null);
	}
}

/* TimeEntryを削除してもいいかどうかのチェック。実行中であれば停止する */
public function checkDeleteTimeEntry(timeEntry:STTimeEntry):void {
	var t:STTimeEntry = TICK_CONTROLLER.timeEntry;
	if (t == null) {
		return;
	} else if (t == timeEntry && TICK_CONTROLLER.running) {
		//選択中で実行中だった場合にはSTOP
		stopTask();
	}
}

/* タスクを選択 */
public function setSelectedTask(task:STTask):void {
	if (selectedTask != null  && TICK_CONTROLLER.running){
		stopTask();
	}
	
	if (task == null) {
		_setSelectedTask(null);
		return;
	} else if (selectedTask == task && TICK_CONTROLLER.running) {
		//    		stopTask();
		//    	} else if (selectedTask == task && !tickController.running) {
		//    		onButtonStart();
		
	} else {
		_setSelectedTask(task);
		setStartButtonImage(false);
	}
}

/* 開始ボタンイメージを設定する */
private function setStartButtonImage(isExecuting:Boolean):void {
	if (isExecuting) {
		btnStart.setStyle("icon", imgStop);
		btnStart.toolTip = rb("stop");
		comments.visible = true;
		imgComment.visible = true;
	} else {
		btnStart.setStyle("icon", imgPlay);
		btnStart.toolTip = rb("start");
		comments.visible = false;
		imgComment.visible = false;
	}
}

private function _setSelectedTask(task:STTask):void {
	selectedTask = task;
	if (selectedTask == null) {
		btnStart.enabled = false;
		TICK_CONTROLLER.clear();
	} else {
		btnStart.enabled = true;
	}
}

// Taskを開始(時間測定開始)
public function startTask(selectedItem:STTask):void {
	if (selectedItem == null) {
		return;
	}
	if (TICK_CONTROLLER.running) {
		if (selectedTask == selectedItem) {
			return;
		} else {
			stopTask();
		}
	}
	
	_setSelectedTask(selectedItem);
	if (ST_SETTING.todaySumTime) {
		loadTodayTimeEntry(selectedItem);
		TICK_CONTROLLER.start(selectedItem);
	} else {
		TICK_CONTROLLER.todaySumTime = 0;
		TICK_CONTROLLER.start(selectedItem);
	}
	
	setStartButtonImage(true);
	if (ST_SETTING.smallWindowWhenTaskStart) {
		windowController.setSmallSize();
	}
}

/* Taskを停止 */
public function stopTask():void {
	if (TICK_CONTROLLER.running) {
		TICK_CONTROLLER.stop();
		setStartButtonImage(false);
	}
}

public function get isTaskRunning():Boolean {
	return TICK_CONTROLLER.running;
}

/* Startボタンをクリックする */
protected function onButtonStart():void {
	if (!TICK_CONTROLLER.running) {
		startTask(selectedTask);
	} else {
		stopTask();
	}
}

/* TimeViewが表示されたとき */
public function onGetTimeEntry():void {
	var mode:int = ASlimTimer.ST_SETTING.networkMode;
	var isNetworkEnabled:Boolean = NETWORK_CHECKER.isNetworkEnabled;
	if (!isNetworkEnabled) {
		NETWORK_CHECKER.refresh();
	} else if (mode != 1) {
		TASKS_CONTROLLER.sync();
	}
	
	var start:String = taskEntryList_date.text;
	var end:String = taskEntryList_date_to.text;
	if (start.length == 0 || end.length == 0) {
		return;
	}
	start = start + " 00:00:00";
	end = end + " 23:59:59";
	TASKS_CONTROLLER.getTimeEntryRange(start, end, function():void {
		taskGrid.setFocus();	
	});
	windowController.onShowTimeEntryGrid();
}

/* Reportが表示されたとき */
public function onShowReport():void {
	if (reportFromDate.selectedDate == null) {
		reportFromDate.selectedDate = new Date();
	}
	if (reportToDate.selectedDate == null) {
		reportToDate.selectedDate = new Date();
	}
}

/* 今日の日付を読込み */
private function loadTodayTimeEntry(selectedItem:STTask):void {
	var today:Date = new Date();
	loadWorkTimeEntry(today, today, function():void {
		var list:ArrayCollection = TASKS_CONTROLLER.workTimeEntries;
		var sum:int = 0;
		for each (var time:STTimeEntry in list) {
			if (selectedItem == null || time == null || time.task == null) {
				continue;
			}
			if (selectedItem.id == time.task.id) {
				sum = sum + time.durationInSeconds;
			}
		}
		TICK_CONTROLLER.todaySumTime = sum;
		
	});
}

/* 日付を読込み(workに格納用) */
private function loadWorkTimeEntry(startDate:Date, endDate:Date, callback:Function):void {
	var start:String = toDateString(startDate) + " 00:00:00";
	var end:String = toDateString(endDate) + " 23:59:59";
	TASKS_CONTROLLER.getTimeEntryRange(start, end, callback, true);
}

private function toDateString(date:Date):String {
	return date.fullYear + "/" + (date.month + 1) + "/" + date.date;
}


/* TimeGridがダブルクリックされたとき */
public function dataTimeGridRowDoubleClicked():void {
	showTimeEditDialog(taskGrid.selectedItem as STTimeEntry);
}

/* Time編集ダイアログを表示する */
public function showTimeEditDialog(time:STTimeEntry):void {
	var window:EditTimeEntry = EditTimeEntry(
	PopUpManager.createPopUp(this, EditTimeEntry , true));
	window.init(time);
	PopUpManager.centerPopUp(window);
}


protected function getToday():Date {
	var date:Date =  new Date();
	return date;
}



/* 今日のレポートを出力 */
public function showTodayReport():void {
	windowController.setNormalSize();
	var window:TodayReport = TodayReport(
	PopUpManager.createPopUp(this, TodayReport , true));
	
	window.init(this);
	PopUpManager.centerPopUp(window);
	window.body.setFocus();
}

private function onTaskLinkClick():void {
	var myURL:URLRequest = new URLRequest("http://slimtimer.com/tasks");
	navigateToURL(myURL,"_blank");
}

private function onTimeEntriesLinkClick():void {
	var myURL:URLRequest = new URLRequest("http://slimtimer.com/edit");
	navigateToURL(myURL,"_blank");		
}

// Alarm
// -----------------------------------------------------
protected function onShowAlarm():void {
	windowController.onShowAlarmGrid();
}

/* AlarmGridをダブルクリックしたとき */
public function onAlarmGridDoubleClicked():void {
	showAlarmEditDialog(alarmGrid.selectedItem as STAlarm);
}

/* Alarm編集ダイアログを表示する */
public function showAlarmEditDialog(alarm:STAlarm):void {
	var window:CreateAlarm = CreateAlarm(
	PopUpManager.createPopUp(this, CreateAlarm , true));
	window.init(alarm);
	PopUpManager.centerPopUp(window);
}

/* Alarm追加ダイアログを表示する */
public function showAlarmAddDialog():void {
	showAlarmEditDialog(null);
}

// Batch
// -----------------------------------------------------
/* 一括登録処理 */
public function onBatchEntry():void {
	if (batchDate.selectedDate == null) {
		Alert.show(rb("TheDateIsACompulsoryInput"), "Error");
		return;
	}
	
	var batch:BatchController = new BatchController();
	batch.parseString(txaList.text, batchDate.selectedDate, this,
	function():void {
		Alert.show(rb("TheProcessingOfBatchEntryWasCompleted"), "Success");
		txaList.text = "";
		batchDate.selectedDate = null;
	});
}

// Report
// -----------------------------------------------------
/* Report表示処理 */
public function onReport():void {
	if (reportFromDate.selectedDate == null || reportToDate.selectedDate == null) {
		Alert.show(rb("TheDateIsACompulsoryInput"), "Error");
		return;
	}
	loadWorkTimeEntry(reportFromDate.selectedDate, reportToDate.selectedDate, function():void {
		var list:ArrayCollection = TASKS_CONTROLLER.workTimeEntries;
		txaReport.text = parse(list);
		
	});
}

private function parse(times:ArrayCollection):String {
	var report:String = "";
	var completed:String = "";
	var created:String = "";
	var sumTime:Object = new Object();
	var taskIds:Object = new Object();
	var taskNames:Object = new Object();
	
	for (var i:Number = 0; i < times.length; i++) {
		var taskId:Number = times[i].task.id;
		var taskName:String = times[i].task.name;
		var seconds:Number = times[i].durationInSeconds;
		sumTime[taskId] = (sumTime[taskId] == null) ? seconds : sumTime[taskId] + seconds;
		taskIds[taskId] = taskId;
		taskNames[taskId] = taskName;
	}
	
	for each (var id:Number in taskIds) {
		var task:STTask = TASKS_CONTROLLER.getTask(id, taskNames[id]);
		if (task == null) { continue;}
		var sum:Number = sumTime[id];
		var sumStr:String = Number(sum / 3600).toFixed(2) + "h";
		report = report + task.name + " " + sumStr  + "\n";
	}
	return report;
}



// Filter
// -----------------------------------------------------
protected function doTaskFilter():void {
	TASKS_CONTROLLER.taskFilter(txtFilter.text);	
}

protected function doTimeFilter():void {
	TASKS_CONTROLLER.timeFilter(txtTimeFilter.text);	
}


// Notification
// -----------------------------------------------------
public function setCriticalNotification():void {
	setNotification(NotificationType.CRITICAL);
}

public function setInfomationNotification():void {
	setNotification(NotificationType.INFORMATIONAL);
}

private function setNotification(type:String):void {
	if (NativeWindow.supportsNotification) {
		nativeWindow.notifyUser(type);
		
	} else if (NativeApplication.supportsDockIcon) {
		var icon:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
		icon.bounce(type);
	}
}

//Localization
public function rb(str:String):String{
	if (str == null) return null;
	var ls:String = resourceManager.getString("aslimtimer", str);
	return (ls == null) ? str : ls;
}

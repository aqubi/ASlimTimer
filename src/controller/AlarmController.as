package controller {

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.errors.IOError;
	import flash.media.SoundChannel;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	import command.NewAlarmCommand;
	import command.GetAlarmListCommand;
	import command.UpdateAlarmCommand;
	import command.DeleteAlarmCommand;

	import model.STAlarm;
	import model.STTask;

	/*
	* Alarmを管理するController
	*/
	public class AlarmController {
		private var _alarms:ArrayCollection = new ArrayCollection();;
		private var _timer:Timer;

		private var window:ASlimTimer;
		private var snd:Sound;
		private var channel:SoundChannel;

		[Bindable]
		public function get alarms():ArrayCollection { return _alarms; }
		public function set alarms(alarms:ArrayCollection):void { _alarms = alarms; }

		[Bindable]
		public function get timer():Timer { return _timer; }
		public function set timer(timer:Timer):void { _timer = timer; }

		public function AlarmController() {
			_timer = new Timer(60000);
			_timer.addEventListener("timer", onTick);
		}

		public function init(win:ASlimTimer):void {
			window = win;
			start();
			load();
		}

		/* 監視開始 */
		private function start():void {
			var date:Date = new Date();
			var delay:Number = 60 - date.seconds;
			var dummyTimer:Timer = new Timer(delay * 1000, 1);
			dummyTimer.addEventListener("timer",
			function(event:TimerEvent):void {
				onTick(event);
				_timer.start();
			});
			dummyTimer.start();
			setClockTime(date);
		}

		/* 分単位のチェック */
		protected function onTick(event:TimerEvent):void {
			var date:Date = new Date();
			var hours:Number = date.hours;
			var	minutes:Number = date.minutes;
			setClockTime(date);
			for each (var alarm:STAlarm in alarms) {
				if (alarm.date != null) { 
					if (date.fullYear != alarm.date.fullYear
					|| date.month != alarm.date.month
					|| date.date != alarm.date.date) {
						continue;
					}
				}

				if (alarm.hours != hours
				|| alarm.minutes != minutes) {
					continue;
				}

				alart(alarm);
				break;
			}
		}

		/* Alartメッセージを表示する */
		private function alart(alarm:STAlarm):void {
			startSound(alarm.mp3);
			window.setCriticalNotification();
			Alert.show(alarm.name + "  begun?",
			'on Time!',
			Alert.YES | Alert.NO, null, 
			function (event:CloseEvent):void {
				stopSound();
				if (alarm.oneTimeOnly) {
					deleteAlarm(alarm);
				}
				if (event.detail == Alert.YES) {
					for each (var task2:STTask in ASlimTimer.TASKS_CONTROLLER.tasks) {
						if (task2.id == alarm.taskId) {
							window.stopTask();
							window.setSelectedTask(task2);
							window.startTask(task2);

							return;
						}
					}
					Alert.show("sorry... task is not found");
				}
			});
		}

		/* Load */
		public function load():void {
			var getCommand:GetAlarmListCommand = new GetAlarmListCommand();
			ASlimTimer.TASKS_CONTROLLER.serviceUpdater.addCommand(getCommand);

		}

		/* Alarmを追加 */
		public function insertAlarm(alarm:STAlarm):void {
			var newCommand:NewAlarmCommand = new NewAlarmCommand(alarm);
			ASlimTimer.TASKS_CONTROLLER.serviceUpdater.addCommand(newCommand);
		}

		/* Alarmを更新 */
		public function updateAlarm(alarm:STAlarm):void {
			var updateCommand:UpdateAlarmCommand = new UpdateAlarmCommand(alarm);
			ASlimTimer.TASKS_CONTROLLER.serviceUpdater.addCommand(updateCommand);
		}

		/* Alarmを削除 */
		public function deleteAlarm( alarm:STAlarm):void {
			var deleteCommand:DeleteAlarmCommand = new DeleteAlarmCommand(alarm);
			ASlimTimer.TASKS_CONTROLLER.serviceUpdater.addCommand(deleteCommand);    	
		}

		/* Soundを停止する */
		private function stopSound():void {
			if (channel != null) {
				channel.stop();
			}
		}

		/* Soundを開始する */
		public function startSound(mp3:String):void {
			snd = new flash.media.Sound();
			if (mp3 == null || mp3.length == 0) {
				return;
			}
			var req:URLRequest = new URLRequest(mp3);

			snd.load(req);
			channel = snd.play();
		}

	private function setClockTime(date:Date):void {
		window.lblClock.text = date.hours + ":" + String(date.minutes+100).substring(1);
	}


	}
}
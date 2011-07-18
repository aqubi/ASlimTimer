import flash.ui.Keyboard;
import mx.managers.PopUpManager;
import mx.controls.Alert;

import controller.WindowController;
import model.STAlarm;


private var channel:SoundChannel;
private var chkString:String;
private var isAdd:Boolean;

[Bindable]
protected var alarm:STAlarm;


public function init(a:STAlarm):void {
	addEventListener(KeyboardEvent.KEY_DOWN, 
		function(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.ESCAPE) {
                cancel();
            }
        });
    WindowController.changeDialogTheme(this);
    chkString = chkDateEnabled.label;

    if (a == null) {
    	title = "Add Alarm";
    	alarm = new STAlarm();
    	isAdd = true;
    } else {
    	title = "Edit Alarm";
    	alarm = a;
    	isAdd = false;
    }
    setDateVisible(chkDateEnabled.selected);

	cmbTask.setFocus();
}


/* 日付の使用可不可を切り替える */
protected function toggleDateEnabled():void {
	setDateVisible(!txtDate.visible);
}

/* 日付の表示を切り替える */
private function setDateVisible(isVisible:Boolean):void {
	txtDate.visible = isVisible;
	if (!isVisible) {
		chkDateEnabled.label = chkString;
	} else {
		chkDateEnabled.label = ''
	}
}

/* OKを押されたとき */
protected function ok():void {
	alarm.name = cmbTask.text;
	alarm.taskId = cmbTask.selectedItem.id;
	alarm.hours = Number(txtHours.text);
	alarm.minutes = Number(txtMinutes.text);
	alarm.oneTimeOnly = chkOneTimeOnly.selected;
	alarm.mp3 = alarm.getMp3(cmbSound.selectedIndex);
	
	if (chkDateEnabled.selected) {
		 alarm.date = new Date(Date.parse(txtDate.text));
	} else {
		alarm.date = null;
	}
	if (isAdd) {
		ASlimTimer.ALARM_CONTROLLER.insertAlarm(alarm);
	} else {
		ASlimTimer.ALARM_CONTROLLER.updateAlarm(alarm);
	}
	cancel();
}

/* Sound開始 */
protected function callSound():void {
	var sound:Sound = new Sound();
	if (channel != null) {
		channel.stop();
	}
	var mp3:String = alarm.getMp3(cmbSound.selectedIndex);
	if (mp3 == null || mp3.length == 0) {
		return;
	}
	var req:URLRequest = new URLRequest(mp3);
    sound.load(req);
	channel = sound.play();
}

/* cancelを押されたとき */
public function cancel():void {
	if (channel != null) {
		channel.stop();
	}
	PopUpManager.removePopUp(this);
}
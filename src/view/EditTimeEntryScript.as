
import mx.controls.Alert;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;
import mx.managers.FocusManager;
import mx.managers.PopUpManager;
import mx.controls.Alert;
import flash.ui.Keyboard;

import model.STTimeEntry;
import controller.WindowController;
import http.LoadResult;

[Bindable]
private var timeEntry:STTimeEntry;
private var timeValidator:RegExpValidator = new RegExpValidator();

private var startDate:Date;
private var endDate:Date;

public function init(time:STTimeEntry):void {
	timeEntry = time;
	timeValidator.expression = "^([0-1][0-9]|[2][0-3]):[0-5][0-9]:[0-5][0-9]$";
	timeValidator.noMatchError = "Please input [HH:MM:SS] format.";
	
	addEventListener(KeyboardEvent.KEY_DOWN, 
		function(e:KeyboardEvent):void {
            // ESCAPEキーだったらウィンドウを閉じる
            if (e.keyCode == Keyboard.ESCAPE) {
                onButtonCancel();
            }
        });
    WindowController.changeDialogTheme(this);
    WindowController.changeTextAlpha([txtStartTime, txtEndTime, txtTags, txtComments]);
    startDate = new Date(timeEntry.startTime);
    endDate = new Date(timeEntry.endTime);
    txtTags.setFocus();
}


private function onWindowComplete():void {
	focusManager.defaultButton = btnCancel;
	title = "edit of " + timeEntry.task.name;
}

private function timeValidate(text:Object):Boolean {
	timeValidator.source = text;
	timeValidator.property = "text";

	var validateRelust:ValidationResultEvent
                = timeValidator.validate();

    return (validateRelust.type == ValidationResultEvent.VALID);
}

private function setDurationInSeconds():void {
	txtDurationInSeconds.text = String(int((endDate.time - startDate.time) / 1000));	
}

private function checkStartTime():void {
	if (timeValidate(txtStartTime)) {
		setDateTime(txtStartTime.text, startDate);
		setDurationInSeconds();
	}
}

private function checkEndTime():void {
	if (timeValidate(txtEndTime)) {
		setDateTime(txtEndTime.text, endDate);
		setDurationInSeconds();
	}
}

private function checkStartDate():void {
	startDate.fullYear = dtStartDate.selectedDate.fullYear;
	startDate.month = dtStartDate.selectedDate.month;
	startDate.date = dtStartDate.selectedDate.date;
	setDurationInSeconds();
}

private function checkEndDate():void {
	endDate.fullYear = dtEndDate.selectedDate.fullYear;
	endDate.month = dtEndDate.selectedDate.month;
	endDate.date = dtEndDate.selectedDate.date;
	setDurationInSeconds();
}

private function setDateTime(timeValue:String, date:Date):void {
	var patternStr:String = "(\\d{2}):(\\d{2}):(\\d{2})";
    var pattern:RegExp = new RegExp(patternStr, "i") ; 
    var result:Array = pattern.exec(timeValue);

    if (result == null || result.length != 4) {
    	return;
    }
    date.hours = result[1];
    date.minutes = result[2];
    date.seconds = result[3];
}

private function onButtonUpdate():void {
	setDurationInSeconds();
	timeEntry.startTime = startDate;
	timeEntry.endTime = endDate;
	timeEntry.tags = txtTags.text;
	timeEntry.comments = txtComments.text;
	timeEntry.durationInSeconds = Number(txtDurationInSeconds.text);
	timeEntry.inProgress = chkInProgress.selected;

	btnUpdate.enabled = false;
	ASlimTimer.TASKS_CONTROLLER.executeUpdateTimeEntry(
	function(result:LoadResult):void {
		if (!result.isSuccess) {
			var window:ASlimTimer = parentDocument as ASlimTimer;
			Alert.show(window.rb("ItWasNotPossibleToUpdateIt") + "\n" + result.message, timeEntry.task.name);
		}
	}, timeEntry);
	onButtonCancel();
}

private function onButtonCancel():void {
	PopUpManager.removePopUp(this);
}

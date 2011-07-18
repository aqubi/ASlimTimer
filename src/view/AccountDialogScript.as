import flash.ui.Keyboard;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import mx.managers.PopUpManager;
import mx.events.ValidationResultEvent;
import mx.validators.NumberValidator;

import controller.WindowController;

private var okFunction:Function;
//protected static const SHARED_FILE:String = "ASlimTimer";
//protected var sharedObject:SharedObject = SharedObject.getLocal(SHARED_FILE);

private var nfValidator:NumberValidator = new NumberValidator();

public function init():void {
	addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
        if (e.keyCode == Keyboard.ESCAPE) {
            cancel();
        }
    });
    WindowController.changeDialogTheme(this);
    WindowController.changeTextAlpha([txtEmail, txtPassword]);
	txtEmail.setFocus();
}

/* */
protected function ok():void {
	ASlimTimer.ST_SETTING.startAtLogin = chkStartAtLogin.selected;
	ASlimTimer.ST_SETTING.alwaysInFront = chkAlwaysInFront.selected;
	ASlimTimer.ST_SETTING.idleCheck = chkIdleCheck.selected;
	ASlimTimer.ST_SETTING.smallWindowWhenTaskStart = chkSmallWindow.selected;
	ASlimTimer.ST_SETTING.windowFit = cmbWindowFit.selectedIndex;
	ASlimTimer.ST_SETTING.theme = cmbTheme.selectedIndex;
	ASlimTimer.ST_SETTING.todaySumTime = chkTodaySum.selected;
	ASlimTimer.ST_SETTING.nfAlert = int(txtNfAlert.text);
	ASlimTimer.ST_SETTING.nfWarning = Number(txtNfWarning.text);
	ASlimTimer.ST_SETTING.nfConfirm = Number(txtNfConfirm.text);
	
	
	PopUpManager.removePopUp(this);
	okFunction(txtEmail.text, txtPassword.text);
}

//Dialogをキャンセル
protected function cancel():void {
	PopUpManager.removePopUp(this);
}

public function setOKEventListener(func:Function):void {
	okFunction = func;
}

/* API KEYのSlimTimerページを表示する */
protected function onGetAPIKey():void {
 var myURL:URLRequest = new URLRequest("http://slimtimer.com/help/api");
 navigateToURL(myURL,"_blank");
}

/* Notificationの時間チェック */
private function nfValidate(text:Object):Boolean {
	nfValidator.source = text;
	nfValidator.property = "text";
	nfValidator.minValue = 0;
	nfValidator.domain="int";

	var validateRelust:ValidationResultEvent
                = nfValidator.validate();

    return (validateRelust.type == ValidationResultEvent.VALID);
}
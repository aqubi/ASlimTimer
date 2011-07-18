package controller {

import flash.desktop.NativeApplication;
import flash.net.SharedObject;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.managers.PopUpManagerChildList;

import command.AuthCommand;
import http.LoadResult;
import view.AccountDialog;

/*
 * 設定情報を制御するController
 */
public class AccountController {
	protected var okFunction:Function;
	private var window:ASlimTimer;
	private var sharedObject:SharedObject = SharedObject.getLocal("ASlimTimer");
	
	public function AccountController(mainWindow:ASlimTimer) {
		window = mainWindow;
	}
	
	/*　ダイアログを表示する */
	public function showAccountDialog(window:ASlimTimer, closure:Function):void {
        var account:AccountDialog = AccountDialog(
    		PopUpManager.createPopUp(window, AccountDialog , false, PopUpManagerChildList.POPUP));
	
		PopUpManager.centerPopUp(account);
    	okFunction = closure;
    	account.init();
    	account.setOKEventListener(onDialogOk);	
	}
	
	/* OKボタンが押されたとき */
	private function onDialogOk(email:String, password:String):void {
     	window.windowController.onApplicationComplete();
    	window.windowController.windowRefresh();
    	//window.refreshNetwork();
		if (ASlimTimer.ST_USER.email != email ||
			ASlimTimer.ST_USER.password != password ||
			ASlimTimer.ST_TOKEN.userId == 0) {
			
			ASlimTimer.ST_TOKEN.userId = 0;
	    	ASlimTimer.ST_TOKEN.accessToken = '';
	    	ASlimTimer.ST_USER.email = email;
	    	ASlimTimer.ST_USER.password = password;
	    	ASlimTimer.ST_USER.apiKey = "94ef49eb94891fa1ab4e756000a52f";
	    	
	    	if (!ASlimTimer.NETWORK_CHECKER.isNetworkEnabled) {
				Alert.show(window.rb("ItIsNotPossibleToAttestItBecauseItDoesn'tConnectItWithTheNetwork"));
	    	} else {
	    		ASlimTimer.TASKS_CONTROLLER.serviceUpdater.addCommand(
	    			new AuthCommand(completeAuth));
	    	}
				
		} else {
			//okFunction();
		}
	}
	
	/* 認証が完了したとき */
    private function completeAuth(result:LoadResult):void {
    	if (result.isSuccess) {
	       //txtUserId.text = event.result.user-id; //-を含んでいると取れない。。
	       ASlimTimer.ST_TOKEN.userId = result.xml["user-id"];
	       ASlimTimer.ST_TOKEN.accessToken = result.xml["access-token"];   
	       saveAccount();//情報を保存 
	       okFunction();

    	} else {
    		Alert.show("It failed in the attestation.\n" +
					"Please confirm Email,Password,APIKey." ,
					'Failed attestation',
					Alert.YES , null, 
				function (event:CloseEvent):void {
					showAccountDialog(window, okFunction);
				}
			);
    	}
    }
    
	
     /* 情報を保存する */
    public function saveAccount():void {
    	sharedObject.data.user_email = ASlimTimer.ST_USER.email;
    	sharedObject.data.api_key = ASlimTimer.ST_USER.apiKey;
    	sharedObject.data.user_id = ASlimTimer.ST_TOKEN.userId;
    	sharedObject.data.user_pass = ASlimTimer.ST_USER.password;
    	sharedObject.data.access_token = ASlimTimer.ST_TOKEN.accessToken;
    	sharedObject.flush();
    }
    
    /* アカウント情報を復元する */
    public function loadAccount():void {
	   	ASlimTimer.ST_USER.email = sharedObject.data.user_email;
    	ASlimTimer.ST_USER.apiKey = sharedObject.data.api_key;
    	ASlimTimer.ST_TOKEN.userId = sharedObject.data.user_id;
    	ASlimTimer.ST_USER.password = sharedObject.data.user_pass;
    	ASlimTimer.ST_TOKEN.accessToken = sharedObject.data.access_token;
    }

}
}
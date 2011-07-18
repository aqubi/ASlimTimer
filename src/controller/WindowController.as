package controller {

import view.AccountDialog;
import mx.managers.PopUpManager;
import mx.containers.TitleWindow;
import mx.core.Container;
import mx.controls.Alert;
import mx.controls.TextInput;
import mx.core.UIComponent;
import mx.controls.DateField;
import mx.controls.TextArea;
import mx.controls.ComboBox;
import mx.controls.Button;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.SharedObject;
import flash.display.NativeWindow;
import flash.display.Screen;
import flash.desktop.NativeApplication;
import flash.geom.Point;
import flash.ui.Keyboard;

import theme.*;

/*
 * Windowのサイズなどを制御するController
 */
public class WindowController {
	private var window:ASlimTimer;
	private var isNormalSize:Boolean = true;
	
	private var smallWidth:Number;
	private var smallHeight:Number;
	private var normalWidth:Number;
	private var normalHeight:Number;
	private var windowX:Number;
	private var windowY:Number;
	
	public var topX:Number = 1;
	public var topY:Number = 1;

	
	[Embed(source='../../icons/arrow_in.png')]
    protected var imgIn:Class;
    [Embed(source='../../icons/arrow_inout.png')]
    protected var imgInOut:Class;
    
    protected static const SHARED_FILE:String = "ASlimTimer";
    protected var sharedObject:SharedObject = SharedObject.getLocal(SHARED_FILE);
    
    /* TaskEntryのViewの初期処理が完了したかどうか */
    private var isTimeGridInitialize:Boolean = false;
    
    /* AlarmのViewの初期処理が完了したかどうか */
    private var isAlarmGridInitialize:Boolean = false;

	/* 初期化処理 */
	public function init(_window:ASlimTimer):void {
		if (NativeApplication.supportsMenu) {
			topY = 20;
		}
		window = _window;
    	smallWidth = sharedObject.data.smallWidth;
    	if (isNaN(smallWidth)) { smallWidth = 330;}
    	//window.width = smallWidth;

    	smallHeight = sharedObject.data.smallHeight;
    	if (isNaN(smallHeight)) { smallHeight = 80;}
    	//window.height = smallHeight;
    	
    	//trace("small:" + smallWidth + ":" + smallHeight);
	
    	normalWidth = sharedObject.data.normalWidth;
    	if (isNaN(normalWidth)) { normalWidth = 550;}
    	normalHeight = sharedObject.data.normalHeight;
    	if (isNaN(normalHeight)) { normalHeight = 380;}
    	
    	//trace("normal:" + normalWidth + ":" + normalHeight);

		if (!isNaN(sharedObject.data.windowX)){ 
			windowX = sharedObject.data.windowX;
			if (windowX < topX) {
				windowX = topX;
			} else if (windowX > Screen.mainScreen.bounds.width - smallWidth -1) {
				windowX = Screen.mainScreen.bounds.width - smallWidth -1;
			}
    		window.nativeWindow.x = windowX;
		}
		
		if (!isNaN(sharedObject.data.windowY)){ 	
			windowY = sharedObject.data.windowY;
			if (windowY < topY) {
				windowY = topY;
			} else if (windowY > Screen.mainScreen.bounds.height - smallHeight -20) {
				windowY = Screen.mainScreen.bounds.height - smallHeight -20;
			}
    		window.nativeWindow.y = windowY;
		}
		windowRefresh();
		setNormalSize();
	}
	
	public function onApplicationComplete():void {
		window.alwaysInFront = ASlimTimer.ST_SETTING.alwaysInFront;
		changeTheme();
		setIdle(ASlimTimer.ST_SETTING.idleCheck);
	}
	
	public function saveXYPosition():void {
		windowX = window.nativeWindow.x;
		windowY = window.nativeWindow.y;
		sharedObject.data.windowX = windowX;
		sharedObject.data.windowY = windowY;
		sharedObject.flush();
	}
	
	/* SharedObjectに保存 */
	public function saveSharedObject():void {
		if (!isNormalSize) {
			sharedObject.data.smallWidth = window.width;
			smallWidth = window.width;
			sharedObject.data.smallHeight = window.height;
			smallHeight = window.height;
			windowX = window.nativeWindow.x;
			windowY = window.nativeWindow.y;
			sharedObject.data.windowX = window.nativeWindow.x;
			sharedObject.data.windowY = window.nativeWindow.y;

		} else {
			sharedObject.data.normalWidth = window.width;
			normalWidth = window.width;
			sharedObject.data.normalHeight = window.height;
			normalHeight = window.height;

		}
		sharedObject.flush();
	}
	
	/* Task用GridのCellWidthを保存　*/
	public function saveTaskGridTableCellWidth():void {
		sharedObject.data.taskGridNameWidth = window.gridName.width;
		sharedObject.data.taskGridTagsWidth = window.gridTags.width;
		sharedObject.data.taskGridHoursWidth = window.gridHours.width;
		sharedObject.data.taskGridEditWidth = window.taskEdit.width;
		sharedObject.flush();
	}
	
	public function loadTaskGridTableCellWidth():void {
		if (!isNaN(sharedObject.data.taskGridNameWidth)) {
			window.gridName.width = sharedObject.data.taskGridNameWidth;
			window.gridTags.width = sharedObject.data.taskGridTagsWidth;
			window.gridHours.width = sharedObject.data.taskGridHoursWidth;
//			window.taskEdit.width = sharedObject.data.taskGridEditWidth;
		}
			
	}
	
	/* Time用GridのCellWidthを保存 */
	public function saveTimeGridTableCellWidth():void {
		sharedObject.data.timeGridNameWidth = window.timeTaskName.width;
		sharedObject.data.timeGridDateWidth = window.timeDate.width;
		sharedObject.data.timeGridStartTimeWidth = window.timeStartTime.width;
		sharedObject.data.timeGridEndTimeWidth = window.timeEndTime.width;
		sharedObject.data.timeGridHoursWidth = window.timeHours.width;	
		sharedObject.data.timeGridEditWidth = window.timeEdit.width;
		sharedObject.data.timeGridCommentsWidth = window.timeComments.width;
		sharedObject.flush();
	}
	
	public function loadTimeGridTableCellWidth():void {
		if (!isNaN(sharedObject.data.timeGridNameWidth)) {
			window.timeTaskName.width = sharedObject.data.timeGridNameWidth;
			window.timeStartTime.width = sharedObject.data.timeGridStartTimeWidth;
			window.timeEndTime.width = sharedObject.data.timeGridEndTimeWidth;
			window.timeHours.width = sharedObject.data.timeGridHoursWidth;
			window.timeComments.width = sharedObject.data.timeGridCommentsWidth;
			//window.timeEdit.width = sharedObject.data.timeGridEditWidth;
		}
	}
	
	/* WindowをSmallSizeにする */
	public function setSmallSize():void {
		isNormalSize = false;
		window.stackview.visible = false;
		window.pnlButtons.visible = false;
		window.width = smallWidth;
		window.height = smallHeight;
		window.btnExpand.setStyle('icon', imgInOut);
		xyRefresh();
		//window.validateNow();
	}
	
	/* WindowのXY位置を設定 */
	private function xyRefresh():void {
		var fit:int = ASlimTimer.ST_SETTING.windowFit;
		if (fit == 4){
			return;
		}
		if (!isNormalSize) {
			window.nativeWindow.x = windowX;
			window.nativeWindow.y = windowY;
			
		} else {
			if (fit == 0) {
				//左上用に整える
				window.nativeWindow.x = windowX;
				window.nativeWindow.y = windowY;
			} else if (fit == 1) {
				//右上に整える
				window.nativeWindow.x = windowX - (normalWidth - smallWidth);
				window.nativeWindow.y = windowY;
			} else if (fit == 2) {
				//右下用に整える
				window.nativeWindow.x = windowX - (normalWidth - smallWidth);
				window.nativeWindow.y = windowY - (normalHeight - smallHeight);
			} else if (fit == 3) {
				//左下用の整える
				window.nativeWindow.x = windowX;
				window.nativeWindow.y = windowY - (normalHeight - smallHeight);
			}
		}
	}
	
	/* WindowをNormalSizeにする */
	public function setNormalSize():void {
		if (window.stackview.visible) { 
			return;
		}

		isNormalSize = true;	
		xyRefresh();
		window.width = normalWidth;
		window.height = normalHeight;
		
		window.stackview.visible = true;
		window.pnlButtons.visible = true;
		window.btnExpand.setStyle('icon', imgIn);
	}
	
	/* Windowの大きさの変更 */
	public function toggleWindowSize():void {
		if (isNormalSize) {
			setSmallSize();
		} else {
			setNormalSize();
		}
	}
	
	
	/*　タスクパネルの表示する */
	public function onTaskPanelVisible():void {
		if (!window.stackview.visible || window.stackview.selectedIndex != 0) {
			window.stackview.selectedIndex = 0;
        	setNormalSize();
        	window.btnShowTaskPanel.selected = true;
        	window.btnShowTimeEntry.selected = false;
        	window.btnShowAlarm.selected = false;
        	window.btnBatch.selected = false;
        	window.btnReport.selected = false;

		}
		window.grid.setFocus();
	}
	

	/*　TimeEntry一覧の表示する */
	public function onTimeEntryListVisible():void {
		if (!window.stackview.visible || window.stackview.selectedIndex != 1) {
			window.stackview.selectedIndex = 1;
        	setNormalSize();
        	window.btnShowTaskPanel.selected = false;
        	window.btnShowTimeEntry.selected = true;
        	window.btnShowAlarm.selected = false;
        	window.btnBatch.selected = false;
        	window.btnReport.selected = false;
        	
		} 
		if (window.taskGrid != null) {
        	window.taskGrid.setFocus();
        }
	}
	
	/*　Alarm一覧の表示する */
	public function onAlarmListVisible():void {
		if (!window.stackview.visible || window.stackview.selectedIndex != 2) {
			window.stackview.selectedIndex = 2;
        	setNormalSize();
        	window.btnShowTaskPanel.selected = false;
        	window.btnShowTimeEntry.selected = false;
        	window.btnShowAlarm.selected = true;
        	window.btnBatch.selected = false;
        	window.btnReport.selected = false;
        	
		} 
		if (window.alarmGrid != null) {
        	window.alarmGrid.setFocus();
        }
	}
	
	/*　Batch登録の表示する */
	public function onBatchVisible():void {
		if (!window.stackview.visible || window.stackview.selectedIndex != 3) {
			window.stackview.selectedIndex = 3;
        	setNormalSize();
        	window.btnShowTaskPanel.selected = false;
        	window.btnShowTimeEntry.selected = false;
        	window.btnShowAlarm.selected = false;
        	window.btnBatch.selected = true;
        	window.btnReport.selected = false;
		} 
		if (window.batchDate != null) {
        	window.batchDate.setFocus();
        }
	}
	
	/* Reportを表示する */
	public function onReportVisible():void {
		if (!window.stackview.visible || window.stackview.selectedIndex != 4) {
			window.stackview.selectedIndex = 4;
        	setNormalSize();
        	window.btnShowTaskPanel.selected = false;
        	window.btnShowTimeEntry.selected = false;
        	window.btnShowAlarm.selected = false;
        	window.btnBatch.selected = false;
        	window.btnReport.selected = true;
		} 
		if (window.taskGrid != null) {
        	window.taskGrid.setFocus();
        }
	}

	/* fitの情報に合わせてWindowの位置を設定しなおす　*/
	public function windowRefresh():void {
		var fit:int = ASlimTimer.ST_SETTING.windowFit;
		if (fit == 0) {
			windowX = topX;
			windowY = topY;
		} else if (fit == 1) {
			windowX = Screen.mainScreen.bounds.width - smallWidth -1;
			windowY = topY;
		} else if (fit == 2) {
			windowX = Screen.mainScreen.bounds.width - smallWidth -1;
			windowY = Screen.mainScreen.bounds.height - smallHeight -3;
		} else if (fit == 3) {
			windowX = topX;
			windowY = Screen.mainScreen.bounds.height - smallHeight -3;
		} else if (fit == 4) {
			windowX = window.nativeWindow.x;
			windowY = window.nativeWindow.y;
		}
		xyRefresh();
	}

	/* WindowのTheme　*/	
	public function changeTheme():void {
		var themeObj:ThemeInterface = ASlimTimer.ST_SETTING.getThemeObject();
		var backColors:Array = [themeObj.backDarkColor, themeObj.backLightColor];
		window.setStyle("backgroundGradientColors", backColors);
		window.setStyle("titleBarColors", [themeObj.backLightColor, themeObj.backDarkColor]);
		window.setStyle("color", themeObj.textForeColor);
		window.titleBox.setStyle("color", themeObj.labelForeColor);
		window.comments.setStyle("color", themeObj.labelForeColor);
		window.setStyle("borderColor", themeObj.backDarkColor);
		window.btnShowTaskPanel.setStyle("fillColors", backColors);
		window.btnShowTimeEntry.setStyle("fillColors", backColors);
		window.btnShowAlarm.setStyle("fillColors", backColors);
		window.btnBatch.setStyle("fillColors", backColors);
		window.btnReport.setStyle("fillColors", backColors);
		window.show_completed_no.setStyle("fillColors", backColors);
		window.show_completed_yes.setStyle("fillColors", backColors);
		window.show_completed_only.setStyle("fillColors", backColors);
		
		//window.alpha = 0.95
	}
	
	/* DialogのTheme */
	public static function changeDialogTheme(dialog:TitleWindow):void {
		var themeObj:ThemeInterface = ASlimTimer.ST_SETTING.getThemeObject();
		dialog.setStyle("borderColor", themeObj.backDarkColor);
		dialog.setStyle("backgroundColor", themeObj.backMiddleColor);
		dialog.setStyle("color", themeObj.panelForeColor); 
		dialog.alpha = 0.95;
		dialog.setStyle("borderAlpha", 0.7);
		dialog.setStyle("alternatingItemColors", [themeObj.backLightColor, 0xFFFFFF]);
		changeTextForeColor(dialog, themeObj.textForeColor);
	}
	
	private static function changeTextForeColor(object:Container, color:uint):void {
		for(var i:Number = 0; i <object.getChildren().length; i++){
			var o:DisplayObject = object.getChildAt(i);
			if (o is TextInput || o is DateField || o is TextArea || o is ComboBox) {
				var text:UIComponent = o as UIComponent;
				text.setStyle("color", color);
			} 
			if (o is Container) {
				changeTextForeColor(o as Container, color);
			}
		}
	}
	// ***************************************************************
	
	public static function changeTextAlpha(control:Array):void {
//		var themeObj:ThemeInterface = ASlimTimer.ST_SETTING.getThemeObject();
//		for each (var text:DisplayObject in control) {
//			text.alpha = themeObj.titleTextAlpha;
//		}
	}
	
	/* Idle監視の設定 */
	private function setIdle(isChecked:Boolean):void {
		var app:NativeApplication = NativeApplication.nativeApplication;
		if (!isChecked) {
			app.removeEventListener(Event.USER_IDLE, userIdleHandler);
			app.removeEventListener(Event.USER_PRESENT, userPresentHandler);
		} else {
			//app.idleThreshold = 10; デフォルトは5分
			app.addEventListener(Event.USER_IDLE, userIdleHandler);
			app.addEventListener(Event.USER_PRESENT, userPresentHandler);
		}
	}
    
	/* 規定Idle時間を過ぎたとき */
	private function userIdleHandler(event:Event):void {
		if (window.isTaskRunning) {
			Alert.show("Stop Task.", "IdleCheck(5minute)");
			window.stopTask();
		}
	}
	
	private function userPresentHandler(event:Event):void {
		//trace("仕事中です");
	}
	

    
	/* TimeEntryGridが表示されたとき */
	public function onShowTimeEntryGrid():void {
		//TimeGridテーブルのKeyLisnter設定
 	    if (!isTimeGridInitialize) {
 	    	isTimeGridInitialize = true;
		    window.taskGrid.addEventListener(KeyboardEvent.KEY_DOWN, 
			    function(e:KeyboardEvent):void {
			        if (e.keyCode == Keyboard.ENTER) {
			            window.dataTimeGridRowDoubleClicked();
			        }
			    }
			);	
		    loadTimeGridTableCellWidth();
 	    } 
	}
	
	/* AlarmGridが表示されたとき */
	public function onShowAlarmGrid():void {
		//TimeGridテーブルのKeyLisnter設定
 	    if (!isAlarmGridInitialize) {
 	    	isAlarmGridInitialize = true;
		    window.alarmGrid.addEventListener(KeyboardEvent.KEY_DOWN, 
				function(e:KeyboardEvent):void {
			        if (e.keyCode == Keyboard.ENTER) {
			            window.onAlarmGridDoubleClicked();
			        }
			    }
			);	
		    loadTaskGridTableCellWidth();
 	    } 
	}
}
}
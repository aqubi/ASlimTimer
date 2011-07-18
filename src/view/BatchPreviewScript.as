import model.STBatchTimeEntry;
import model.STTask;
import controller.WindowController;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;
import http.LoadResult;
import flash.ui.Keyboard;

import theme.ThemeInterface;

[Bindable]
protected var timeEntries:ArrayCollection = new ArrayCollection();

private var taskEntries:Object;

[Bindable]
protected var selectedDate:Date;

private var _callback:Function;

private var _isError:Boolean;

public function init(entries:ArrayCollection, tasks:Object, date:Date, isError:Boolean, callback:Function):void {
	timeEntries = entries;
	taskEntries = tasks;
	selectedDate = date;
	_callback = callback;
	_isError = isError;
	
	addEventListener(KeyboardEvent.KEY_DOWN, 
	function(e:KeyboardEvent):void {
        // ESCAPEキーだったらウィンドウを閉じる
        if (e.keyCode == Keyboard.ESCAPE) {
            onCancel();
        }
    });
    WindowController.changeDialogTheme(this);
    var themeObj:ThemeInterface = ASlimTimer.ST_SETTING.getThemeObject();
	tblPreview.setStyle("color", 0x000000); 
    tblPreview.setFocus();
    tblPreview.selectedIndex = 0;
    onSelectionChanged();
    if (isError) {
    	btnUpdate.enabled = false;
    }
}

public function onCancel():void {
	PopUpManager.removePopUp(this);
}


public function onOk():void {
	ASlimTimer.TASKS_CONTROLLER.syncBatch(
		function():void {
			if (_callback != null) {
				_callback();
			}
		}, timeEntries, taskEntries);
    WindowController.changeDialogTheme(this); 
	PopUpManager.removePopUp(this);
}

public function onSelectionChanged():void {
	txtMessage.text = tblPreview.selectedItem.statusMessage;
}


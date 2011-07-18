package controller {
	
import flash.display.*;
import flash.desktop.NativeApplication;
import flash.desktop.DockIcon;
import flash.desktop.SystemTrayIcon;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.errors.IllegalOperationError;
import flash.net.SharedObject;
import flash.ui.Keyboard;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import mx.controls.Alert;
import mx.controls.FlexNativeMenu;

import view.HtmlWindow;
import export.DataExpoort;

/**
 * ネイティブメニューとシステムトレイを作成、制御を行なう 
 */
public class MenuController {
 	private var window:ASlimTimer;
	private var isMenuAdd:Boolean = false;
	
	public function init(aslimTimer:ASlimTimer):void {
		window = aslimTimer;
		//NativeMenuの設定
		var menu:NativeMenu;
		
		if (NativeApplication.supportsMenu) {
			menu = NativeApplication.nativeApplication.menu;

		} else if (NativeWindow.supportsMenu) {
			//menu = new NativeMenu();
			//aslimTimer.nativeWindow.menu = menu;
		}

		if (menu == null) {
			isMenuAdd = false;
			menu = new NativeMenu();
		} else {
			isMenuAdd = true;
		}

		menu.addItem(createViewMenu());
		menu.addItem(createActionMenu());
		menu.addItem(createCloseMenu());
		
		//TrayIconの設定
		if (NativeApplication.supportsSystemTrayIcon) {
			setSystemTrayIcon(menu);
		} else if (NativeApplication.supportsDockIcon) {
			setDockIcon(menu);
		}
	}
	
	/* Exitメニュー作成 */
	private function createCloseMenu():NativeMenuItem {
		var closeMenu:NativeMenuItem = new NativeMenuItem("Exit");
		closeMenu.addEventListener(Event.SELECT, onCloseMenuItem);
		return closeMenu;
	}
	
	private function onCloseMenuItem(event:Event):void {
		window.exit();
	}

	
	/* Viewメニュー */
	private function createViewMenu():NativeMenuItem {
		var item:NativeMenuItem = new NativeMenuItem("View");
		var menu:NativeMenu = new NativeMenu();
		item.submenu = menu;
		
		var menu1:NativeMenuItem = new NativeMenuItem("Small");
		var menu2:NativeMenuItem = new NativeMenuItem("TaskList");
		var menu3:NativeMenuItem = new NativeMenuItem("TimeEntryList");
		var menu4:NativeMenuItem = new NativeMenuItem("AlarmList");
		var menu5:NativeMenuItem = new NativeMenuItem("BatchEntryList");
		var menu6:NativeMenuItem = new NativeMenuItem("Report");
		
		//var menu4:NativeMenuItem = new NativeMenuItem("TodayReport");
		
		menu1.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.setSmallSize();
		});
		if (isMenuAdd) {menu1.keyEquivalent = "1";}
		
		menu2.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.onTaskPanelVisible();
		});
		if (isMenuAdd) {menu2.keyEquivalent = "2";}
		
		menu3.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.onTimeEntryListVisible();
		});
		if (isMenuAdd) {menu3.keyEquivalent = "3";}
		
		menu4.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.onAlarmListVisible();
		});
		if (isMenuAdd) {menu4.keyEquivalent = "4";}
		
		menu5.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.onBatchVisible();
		});
		if (isMenuAdd) {menu5.keyEquivalent = "5";}

		menu6.addEventListener(Event.SELECT, function(event:Event):void{
			window.windowController.onReportVisible();
		});
		if (isMenuAdd) {menu6.keyEquivalent = "6";}

		menu.addItem(menu1);
		menu.addItem(menu2);
		menu.addItem(menu3);
		menu.addItem(menu4);
		menu.addItem(menu5);
		menu.addItem(menu6);
		return item;
	}

	/* Actionメニュー */
	private function createActionMenu():NativeMenuItem {
		var item:NativeMenuItem = new NativeMenuItem("Action");
		var menu:NativeMenu = new NativeMenu();
		item.submenu = menu;
		
		var menu1:NativeMenuItem = new NativeMenuItem("Add Task");
		var menu2:NativeMenuItem = new NativeMenuItem("Task Start");
		var menu3:NativeMenuItem = new NativeMenuItem("Task Stop");
		var menu4:NativeMenuItem = new NativeMenuItem("Task Edit");
		var menu5:NativeMenuItem = new NativeMenuItem("Add Alart");
		
		var menu6:NativeMenuItem = new NativeMenuItem("Data Export");
		
		menu1.addEventListener(Event.SELECT, function(event:Event):void{
			window.showTaskCreateDialog();
		});
		if (isMenuAdd) {menu1.keyEquivalent = "A";}
		menu2.addEventListener(Event.SELECT, function(event:Event):void{
			window.startTask(ASlimTimer.TICK_CONTROLLER.selectedItem);
		});
		if (isMenuAdd) {menu2.keyEquivalent = "S";}
		menu3.addEventListener(Event.SELECT, function(event:Event):void{
			window.stopTask();
		});
		if (isMenuAdd) {menu3.keyEquivalent = "C";}
		menu4.addEventListener(Event.SELECT, function(event:Event):void{
			window.editTask();
		});
		if (isMenuAdd) {menu4.keyEquivalent = "E";}
		menu5.addEventListener(Event.SELECT, function(event:Event):void{
			window.showAlarmAddDialog();
		});
		if (isMenuAdd) {menu5.keyEquivalent = "R";}
		menu6.addEventListener(Event.SELECT, function(event:Event):void{
			new DataExpoort().export();
		});
		if (isMenuAdd) {menu5.keyEquivalent = "R";}
		
		menu.addItem(menu1);
		menu.addItem(menu2);
		menu.addItem(menu3);
		menu.addItem(menu4);
		menu.addItem(menu5);
		menu.addItem(menu6);
		return item;
	}
	// **************************************************
	// SystemTrayとDockの設定
	// **************************************************
    [Embed(source='../../icons_application/SlimTimer16.png')] 
    protected var icon16x16:Class 
     [Embed(source='../../icons_application/SlimTimer128.png')] 
    protected var icon128x128:Class 
    /* DocIconの設定 */
	private function setDockIcon(menu:NativeMenu):void {
		var tray:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
		tray.bitmaps = [new icon16x16(), new icon128x128()];
		tray.menu = menu;
	}
	
	/* SystemTrayの設定 */
	private function setSystemTrayIcon(menu:NativeMenu):void {
		var tray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
		tray.bitmaps = [new icon16x16(), new icon128x128()];
		tray.menu = menu;
	}


}
}
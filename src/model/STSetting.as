package model {
import flash.desktop.NativeApplication;
import flash.net.SharedObject;
import flash.errors.IllegalOperationError;
import mx.collections.ArrayCollection;
import theme.*;

/**
 * 設定関連の情報
 */	
public class STSetting {
    protected static const SHARED_FILE:String = "ASlimTimer";
    protected var sharedObject:SharedObject = SharedObject.getLocal(SHARED_FILE);
    
    [Bindable]
    public var colors:ArrayCollection;
    
    [Bindable]
    public var windowFits:Array = ["left-top", "right-top", "right-bottom", "left-bottom", "no fit"];

	[Bindable]
	public var networkModes:Array = ["online only", "offline only", "auto detection"];
	
	public function STSetting():void {
		colors = new ArrayCollection();
		colors.addItem(new BlackTheme());
		colors.addItem(new GreenTheme());
		colors.addItem(new BlueTheme());
		colors.addItem(new AquaTheme());
		colors.addItem(new IvoryTheme());
		colors.addItem(new RedTheme());
		colors.addItem(new PinkTheme());
		colors.addItem(new OrangeTheme());
		colors.addItem(new YellowTheme());
		colors.addItem(new PurpleTheme());
		colors.addItem(new RosyBrownTheme());
		colors.addItem(new LavenderTheme());
		colors.addItem(new MoegiTheme());
		colors.addItem(new RuriTheme());
		colors.addItem(new AzukiTheme());
		colors.addItem(new AnzuTheme());
		colors.addItem(new MouseTheme());
		colors.addItem(new KarasubaTheme());
	}
	
	[Bindable] 
	public function set alwaysInFront(alwaysInFront:Boolean):void { 
		sharedObject.data.alwaysInFront = alwaysInFront;
		sharedObject.flush();
	}
	
	public function get alwaysInFront():Boolean {
		if (isNaN(sharedObject.data.alwaysInFront)) {
			sharedObject.data.alwaysInFront = true;
			sharedObject.flush();
		}
		return sharedObject.data.alwaysInFront; 
	}


	[Bindable] 
	public function set idleCheck(idleCheck:Boolean):void {
		sharedObject.data.idlecheck = idleCheck;
		sharedObject.flush();
	}

	public function get idleCheck():Boolean {
		if (isNaN(sharedObject.data.idlecheck)) {
			sharedObject.data.idlecheck = false;
			sharedObject.flush();
		}
		return sharedObject.data.idlecheck; 
	}

	[Bindable] 
	public function set startAtLogin(startAtLogin:Boolean):void {
		try {
			NativeApplication.nativeApplication.startAtLogin = startAtLogin;
		} catch (e:IllegalOperationError) {
			//trace(e.message);
		}
	}

	public function get startAtLogin():Boolean {
		try {
			var isStart:Boolean = NativeApplication.nativeApplication.startAtLogin; 
			return isStart;
		} catch (e:IllegalOperationError) {
			//trace(e.message);
			return false;
		}
		return false;
	}
	
	[Bindable] 
	public function set windowFit(windowFit:int):void {
		sharedObject.data.fit = windowFit;
		sharedObject.flush();
	}
	public function get windowFit():int {
		if (isNaN(sharedObject.data.fit)) {
			sharedObject.data.fit = 0;
			sharedObject.flush();
		}
		return sharedObject.data.fit; 
	}
	
	[Bindable] 
	public function set networkMode(networkMode:int):void {
		sharedObject.data.networkMode = networkMode;
		sharedObject.flush();
	}
	public function get networkMode():int {
		if (isNaN(sharedObject.data.networkMode)) {
			sharedObject.data.networkMode = 2;
			sharedObject.flush();
		}
		return sharedObject.data.networkMode; 
	}
	
	[Bindable] 
	public function set theme(theme:int):void {
		sharedObject.data.theme = theme;
		sharedObject.flush();
	}
	public function get theme():int {
		if (isNaN(sharedObject.data.theme)) {
			sharedObject.data.theme = 0;
			sharedObject.flush();
		}
		return sharedObject.data.theme; 
	}
		
	public function getThemeObject():ThemeInterface {
		var themeId:int = ASlimTimer.ST_SETTING.theme;
		return colors.getItemAt(themeId) as ThemeInterface;
	}
	
	[Bindable]
	public function set smallWindowWhenTaskStart(isSetting:Boolean):void {
		sharedObject.data.smallWindowWhenTaskStart = isSetting;
		sharedObject.flush();
	}
	public function get smallWindowWhenTaskStart():Boolean {
		if (isNaN(sharedObject.data.smallWindowWhenTaskStart)) {
			sharedObject.data.smallWindowWhenTaskStart = true;
			sharedObject.flush();
		}
		return sharedObject.data.smallWindowWhenTaskStart; 
	}
	
	[Bindable]
	public function set todaySumTime(todaySumTime:Boolean):void { 
		sharedObject.data.todaySumTime = todaySumTime;
		sharedObject.flush();
	}
	
	public function get todaySumTime():Boolean {
		if (isNaN(sharedObject.data.todaySumTime)) {
			sharedObject.data.todaySumTime = false;
			sharedObject.flush();
		}
		return sharedObject.data.todaySumTime;
	}
	
	/* 次のローカルタスクのID */
	public function get nextLocalTaskId():int {
		if (isNaN(sharedObject.data.nextlocaltaskid)) {
			sharedObject.data.nextlocaltaskid = 0;
		}
		sharedObject.data.nextlocaltaskid = sharedObject.data.nextlocaltaskid - 1;
		sharedObject.flush();
		return sharedObject.data.nextlocaltaskid; 
	}
	
	/* 次のローカルTimeEntryのID */
	public function get nextLocalTimeEntryId():int {
		if (isNaN(sharedObject.data.nextlocaltimeid)) {
			sharedObject.data.nextlocaltimeid = 0;
		}
		sharedObject.data.nextlocaltimeid = sharedObject.data.nextlocaltimeid - 1;
		sharedObject.flush();
		return sharedObject.data.nextlocaltimeid; 
	}
	
	/* 次のAlarmのID */
	public function get nextLocalAlarmId():int {
		if (isNaN(sharedObject.data.nextalarmid)) {
			sharedObject.data.nextalarmid = 0;
		}
		sharedObject.data.nextalarmid = sharedObject.data.nextalarmid + 1;
		sharedObject.flush();
		return sharedObject.data.nextalarmid; 
	}
	
	[Bindable]
	public function set nfAlert(nfAlert:int):void { 
		sharedObject.data.nfAlert = nfAlert;
		sharedObject.flush();
	}
	public function get nfAlert():int { 
		return sharedObject.data.nfAlert;
	}
	
	[Bindable]
	public function set nfWarning(nfWarning:int):void { 
		sharedObject.data.nfWarning = nfWarning;
		sharedObject.flush();
	}
	public function get nfWarning():int { 
		return sharedObject.data.nfWarning;
	}
	
	[Bindable]
	public function set nfConfirm(nfConfirm:int):void { 
		sharedObject.data.nfConfirm = nfConfirm;
		sharedObject.flush();
	}
	public function get nfConfirm():int { 
		return sharedObject.data.nfConfirm;
	}
		
	
}
}

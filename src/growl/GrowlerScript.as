
private var timeToLive:uint;

private var _message:String;
[Bindable (readonly)]
public function get message():String { return _message; }

private var _messageTitle:String;
[Bindable (readonly)]
public function get messageTitle():String { return _messageTitle; }

private var _titleImage:Class;
[Bindable (readonly)]
public function get titleImage():Class { return _titleImage; }

private var displayManager:DisplayManager;
private var priority:int;


public const priorityManager:PriorityManager = new PriorityManager();

/* 初期化 */
public function init(title:String, message:String, priority:int, image:Class, displayManager:DisplayManager):Growler {
	_messageTitle = title;
	_message = message;
	_titleImage = image;
	this.displayManager = displayManager;
	this.priority = priority;
	if (priorityManager.isAutoHidden(priority)) {
		displayManager.addEventListener(DisplayManager.LIFE_TICK, lifeTick, false, 0, true);
	}
	timeToLive = priorityManager.getTimeToLive(priority);
	return this;	
}

/** stageに追加されたタイミングで、stageの属性と色を変更 */
private function onAddToStage():void {
	stage.align = StageAlign.TOP_LEFT;
	stage.scaleMode = StageScaleMode.NO_SCALE;
	box.setStyle("backgroundColor", priorityManager.getBackgroundColor(priority));
	box.setStyle("color", priorityManager.getColor(priority));

}

/** 作成完了したタイミングでウィンドの高さを調節 */
private function onWindowComplete():void {
	nativeWindow.height = box.height;
	nativeWindow.width = box.width;
}

/** 生存チェック */
public function lifeTick(event:Event):void {
	timeToLive--;
	if (timeToLive < 1) {
		closeGrowler();
	}
}

public function onShow():void {
	showGrowler();
}

/** Growler画面を透明から段々と表示させる */
private function showGrowler():void {
	var timer:Timer = new Timer(20, 0);
	timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
		alpha += .1;
		if (alpha >= 1) {
			timer.stop();
		}
	});
	timer.start();	
}
/** Growler画面を段々と透明にして終了する */
private function closeGrowler():void {
	var timer:Timer = new Timer(50, 0);
	timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
		alpha -= .1;
		if (alpha < 0) {
			timer.stop();
			close();
		}
	});
	timer.start();	
}

/** リスナーを削除して画面終了 */
public override function close():void {
	displayManager.removeEventListener(DisplayManager.LIFE_TICK, lifeTick, false);
	super.close();
}
package controller {
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	import air.net.URLMonitor;
	import flash.desktop.NativeApplication;

	/*
	* Networkの監視用
	*/
	public class NetworkChecker {
		public static const ONLINE:int = 0;
		public static const OFFLINE:int = 1;

		private var monitor:URLMonitor;
		[Bindable]
		public var _isNetworkEnabled:Boolean = false;
		public function set isNetworkEnabled(isNetworkEnabled:Boolean):void { _isNetworkEnabled = isNetworkEnabled;}
		public function get isNetworkEnabled():Boolean { return _isNetworkEnabled;}

		//ネットワークの変更イベントを発火する対象
		protected var networkListeners:Array = new Array();

		public function NetworkChecker() {
			networkMonitorStart();
		}

		/* 設定、ネットワークの状態よりどこから情報を取得するかどうかを取得 */
		public function getNetworkMode():int {
			var mode:int = ASlimTimer.ST_SETTING.networkMode;
			if (mode == 1) { //Mode is Offline
				return OFFLINE;
			}
			if (isNetworkEnabled) {
				return ONLINE;
			} else if (mode == 2) { //Mode is Auto
				return OFFLINE;
			} else {
				return -1;
			}	 
		}

		/* Network監視リスナーの登録 */
		public function addNetworkListener(listener:Function):void {
			networkListeners.push(listener);
			listener(isNetworkEnabled);
		}

		/* Network監視開始 */
		private function networkMonitorStart():void {
			var request:URLRequest = new URLRequest("http://slimtimer.com/");
			monitor = new URLMonitor(request);
			//monitor.pollInterval = 4000;
			monitor.addEventListener(StatusEvent.STATUS, onNetworkStatus, false, 0, true);	
			monitor.start();

			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, onIdle);
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, onPresence);

		}

		/* Networkの変更があったとき */
		private function onNetworkStatus(event:StatusEvent):void {
			var enabled:Boolean = event.target.available;
			if (isNetworkEnabled != enabled) {
				//trace("network changed. " + enabled);
				isNetworkEnabled = enabled;
				for each(var networkLister:Function in networkListeners) {
					networkLister(isNetworkEnabled);
				}
			}
		}
		
		public function refresh():void {
			monitor.stop();
			monitor.start();
		}

		/** コンピュータがアイドル状態 */
		private function onIdle(event:Event):void{
			trace("Idling.");
		}

		/** アイドル状態からの復帰 */
		private function onPresence(event:Event):void{
			trace("Resuming.");
			
		}
	}
}

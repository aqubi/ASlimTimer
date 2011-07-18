package command {
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import flash.display.DisplayObject;

	import model.STTask;
	import mx.collections.ArrayCollection;
	import controller.SQLiteController;
	import controller.SlimTimerController;
	import controller.TasksController;
	import controller.NetworkChecker;
	import view.ProgressWindow;
	import http.LoadResult;
	import command.ICommand;

	/*
	* 最初にDBへ更新した後、SlimTimerServiceへ更新する。
	* SlimTimerへの更新が正常に完了したらDBの後処理も行ないます。
	*
	* SlimTimerへの処理は同期処理を行ないます。
	*/
	public class ServiceUpdater {
		public static const ONLINE:int = 0;
		public static const OFFLINE:int = 1;

		/* 実行するCommandのリスト */
		private static var commandList:ArrayCollection = new ArrayCollection();

		//ローカルDBを使ってアクセスするクラス
		private var sqLiteController:SQLiteController = new SQLiteController();

		//SlimTimer(ネットワーク)を使ってアクセスするクラス
		private var slimTimerController:SlimTimerController = new SlimTimerController();

		private var popup:ProgressWindow;

		private var popupTitle:String;

		/* 実行中かどうか */
		private var _isExecuting:Boolean = false;
		[Bindable]
		public function get isExecuting():Boolean { return _isExecuting; }
		public function set isExecuting(isExecuting:Boolean):void { _isExecuting = isExecuting; }

		/* 終了時に完了メッセージを表示するかどうか */
		private var _endMessage:String;
		[Bindable]
		public function set endMessage(endMessage:String):void { _endMessage = endMessage; }
		public function get endMessage():String { return _endMessage; }

		/* 終了時のCallback */
		private var _callback:Function;
		[Bindable]
		public function set callback(callback:Function):void { _callback = callback; }
		public function get callback():Function { return _callback; }

		/* 処理の数 */
		private var length:int;
		/* 現在の処理Count */
		private var count:int;

		/* DB接続完了時 */
		private function onDBConnectCompleted(result:LoadResult):void {
			trace("DB接続完了");
		}

		/* 同期処理用のコマンド追加 DB追加の処理は行なわない */
		public function addSyncCommand(item:ICommand):void {
			addServiceCommand(item, true);
		}

		/* コマンド処理の追加 */
		public function addCommand(item:ICommand):void {
			//DBへ保存
			item.updateDB(sqLiteController, function():void{});
			addServiceCommand(item);
		}

		private function addServiceCommand(item:ICommand, isPopup:Boolean=false):void {
			var networkMode:int = ASlimTimer.NETWORK_CHECKER.getNetworkMode();
			if (networkMode == NetworkChecker.ONLINE) {
				commandList.addItem(item);
				length++;
				if (!_isExecuting) {
					_isExecuting = true;
					popupTitle = "ASlimTimer Synchronize";
					if (isPopup) {
						popup = ProgressWindow(PopUpManager.createPopUp(DisplayObject(Application.application), ProgressWindow, true));
						popup.title = popupTitle;
						popup.progress.mode = 'manual';
						PopUpManager.centerPopUp(popup);
					}
					run();
				}
			}
		}

		/* ProgressDialogを表示する */
		public function showProgressDialog():void {
			if (_isExecuting && popup == null) {
				popup = ProgressWindow(PopUpManager.createPopUp(DisplayObject(Application.application), ProgressWindow, true));
				popup.title = popupTitle;
				popup.progress.mode = 'manual';
				PopUpManager.centerPopUp(popup);
				popup.progress.setProgress(count, length);
			}
		}

		/* 処理を開始する */
		private function run():void {
			count = 0;
			runCommand();
		}

		import flash.utils.getQualifiedClassName;
		/* Commandを実行 */
		private function runCommand():void {
			var executingCommand:ICommand = commandList.getItemAt(0) as ICommand;
			if (executingCommand == null) {
				endService();
				return;
			}

			if (popup != null) {
				popupTitle = getQualifiedClassName(executingCommand);
				popup.title = popupTitle;
				popup.progress.setProgress(count, length);
			}

			try {
				executingCommand.updateService(sqLiteController, slimTimerController, onExecuteEnd);
			} catch (error:Error) {
				var result:LoadResult = new LoadResult();
				result.httpStatus = -1;
				result.message = error.message;
				result.targetCommand = executingCommand;
				trace(error);
				onExecuteEnd(result);
			}
			count++;
		}

		private function endService():void {
			if (popup != null) { 
				PopUpManager.removePopUp(popup); 
				popup = null;
			}
			_isExecuting = false;
			length = 0;
			count = 0;
			if (endMessage != null) {
				Alert.show(endMessage);
				endMessage = null;	
			}
			if (callback != null) {
				callback();
				callback = null;
			}
		}

		/* 処理が完了したとき */
		private function onExecuteEnd(result:LoadResult):void {
			var index:int = commandList.getItemIndex(result.targetCommand);
			if (index >= 0) {
				commandList.removeItemAt(index);
			}

			if (!result.isSuccess) {
				var message:String = 
				result.targetCommand
				+ "HttpStatus:" + result.httpStatus + "\n"
				+ "Message:" + result.message + "\n"
				+ "XML:" + result.xml;

				trace(message);
				//Alert.show(message, "ERROR");

			} else {
				if (commandList.length > 0) {
					runCommand();
					return;
				} 
			}
			endService();
		}
	}	
}

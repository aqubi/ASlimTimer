package controller {
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;

	import flash.filesystem.File;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	
	import mx.core.UIComponent;
	
	public class UpdateManager extends UIComponent {
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI;

		public function get applicationUpdater():ApplicationUpdaterUI{
			return appUpdater;				
		}	
		 
		public function UpdateManager(callBack:Function) {
			super();
			forBug();
			appUpdater.configurationFile = new File("app:/update.xml");
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);

	    	appUpdater.addEventListener(UpdateEvent.INITIALIZED, 
	    		function (event:UpdateEvent):void {
	    			checkForUpdate();
	    			
	    			callBack();
	    		}
	    	);
			appUpdater.initialize();
		}
		
		private function onError(ev:ErrorEvent):void {
			
		}

		public function checkForUpdate():void {
			appUpdater.checkNow();
		}
		
		//http://www.adobe.com/cfusion/webforums/forum/messageview.cfm?forumid=72&catid=670&threadid=1373568&enterthread=y
		private function forBug():void {
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, 
			     function(e:Event):void {
			         var opened:Array = NativeApplication.nativeApplication.openedWindows;
			         for (var i:int = 0; i < opened.length; i ++) {
			               opened[i].close();
			         }
			});			
			
		}
		
	}
}
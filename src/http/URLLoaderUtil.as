package http {

	import flash.net.*;
	import flash.events.*;


	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.managers.CursorManager;

	/*
	* URLLoaderを使ったAccess
	*/
	public class URLLoaderUtil {
		private var result:LoadResult;
		private var callBackFunction:Function;


		public function load(loader:URLLoader, request:URLRequest, callBack:Function):void {
			onLoadStart(request.method);
			callBackFunction = callBack;
			result = new LoadResult();

			loader.addEventListener(Event.COMPLETE, onCompleted);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0 , true);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0 , true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0 , true);
			//loader.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponse, false, 0, true);
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}	
		}

		// ---------------------------------------

		private function onLoadStart(httpMethod:String):void {
			if (httpMethod != URLRequestMethod.PUT) {
				CursorManager.setBusyCursor();
			}
		}

		private function onAccessEnd(urlLoader:URLLoader):void {
			CursorManager.removeBusyCursor();
			urlLoader.removeEventListener(Event.COMPLETE, onCompleted);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			//urlLoader.removeEventListener(ProgressEvent.PROGRESS, progress);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponse);
			urlLoader.close();
			callBackFunction(result);
			callBackFunction = null;
			result = null;
			urlLoader = null;
		}

		private function onCompleted(event:Event):void {
			try {
				var xml:XML  = new XML(event.target.data);
				result.xml = xml;
			} catch (error:Error) {
				trace(error);
				trace(event.target.data);
			}
			onAccessEnd(event.target as URLLoader);
		}

		private function httpStatusHandler(event:HTTPStatusEvent):void {
			result.httpStatus = event.status;
		}

		private function httpResponse(event:HTTPStatusEvent):void {
			if (event.status != 200) {
				trace("responseURL: " + event.responseURL);
				trace(event);
			}
			//trace("responseURL: " + event.responseURL);
			//		for each(var h:Object in event.responseHeaders) {
			//			trace(h.name + ":" + h.value);
			//		}
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void {
			result.message = "HttpStatus=" + result.httpStatus + "\n" + String(event);
			onAccessEnd(event.target as URLLoader);
		}

		private function ioErrorHandler(event:IOErrorEvent):void {
			result.message = "HttpStatus=" + result.httpStatus + "\n" + String(event);
			onAccessEnd(event.target as URLLoader);
		}

		//    private function progress(event:ProgressEvent):void {
		//    	trace(event);
		//    }

	}
}
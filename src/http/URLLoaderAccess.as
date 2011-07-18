package http {

	import flash.net.*;
	import flash.events.*;


	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.managers.CursorManager;

	/*
	* URLLoaderを使ったAccess
	*/
	public class URLLoaderAccess implements AccessInterface {
		public static const SLIMTIMER_PATH:String = "http://slimtimer.com/";
		protected var errorListeners:Array;

		// 初期処理
		public function init():void {
			errorListeners = new Array();
		}

		//URLLoaderを取得
		private function getUrlLoader():URLLoader {
			var loader:URLLoader = new URLLoader();
			return loader;
		}

		// URLRequestオブジェクトを取得
		private function getURLRequest(path:String, httpMethod:String):URLRequest {
			var request:URLRequest = new URLRequest(path);
			request.cacheResponse = false;
			request.manageCookies = false;
			request.followRedirects = false;
			request.authenticate = false;
			request.useCache = false;
			request.method = httpMethod;
			var header:URLRequestHeader = new URLRequestHeader("Accept", "application/xml");	
			request.requestHeaders.push(header);
			return request;
		}

		//リクエスト実行
		public function callRequest(path:String,  requests:Object, completeFunction:Function, httpMethod:String):void {
			var urlPath:String;
			var request:URLRequest;

			urlPath = SLIMTIMER_PATH + path;
			request = getURLRequest(urlPath, httpMethod);
			request.data = getRequestString(requests);
			var loader:URLLoader = getUrlLoader();
			new URLLoaderUtil().load(loader, request, completeFunction);
		}

		//リクエスト実行
		public function postXml(path:String,  requests:Object,
		requestBody:XML, completeFunction:Function, httpMethod:String):void {

			var urlPath:String = getUrlPath(path, requests);
			var request:URLRequest = getURLRequest(urlPath, httpMethod);
			// URLRequest.dataをそのまま使えそうだ?
			request.contentType = 'application/xml';
			request.requestHeaders.push(new URLRequestHeader("Accept", "application/xml"));
			request.data = requestBody;

			var loader:URLLoader = getUrlLoader();
			new URLLoaderUtil().load(loader, request, completeFunction);
		}

		/* Pathの生成 */
		private function getUrlPath(path:String, requests:Object):String {
			var urlPath:String = SLIMTIMER_PATH + path;
			return urlPath + getRequestString(requests, '?');
		}

		private function getRequestString(requests:Object, first:String=''):String {
			var path:String = '';
			var i:int = 0;
			for (var req:String in requests) {
				if (i == 0) {
					path = path + first;
				} else {
					path = path + "&";
				}
				path = path + req + "=" + requests[req];
				i++;
			}
			return path;
		}
	}
}

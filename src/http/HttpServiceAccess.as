package http {

	import mx.rpc.events.*;
	import flash.events.*;
	import flash.net.*;
    import mx.rpc.http.mxml.HTTPService;

/*
 * HttpServiceを使ったAccess
 * 始めはURLLoaderでなくて、こっちを使おうとしてたけど、今は使ってないw
 */
public class HttpServiceAccess implements AccessInterface {
    public static const SLIMTIMER_PATH:String = "http://slimtimer.com/";
	//protected var service:HTTPService;
	protected var errorListeners:Array;

    // 初期処理
    public function init():void {
//    	service = new HTTPService();
//    	service.showBusyCursor = true;
    	errorListeners = new Array();
//        configureListeners(service);
    }

	    
    //リクエスト実行
    public function callRequest(path:String,  request:Object,
    	completeFunction:Function, httpMethod:String):void {
    	var urlPath:String = SLIMTIMER_PATH + path;
    	trace("callRequest :" + path);
    	var service:HTTPService = new HTTPService();
    	service.showBusyCursor = true;
    	//configureListeners(service);
    	
    	service.method = httpMethod;
        service.url = urlPath;
        service.useProxy = false;
        service.headers = {"Accept": "application/xml"};
        service.resultFormat = "e4x";
        service.request = request;

		service.addEventListener(ResultEvent.RESULT,
        function myFunction(event:ResultEvent):void {
        		trace("end of callRequest -" + path );
        		completeFunction(event.result);
        		service.removeEventListener(ResultEvent.RESULT, myFunction);
        	}, false, 0 , true);
        service.send();
    }

    //リクエスト実行
    public function postXml(path:String,  request:Object,
    	requestBody:XML, completeFunction:Function, httpMethod:String):void {
    	var urlPath:String = SLIMTIMER_PATH + path;

    	var service:HTTPService = new HTTPService();
    	service.showBusyCursor = true;
     	//configureListeners(service);
    	
    	service.method = httpMethod;
        service.url = urlPath;
        trace(urlPath);
        service.useProxy = false;
        service.headers = null;
        service.headers = {"Accept": "application/xml", "Content-type": "application/xml"};
        service.contentType = "application/xml";
        //trace(service.headers);
        service.resultFormat = "e4x";
        trace(requestBody);
        service.request = requestBody;
        

    	service.addEventListener(ResultEvent.RESULT,
        function myFunction(event:ResultEvent):void {
        	trace("end of postXml aa");
        	    trace(event);
        	    trace("result=" + event.result.id);
        		completeFunction(event.result as XML);
        		service.removeEventListener(ResultEvent.RESULT, myFunction);
        	});


        //service.addEventListener(ResultEvent.RESULT, resultHandler);
        service.addEventListener(FaultEvent.FAULT,httpFaultHandler);
        service.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        service.send();
    }
    
    public function addErrorEventListener(closure:Function):void {
    	errorListeners.push(closure);
    }
    
    public function removeErrorEventListener(closure:Function):void {
    	errorListeners.remove(closure);
    }
    
   private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(FaultEvent.FAULT,httpFaultHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        dispatcher.addEventListener(ResultEvent.RESULT, resultHandler);
   }
    
    // -------------------------------------------------------
    protected function resultHandler(event:ResultEvent):void {
    	trace('ResultEvent\n' + event);
    	trace('ResultEvent.result\n' + event.result);
    	onAccessEnd();
    }
    
    protected function httpFaultHandler(event:FaultEvent):void {
        trace('fault\n' + event);
        for each (var closure:Function in errorListeners) {
    		closure();
    	}
        onAccessEnd();
    }
    
    protected function ioErrorHandler(event:IOErrorEvent):void {
    	trace('IOError\n' + event);
    	for each (var closure:Function in errorListeners) {
    		closure();
    	}
        onAccessEnd();
	}
	
	protected function onAccessEnd():void {
		errorListeners = [];
	}
	

}
}
package http {
public interface AccessInterface {

	function init():void;
	
	//リクエスト実行
    function callRequest(path:String,  requests:Object,
    	completeFunction:Function, httpMethod:String):void;
    	
	//リクエスト実行(送信データアリ)
    function postXml(path:String,  requests:Object,
    	requestBody:XML, completeFunction:Function, httpMethod:String):void;
    	
    // Error発生時のイベントを追加する。Access終了時に自動的にremoveします
    //function addErrorEventListener(closure:Function):void;


}
}
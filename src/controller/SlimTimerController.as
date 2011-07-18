package controller {

import http.*;
import mx.collections.ArrayCollection;
import model.STUser;
import model.STToken;
import model.STTask;
import model.STTimeEntry;
import db.TasksStore;
import db.TimesStore;
import flash.net.URLRequestMethod;
import flash.utils.escapeMultiByte;
	
public class SlimTimerController {

	private var service:AccessInterface;

	public function SlimTimerController() {
    	service = new URLLoaderAccess();
    	service.init();
	}
	
	/*
	 *　アカウントの認証
	 */
	public function auth(user:STUser, callbackFunc:Function):void {
    	//var variables:String = "user[email]=" +  escapeMultiByte(user.email) +"&" + "user[password]=" +  escapeMultiByte(user.password);
    	
    	var variables:Object = {"api_key": user.apiKey, "user[email]": escapeMultiByte(user.email), "user[password]": escapeMultiByte(user.password)};
    	service.callRequest("users/token", variables, callbackFunc, URLRequestMethod.POST);
	}

	/*
	 * タスクの一覧を取得する。
	 */
	public function executeGetTasks(callbackFunc:Function, user:STUser, token:STToken, showCompleted:String):void {
		var urlPath:String = "users/" + token.userId + "/tasks";
    	var requests:Object = {
    		"api_key": user.apiKey,
    		"access_token": token.accessToken,
    		"show_completed" : showCompleted };

    	service.callRequest(urlPath, requests, 
    		function(result:LoadResult):void {
    			if (!result.isSuccess) {
    				callbackFunc(result, null);
    			} else {
    				callbackFunc(result, completeGetTasks(result.xml));
    			}
    		}, 
    	URLRequestMethod.GET);
	}
	
	/* タスクリスト取得完了時 - STTaskに格納 */
    private function completeGetTasks(result:XML):ArrayCollection { 
       result.ignoreWhite = true;
       var size:int = result.length();
       var work:ArrayCollection = new ArrayCollection();
       for each (var node:Object in result.children()) {
       		var task:STTask = new STTask();
       		task.name = node.name;
       		task.id = node.id;
       		if (task.id == 0) {
       			continue;
       		}
       		task.tags = node.tags;
       		task.hours = parseNumber(node.hours);
       		task.role = node.role;       		
       		task.updatedAt = parseDate(node["updated-at"]);
       		task.completedOn = parseDate(node["completed-on"]);
       		task.createdAt = parseDate(node["created-at"]);
       		task.ownerId = node.owners.person["user-id"];
       		task.isUpdated = true;
       		task.isCreated = true;
       		work.addItem(task);
       }
       return work;
    }
	
	/*
	 * タスクを新規作成する。
	 */
	public function executeCreateTask(callbackFunc:Function, user:STUser, token:STToken, task:STTask):void {
		var urlPath:String = "users/" + token.userId + "/tasks";
    	var requests:Object = {"api_key": user.apiKey,
    		"access_token": token.accessToken};
		var xml:XML = <task></task>;
		xml.appendChild(<name>{task.name}</name>);
		xml.appendChild(<role>{task.role}</role>);
		xml.appendChild(<tags>{task.tags}</tags>);
		xml.appendChild(<created-at>{task.createdAt}</created-at>);
    	service.postXml(createPath(urlPath, requests), null, xml, callbackFunc, URLRequestMethod.POST);	
    }
    
	/*
	 * タスクを更新する。
	 */
	public function executeUpdateTask(task:STTask, user:STUser, token:STToken, callbackFunc:Function):void {
		var urlPath:String = "users/" + token.userId + "/tasks/" + task.id;
    	var requests:Object = {"api_key": user.apiKey,
    		"access_token": token.accessToken};
		var xml:XML = <task></task>;
		xml.appendChild(<name>{task.name}</name>);
		xml.appendChild(<role>{task.role}</role>);
		xml.appendChild(<tags>{task.tags}</tags>);
		xml.appendChild(<updated-at>{task.updatedAt}</updated-at>);
		xml.appendChild(<completed-on>{task.completedOn}</completed-on>);
		//trace(xml.toString());
    	service.postXml(createPath(urlPath, requests), null, xml, callbackFunc, URLRequestMethod.PUT);	
    }
    
	/*
	 * タスクを削除する。
	 */
	public function executeDeleteTask(callbackFunc:Function, user:STUser, token:STToken, task:STTask):void {
		var urlPath:String = "users/" + token.userId + "/tasks/" + task.id;
    	var requests:Object = {"api_key": user.apiKey,
    		"access_token": token.accessToken};
    	service.postXml(createPath(urlPath, requests), null, null, callbackFunc, URLRequestMethod.DELETE);	
    }
    
    // ***********************************************************
	
	/*
	 * TimeEntryの一覧を取得する。
	 */
	public function executeGetTimeEntries(rangeStart:String, rangeEnd:String, user:STUser, token:STToken, callbackFunc:Function):void {
		var urlPath:String = "users/" + token.userId + "/time_entries";   	
    	var requests:Object = {"api_key": user.apiKey, "access_token": token.accessToken 
    	, "range_start":rangeStart, "range_end":rangeEnd};
    	service.callRequest(urlPath, requests, 
    	function(result:LoadResult):void {
    		if (result.isSuccess) {
    			callbackFunc(result, completedGetTimeEntry(result.xml));
    		} else {
    			callbackFunc(result, null);
    		}
    	}, URLRequestMethod.GET);
	}

	private function completedGetTimeEntry(result:XML):ArrayCollection {
		result.ignoreWhite = true;
		//trace(result);
       var size:int = result.length();
       var work:ArrayCollection = new ArrayCollection();
       for each (var node:Object in result.children()) {
       		var time:STTimeEntry = new STTimeEntry();
       		time.id = node.id;
       		if (time.id == 0) {
       			continue;
       		}

       		time.task = ASlimTimer.TASKS_CONTROLLER.getTask(node.task.id, node.task.name);
       		time.durationInSeconds = node["duration-in-seconds"];
       		var progress:String = node["in-progress"];
       		
     		if (progress == 'true') {
     			time.inProgress = true;
     		} else {
     			time.inProgress = false;
     		}

       		time.startTime = parseDate(node["start-time"]);
       		time.endTime = parseDate(node["end-time"]);      		
       		time.createdAt = parseDate(node["created-at"]);
       		time.tags = node.tags;
       		time.comments = node.comments;
       		time.isUpdated = true;
       		time.isCreated = true;
       		work.addItem(time);
       }
       return work;
	}
    
	
	/*
	 * 新しいTimeEntryを作成する。
	 * 
	 * 送信可能なXMLはメソッド内で構築する。
	 */
	public function executeCreateTimeEntry(callbackFunc:Function, user:STUser, token:STToken, timeEntry:STTimeEntry):void {
		var urlPath:String = "users/" + token.userId + "/time_entries";
    	var requests:Object = {"api_key": user.apiKey, "access_token": token.accessToken };
		var xml:XML = <time-entry></time-entry>;
		xml.appendChild(<task-id>{timeEntry.task.id}</task-id>);
		xml.appendChild(<start-time>{timeEntry.startTime.toLocaleString()}</start-time>);
		if (timeEntry.endTime != null) {
			xml.appendChild(<end-time>{timeEntry.endTime.toLocaleString()}</end-time>);
		}
		xml.appendChild(<duration-in-seconds>{timeEntry.durationInSeconds}</duration-in-seconds>);
		xml.appendChild(<in-progress>{timeEntry.inProgress}</in-progress>);
		xml.appendChild(<created-at>{timeEntry.createdAt}</created-at>);
		if (timeEntry.comments != null) {
			xml.appendChild(<comments>{timeEntry.comments}</comments>);
		}

		//trace(xml.toString());
    	service.postXml(createPath(urlPath, requests), null, xml, callbackFunc, URLRequestMethod.POST);
	}
	
	/*
	 * 新しいTimeEntryを作成する。一括登録Batch用
	 */
	public function executeCreateTimeEntry4Batch(callbackFunc:Function, user:STUser, token:STToken, timeEntry:STTimeEntry):void {
		var urlPath:String = "users/" + token.userId + "/time_entries";
    	var requests:Object = {"api_key": user.apiKey, "access_token": token.accessToken };
		var xml:XML = <time-entry></time-entry>;
		xml.appendChild(<task-id>{timeEntry.task.id}</task-id>);
		xml.appendChild(<start-time>{timeEntry.startTime.toLocaleString()}</start-time>);
		xml.appendChild(<end-time>{timeEntry.endTime.toLocaleString()}</end-time>);
		xml.appendChild(<duration-in-seconds>{timeEntry.durationInSeconds}</duration-in-seconds>);
		xml.appendChild(<in-progress>{timeEntry.inProgress}</in-progress>);
		xml.appendChild(<created-at>{timeEntry.createdAt}</created-at>);
		xml.appendChild(<comments>{timeEntry.comments}</comments>);
		trace(xml.toString());
    	service.postXml(createPath(urlPath, requests), null, xml, callbackFunc, URLRequestMethod.POST);
	}
	
	/*
	 * 既存のTimeEntryを削除する。
	 */
	public function executeDeleteTimeEntry(timeEntryId:Number, user:STUser, token:STToken, callbackFunk:Function):void {
		var urlPath:String = "users/" + token.userId + "/time_entries/" + timeEntryId;
    	var requests:Object = {"api_key": user.apiKey, "access_token": token.accessToken };
    	service.callRequest(createPath(urlPath, requests), null, callbackFunk, URLRequestMethod.DELETE);
	}
	
	/*
	 * 既存のTimeEntryを更新する。
	 * 送信可能なXMLが引数で渡される必要がある。
	 * // STTimeEntry.durationInSecondsの値は現在日時を参考に自動的に更新する。
	 */
	public function executeUpdateTimeEntry(timeEntry:STTimeEntry, user:STUser, token:STToken, callbackFunc:Function):void {
		var urlPath:String = "users/" + token.userId + "/time_entries/" + timeEntry.id;
    	var requests:Object = {"api_key": user.apiKey,"access_token": token.accessToken };
    	service.postXml(createPath(urlPath, requests), null, getUpdateTimeEntryXML(timeEntry), callbackFunc, URLRequestMethod.PUT);
	}
	
	private function createPath(path:String, requests:Object):String {
		//Pathの生成
    	var urlPath:String = path;
    	var i:int = 0;
    	for (var req:String in requests) {
    		if (i == 0) {
    			urlPath = urlPath + "?";
    		} else {
    			urlPath = urlPath + "&";
    		}
			urlPath = urlPath + req + "=" + requests[req];
			i++;
		}
		//trace("urlPath=" + urlPath);
		return urlPath;
	}
	
	/* TimeEntry更新用XMLを取得する */
    private function getUpdateTimeEntryXML(timeEntry:STTimeEntry):XML {
    	// XMLでReuqestBodyを作成。
		var xml:XML = <time-entry></time-entry>;
		xml.appendChild(<id>{timeEntry.id}</id>);
		xml.appendChild(<task-id>{timeEntry.task.id}</task-id>);
		xml.appendChild(<start-time>{timeEntry.startTime.toLocaleString()}</start-time>);
		xml.appendChild(<duration-in-seconds>{timeEntry.durationInSeconds}</duration-in-seconds>);
		if (timeEntry.endTime != null) {
			xml.appendChild(<end-time>{timeEntry.endTime.toLocaleString()}</end-time>);
		}
		if (timeEntry.tags != null) {
			xml.appendChild(<tags>{timeEntry.tags}</tags>);
		}
		if (timeEntry.comments != null) {
			xml.appendChild(<comments>{timeEntry.comments}</comments>);
		}
		if (timeEntry.updatedAt != null) {
			xml.appendChild(<updated-at>{timeEntry.updatedAt.toLocaleString()}</updated-at>);
		}
		xml.appendChild(<in-progress>{timeEntry.inProgress}</in-progress>);
		//trace(xml.toString());
		return xml;
	}
	
    /* 文字列を数値型に変更する */
    private function parseNumber(value:String):Number {
    	if (value.length == 0){
    		return 0;
    	} else {
    		return new Number(value);
    	}
    }
    
    /* 文字列を日付型に変更する */
    private function parseDate(value:String) :Date {
    	//2008-07-09T16:20:48Z to
    	//YYYY/MM/DD HH:MM:SS TZD
        var patternStr:String = "(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}:\\d{2}:\\d{2})Z";
        var pattern:RegExp = new RegExp(patternStr, "i") ; 
        var rep:String = value.replace(pattern, "$1/$2/$3 $4");
    	if (rep.length == 0){
    		return null;
    	} else {
    		return new Date(rep);
    	}
    }
}
}
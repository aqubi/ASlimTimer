package controller {

import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.data.SQLResult;
import flash.events.SQLEvent;
import flash.events.SQLErrorEvent;
import flash.filesystem.File;
import flash.net.SharedObject;
import mx.collections.ArrayCollection;

import model.STTask;
import model.STToken;
import model.STTimeEntry;
import model.STAlarm;
import db.*;
import http.LoadResult;

/*
 * SQLiteのDBとのAccessをするController
 */
public class SQLiteController {
	private static const FILE_PATH:String = "app-storage:/ASlimTimer.db";
	private var conn:SQLConnection;
	private var stmt:SQLStatement;
	
	// ******************************************
	// DBに接続
	// ******************************************
	/* 接続する */
	public function SQLiteController():void {
		var file:File = new File(FILE_PATH);
		
		if (conn == null) {
			conn = new SQLConnection();
			conn.addEventListener(SQLEvent.OPEN, 
			function connectEnd(event:SQLEvent):void {
				trace("接続成功");
				conn.removeEventListener(SQLEvent.OPEN, connectEnd);
				createTable();
			});
			conn.addEventListener(SQLErrorEvent.ERROR, onSQLiteOpenError);
		}
		//conn.openAsync(file);
		conn.open(file);
	}
	
	/* SQLite接続失敗 */
	private function onSQLiteOpenError(event:SQLErrorEvent):void {
		trace("接続失敗:" + event);
	}
	
	/* SQLStatementを作成する */
	private function createSQLStatement():SQLStatement {
		if (stmt != null)  {
			stmt.removeEventListener(SQLErrorEvent.ERROR, onSQLiteExecuteError);
			stmt = null
		}
		stmt = new SQLStatement();
		stmt.sqlConnection = conn;
		stmt.addEventListener(SQLErrorEvent.ERROR, onSQLiteExecuteError);
		return stmt;
	}
	
	/* SQL実行失敗 */
	private function onSQLiteExecuteError(event:SQLErrorEvent):void {
		trace("実行失敗:" + event);
	}
	
	// ******************************************
	// テーブル作成
	// ******************************************
	/* テーブルを作成する */
	private function createTable():void {
		if (!conn.connected) {
			return;
		}
		stmt = createSQLStatement();
		stmt.text = TasksStore.getCreateTableSql();
		stmt.execute();	
			
		stmt.text = TimesStore.getCreateTableSql();
		stmt.execute();	
		
		stmt.text = AlarmStore.getCreateTableSql();
		stmt.execute();	
	}

	private function onSQLSuccess(event:SQLEvent):void {
		//trace("SQLが完了しました。" + event.target.text, false, 0, true);
	}
	
	// ******************************************
	// TASKの更新
	// ******************************************
	/* TaskをInsert */
	public function insertTask(task:STTask, token:STToken, callBack:Function=null):void {		
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callBack != null) {
					var result:LoadResult = new LoadResult();
					result.sqlEvent = event;
					callBack(result);
				}
			}, false, 0, true);

		TasksStore.setInsertStatement(task, token, stmt);		
		stmt.execute();
	}
	
	/* TaskをUpdate */
	public function updateTask(task:STTask, token:STToken, callBack:Function=null):void {		
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callBack != null) {
					var result:LoadResult = new LoadResult();
					result.sqlEvent = event;
					callBack(result);
				}
			}, false, 0, true);

		TasksStore.setUpdateStatement(task, token, stmt);		
		stmt.execute();
	}
	
	/* TaskをUpdate */
	public function updateIdTask(task:STTask, oldId:Number, token:STToken, callBack:Function=null):void {		
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callBack != null) {
					var result:LoadResult = new LoadResult();
					result.sqlEvent = event;
					callBack(result);
				}
			}, false, 0, true);

		TasksStore.setIdUpdateStatement(task, oldId, token, stmt);		
		stmt.execute();
	}
	
	/* TaskをDelete */
	public function deleteTask(task:STTask, token:STToken, callBack:Function = null):void {		
		//関連するTimeEntryを削除(サーバ上は自動的に削除してくれるので、ここではDBを物理的に削除)
		stmt = createSQLStatement();
		TimesStore.setDeleteTaskIDStatement(task.id, token, stmt);
		stmt.execute();
		
		//関連するAlartを削除
		stmt = createSQLStatement();
		AlarmStore.setDeleteTaskIDStatement(task.id, stmt);
		stmt.execute();
		
		//Taskを削除
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callBack != null) {
					var result:LoadResult = new LoadResult();
					result.sqlEvent = event;
					callBack(result);
				}
			}, false, 0, true);

		if (!task.isCreated) {
			//DBを削除する
			TasksStore.setDeleteStatement(task, token, stmt);
		} else {
			//削除フラグをつける
			TasksStore.setUpdateDeletedStatement(task, token, stmt);
		}	
		stmt.execute();
	}
	
	// ******************************************
	// TASKの同期
	// ******************************************
	
	/* Networkで同期が必要な新規作成Taskの一覧を取得 */
	public function getSynchroNewTasks(token:STToken):ArrayCollection {
		stmt = createSQLStatement();
		TasksStore.setSelectSynchroCreateStatement(token, stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					TasksStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}
	
	/* Networkで同期が必要な更新Taskの一覧を取得 */
	public function getSynchroUpdateTasks(token:STToken):ArrayCollection {
		stmt = createSQLStatement();
		TasksStore.setSelectSynchroUpdateStatement(token, stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					TasksStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}
	
	/* 削除が必要なタスク一覧の取得*/
	public function getSynchroDeleteTasks(token:STToken):ArrayCollection {
		stmt = createSQLStatement();
		TasksStore.setSelectSynchroSelectDeleteStatement(token, stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					TasksStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}
	
	// ******************************************
	// TASKの削除
	// ******************************************
	/* TaskをDeleteInsert */
	public function deleteInsertTasks(tasks:ArrayCollection, token:STToken):void {
		deleteTaskInfo(token);
		for each(var task:STTask in tasks) {
			insertTask(task, token, null);
		}
	}
	
	/* テーブル内容をクリア */
	private function deleteTaskInfo(token:STToken):void {
		stmt = createSQLStatement();
		TasksStore.setDeleteAllStatement(token, stmt);
		stmt.execute();	
	}
	
	// ******************************************
	// TASKの取得
	// ******************************************
	/* Taskを取得 */
	public function selectTasks(token:STToken, callback:Function=null):void {

		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
		function myFunc(event:SQLEvent):void {
			stmt.removeEventListener(SQLEvent.RESULT, myFunc);
			var tasks:ArrayCollection = new ArrayCollection();
			var result:SQLResult = event.target.getResult();
			onSQLSuccess(event);
			if (result.data != null && result.data.length != 0) {
				TasksStore.parse(tasks, result.data);
			}
			if (callback != null) {
				var result2:LoadResult = new LoadResult();
				result2.sqlEvent = event;
				callback(result2, tasks);
			}
		}, false, 0, true);

		TasksStore.setSelectStatement(token, stmt);
		stmt.execute();	
	}


	// ******************************************
	// TimeEntryの更新
	// ******************************************

	/* TimeEntryをInsert */
	public function insertTimeEntry(task:STTimeEntry, token:STToken, callbackFunc:Function=null):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callbackFunc != null) { callBack(callbackFunc, event); }
			}, false, 0, true);

		TimesStore.setInsertStatement(task, token, stmt);
		stmt.execute();
	}
	
	/* TimeEntryをUpdate */
	public function updateTimeEntry(task:STTimeEntry, token:STToken, callbackFunc:Function=null):void {
		stmt = createSQLStatement();
		TimesStore.setSelectTimeEntryStatement(task, token, stmt);
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				var result:SQLResult = event.target.getResult();
				if (result.data == null || result.data.length == 0) {
					insertTimeEntry(task, token);
				}
			}, false, 0, true);
		stmt.execute();

		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callbackFunc != null) { callBack(callbackFunc, event) };
			}, false, 0, true);
		TimesStore.setUpdateStatement(task, token, stmt);
		stmt.execute();
	}
	
	/* TimeEntryをDelete */
	public function deleteTimeEntry(timeEntry:STTimeEntry, token:STToken, callbackFunc:Function=null):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callbackFunc != null) { callBack(callbackFunc, event) };
			}, false, 0, true);
			
		if (!timeEntry.isCreated) {
			//DBを削除する
			TimesStore.setDeleteStatement(timeEntry, token, stmt);
			stmt.execute();
		} else {
			//データがなければ作成する
			timeEntry.isOfflineDeleted = true;
			stmt = createSQLStatement();
			TimesStore.setSelectTimeEntryStatement(timeEntry, token, stmt);
			stmt.addEventListener(SQLEvent.RESULT, 
				function myFunc(event:SQLEvent):void {
					var result:SQLResult = event.target.getResult();
					stmt.removeEventListener(SQLEvent.RESULT, myFunc);
					if (result.data == null || result.data.length == 0) {
						insertTimeEntry(timeEntry, token);
					} else {
						//削除フラグをつける
						stmt = createSQLStatement();
						TimesStore.setUpdateDeletedStatement(timeEntry, token, stmt);
						stmt.execute();
					}
				}, false, 0, true);
			stmt.execute();
		}

	}
	
//	/* TimeEntryをDelete */
//	public function deleteAllTimeEntry(token:STToken, callbackFunc:Function=null):void {
//		stmt = createSQLStatement();
//		TimesStore.setDeleteAllStatement(token, stmt);
//		stmt.addEventListener(SQLEvent.RESULT, 
//			function myFunc(event:SQLEvent):void {
//				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
//				if (callbackFunc != null) { callBack(callbackFunc, event) };
//			}, false, 0, true);
//	}
	
	/* 時間の範囲でTimeEntryを取得する */
	public function getSelectTimeEntryByDate(start:String, end:String, token:STToken):ArrayCollection {
		stmt = createSQLStatement();
		TimesStore.setSelectStatementByDate(new Date(start), new Date(end), token, stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					TimesStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}
	
	// ******************************************
	// TimeEntryの同期
	// ******************************************
	/* TimeEntryのTaskIDを更新する */
	public function updateTimeEntryToTaskId(oldId:Number, newId:Number, token:STToken, callbackFunc:Function=null):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				if (callbackFunc != null) { callBack(callbackFunc, event) };
			}, false, 0, true);
		TimesStore.setUpdateStatementToTaskId(oldId, newId, token, stmt);
		stmt.execute();
	}
	
	private function callBack(callbackFunc:Function, event:SQLEvent):void {
		if (callbackFunc != null) {
			var result:LoadResult = new LoadResult();
			result.sqlEvent = event;
			callbackFunc(result);
		}
	}
	
	public function getSelectTimeEntry(token:STToken):ArrayCollection {
		stmt = createSQLStatement();
		TimesStore.setSelectStatement(token, stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					TimesStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}
	
//	/* テーブル内容をクリア */
//	public function deleteAllTimeEntryInfo(token:STToken):void {
//		stmt = createSQLStatement();
//		TimesStore.setDeleteAllStatement(token, stmt);
//		stmt.execute();	
//	}

	
	// ******************************************
	// Alarmの更新
	// ******************************************
	public function loadAlarm():ArrayCollection {
		stmt = createSQLStatement();
		AlarmStore.setSelectStatement(stmt);
		var works:ArrayCollection = new ArrayCollection();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				var result:SQLResult = event.target.getResult();
				if (result.data != null && result.data.length != 0) {
					AlarmStore.parse(works, result.data);
				}
			}, false, 0, true);
		stmt.execute();	
		return works;
	}

	public function insertAlarm(alarm:STAlarm, callbackFunc:Function):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				callBack(callbackFunc, event);
			}, false, 0, true);

		AlarmStore.setInsertStatement(alarm, stmt);
		stmt.execute();
	}
	
	public function updateAlarm(alarm:STAlarm, callbackFunc:Function):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				callBack(callbackFunc, event);
			}, false, 0, true);

		AlarmStore.setUpdateStatement(alarm, stmt);
		stmt.execute();
	}
	
	public function deleteAlarm(alarm:STAlarm, callbackFunc:Function):void {
		stmt = createSQLStatement();
		stmt.addEventListener(SQLEvent.RESULT, 
			function myFunc(event:SQLEvent):void {
				stmt.removeEventListener(SQLEvent.RESULT, myFunc);
				callBack(callbackFunc, event);
			}, false, 0, true);

		AlarmStore.setDeleteStatement(alarm, stmt);
		stmt.execute();
	}
}
}
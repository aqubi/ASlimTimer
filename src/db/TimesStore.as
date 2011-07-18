package db {
import mx.collections.ArrayCollection;
import flash.data.SQLStatement;

import controller.TasksController;
import model.STToken;
import model.STTimeEntry;

/* Times情報のDB保存関連の処理を行なう */
public class TimesStore {
		
	/* CreateTable文の作成 */
	static public function getCreateTableSql():String {
		var sql:String = "CREATE TABLE IF NOT EXISTS times ("
		+ "id INTEGER PRIMARY KEY,"
		+ "user_id INTEGER,"
		+ "start_time DATE NOT NULL,"
		+ "end_time DATE,"
		+ "duration_in_seconds NUMERIC NOT NULL,"
		+ "task_id INTEGER NOT NULL," 
		+ "task_name String,"
		+ "tags TEXT,"
		+ "comments TEXT,"
		+ "in_progress TEXT,"
		+ "updated_at DATE,"
		+ "created_at DATE,"
		+ "is_created INTEGER,"
		+ "is_updated INTEGER,"
		+ "is_offline_deleted INTEGER)";
		return sql;
	}
		
	/* SQLStatementにInsert文の設定を行なう */
	static public function setInsertStatement(task:STTimeEntry, token:STToken, stmt:SQLStatement):void {
		var sql:String = "INSERT INTO times (" + 
		 	"user_id, id, start_time, end_time, duration_in_seconds, tags, comments,"
		 	+ "in_progress, task_id, task_name, created_at, updated_at, is_created, "
		 	+ "is_updated, is_offline_deleted" + 
		  	") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";		

		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = task.id; 
		stmt.parameters[2] = task.startTime;
		stmt.parameters[3] = task.endTime;	
		stmt.parameters[4] = task.durationInSeconds;
		stmt.parameters[5] = task.tags;
		stmt.parameters[6] = task.comments;
		stmt.parameters[7] = task.inProgress;
		stmt.parameters[8] = task.task.id;
		stmt.parameters[9] = task.task.name;
		stmt.parameters[10] = task.createdAt;
		stmt.parameters[11] = task.updatedAt;
		stmt.parameters[12] = task.isCreated;
		stmt.parameters[13] = task.isUpdated;
		stmt.parameters[14] = task.isOfflineDeleted;
	}
	
	/* SQLStatementにUpdate文の設定を行なう */
	static public function setUpdateStatement(task:STTimeEntry, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE times SET" + 
		 	" start_time = ?, end_time = ?, duration_in_seconds =?, tags = ?, comments = ?,"
		 	+ " in_progress = ?, updated_at = ?, is_created = ? ,is_updated = ?, task_id = ?, task_name = ?"
		 	+ " WHERE id = ? AND user_id = ?";	
		stmt.text = sql;
		stmt.parameters[0] = task.startTime; 
		stmt.parameters[1] = task.endTime; 
		stmt.parameters[2] = task.durationInSeconds;	
		stmt.parameters[3] = task.tags;
		stmt.parameters[4] = task.comments;
		stmt.parameters[5] = task.inProgress;
		stmt.parameters[6] = task.updatedAt;
		stmt.parameters[7] = task.isCreated;
		stmt.parameters[8] = task.isUpdated;
		stmt.parameters[9] = task.task.id;	
		stmt.parameters[10] = task.task.name;
		stmt.parameters[11] = task.id;
		stmt.parameters[12] = token.userId;	
	}
	
	/* SQLStatementにTaskIdのの設定を行なう */
	static public function setUpdateStatementToTaskId(oldId:Number, newId:Number, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE times SET" + 
		 	" task_id = ?"
		 	+ " WHERE task_id = ? AND user_id = ?";	
		stmt.text = sql;
		stmt.parameters[0] = newId; 
		stmt.parameters[1] = oldId;	
		stmt.parameters[2] = token.userId;	
	}
	
	/* SQLStatementにDeleteの設定を行なう */
	static public function setUpdateDeletedStatement(task:STTimeEntry, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE times SET" + 
		 	" is_offline_deleted = ?"
		 	+ " WHERE id = ? AND user_id = ?";	
		stmt.text = sql;
		stmt.parameters[0] = true;
		stmt.parameters[1] = task.id; 
		stmt.parameters[2] = token.userId;	
	}
	
	/* SQLStatementにDelete文の設定を行なう */
	static public function setDeleteStatement(time:STTimeEntry, token:STToken, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM times WHERE user_id = ? AND id = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = time.id;
	}

//	/* SQLStatementに全Delete文の設定を行なう */
//	static public function setDeleteAllStatement(token:STToken, stmt:SQLStatement):void {
//		var sql:String = "DELETE FROM times WHERE user_id = ?　AND is_updated = ?";
//		stmt.text = sql;
//		stmt.parameters[0] = token.userId;
//		stmt.parameters[1] = true;
//	}
//	
	/* SQLStatementにTaskIDでDelete文の設定を行なう */
	static public function setDeleteTaskIDStatement(taskId:Number, token:STToken, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM times WHERE user_id = ? AND task_id = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = taskId;
	}
	
	/* SQLStatementにSelect文の設定を行なう */
	static public function setSelectStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM times WHERE user_id = ? ORDER BY id DESC";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
	}
	
	/* IDをKeyにSQLStatementにSelect文の設定を行なう */
	static public function setSelectTimeEntryStatement(time:STTimeEntry, token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM times WHERE user_id = ? AND id = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = time.id;
	}
	
	/* 日付をKeyにSQLStatementにSelect文の設定をおこなう */
	static public function setSelectStatementByDate(start:Date, end:Date, token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM times WHERE user_id = ? AND start_time >= ? AND start_time <= ? AND is_offline_deleted = ? ORDER BY start_time ASC";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = start;
		stmt.parameters[2] = end;	
		stmt.parameters[3] = false;	
	}
	
	/* 取得したTaskXMLをSTTaskに変換する */
	static public function parse(times:ArrayCollection, resultData:Object):void {
		for (var i:int = 0; i < resultData.length; i++) {
			var time:STTimeEntry = new STTimeEntry();
			var obj:Object = resultData[i];
			if (obj["id"] == null || obj["id"] == 0) {
				continue;
			}
			for (var col:String in obj) {
				if (col == "id") {
					time.id = obj[col];
				} else if (col == "start_time") {
					time.startTime = obj[col];
				} else if (col == "end_time") {
					time.endTime = obj[col];
				} else if (col == "duration_in_seconds") {
					time.durationInSeconds = obj[col];
				} else if (col == "task_id") {
					time.task = ASlimTimer.TASKS_CONTROLLER.getTask(obj[col], obj["task_name"]);
				} else if (col == "task_name") {
					//Noting todo.
				} else if (col == "tags") {
					time.tags = obj[col];
				} else if (col == "comments") {
					time.comments = obj[col];
				} else if (col == "in_progress") {
					//DBの型がTEXTになっているのでキャストしてBooleanにしている
					time.inProgress = Boolean(Number(obj[col]));
				} else if (col == "updated_at") {
					time.updatedAt = obj[col];
				} else if (col == "created_at") {
					time.createdAt = obj[col];
				} else if (col == "is_created") {
					time.isCreated = obj[col];
				} else if (col == "is_updated") {
					time.isUpdated = obj[col];
				} else if (col == "is_offline_deleted") {
					time.isOfflineDeleted = obj[col];
				} else {
					//trace(col + ":" + obj[col]);
				}
			}
			times.addItem(time);
		}
	}
	

}
}
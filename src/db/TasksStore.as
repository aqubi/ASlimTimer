package db {
import mx.collections.ArrayCollection;
import flash.data.SQLStatement;
import model.STToken;
import model.STTask;

/* Task情報のDB保存関連の処理を行なう */
public class TasksStore {
		
	/* CreateTable文の作成 */
	static public function getCreateTableSql():String {
		var sql:String = "CREATE TABLE IF NOT EXISTS tasks ("
		+ "id INTEGER PRIMARY KEY,"
		+ "user_id INTEGER,"
		+ "name TEXT," 
		+ "role TEXT,"
		+ "tags TEXT,"
		+ "hours NUMERIC,"
		+ "created_at DATE,"
		+ "updated_at DATE,"
		+ "completed_on DATE,"
		+ "owner_id INTEGER,"
		+ "is_created INTEGER,"
		+ "is_updated INTEGER,"
		+ "is_offline_deleted INTEGER)";
		return sql;
	}
		
	/* SQLStatementにInsert文の設定を行なう */
	static public function setInsertStatement(task:STTask, token:STToken, stmt:SQLStatement):void {
		var sql:String = "INSERT INTO tasks (" + 
		 	"user_id, id, name, tags, hours, role, updated_at, " +
		 	"completed_on, created_at, is_created, is_updated, owner_id," + 
		  	"is_offline_deleted) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";		

		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = task.id; 
		stmt.parameters[2] = task.name;	
		stmt.parameters[3] = task.tags;
		stmt.parameters[4] = task.hours;
		stmt.parameters[5] = task.role;
		stmt.parameters[6] = task.updatedAt;
		stmt.parameters[7] = task.completedOn;
		stmt.parameters[8] = task.createdAt;
		stmt.parameters[9] = task.isCreated;
		stmt.parameters[10] = task.isUpdated;
		stmt.parameters[11] = task.ownerId;
		stmt.parameters[12] = task.isOfflineDeleted;
	}

	/* SQLStatementにDelete文の設定を行なう */
	static public function setDeleteStatement(task:STTask, token:STToken, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM tasks WHERE id = ? AND user_id = ?";
		stmt.text = sql;
		stmt.parameters[0] = task.id;
		stmt.parameters[1] = token.userId;
	}
	
	/* SQLStatementにDeleteの設定を行なう */
	static public function setUpdateDeletedStatement(task:STTask, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE tasks SET" + 
		 	" is_offline_deleted = ?"
		 	+ " WHERE id = ? AND user_id = ?";	
		stmt.text = sql;
		stmt.parameters[0] = true;
		stmt.parameters[1] = task.id; 
		stmt.parameters[2] = token.userId;	
	}

	/* SQLStatementにDelete文の設定を行なう */
	static public function setDeleteAllStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM tasks WHERE user_id = ? and id > 0";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
	}
	
	/* SQLStatementにSelect文の設定を行なう */
	static public function setSelectStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM tasks WHERE user_id = ? AND is_offline_deleted = ? ORDER BY id ASC";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = false;
	}
	
	/* SQLStatementにUpdate文の設定を行なう */
	static public function setUpdateStatement(task:STTask, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE tasks SET "
		 + " name = ?, tags = ?, hours= ?, created_at = ?, updated_at = ?"
		 + ", completed_on = ?,  is_updated = ?  "
		 + " WHERE id = ? AND user_id = ?";
		stmt.text = sql;
		stmt.parameters[0] = task.name;
		stmt.parameters[1] = task.tags;
		stmt.parameters[2] = task.hours;
		stmt.parameters[3] = task.createdAt;
		stmt.parameters[4] = task.updatedAt;
		stmt.parameters[5] = task.completedOn;
		stmt.parameters[6] = task.isUpdated;
		stmt.parameters[7] = task.id;
		stmt.parameters[8] = token.userId;
	}
	
	/* SQLStatementに新しく取得したIDのUpdate文の設定を行なう */
	static public function setIdUpdateStatement(task:STTask, oldId:Number, token:STToken, stmt:SQLStatement):void {
		var sql:String = "UPDATE tasks SET "
		 + " id = ?, name = ?, tags = ?, hours= ?, created_at = ?, updated_at = ?"
		 + ", completed_on = ?, is_created = ?, is_updated = ?  "
		 + " WHERE id = ? AND user_id = ?";
		stmt.text = sql;
		stmt.parameters[0] = task.id;
		stmt.parameters[1] = task.name;
		stmt.parameters[2] = task.tags;
		stmt.parameters[3] = task.hours;
		stmt.parameters[4] = task.createdAt;
		stmt.parameters[5] = task.updatedAt;
		stmt.parameters[6] = task.completedOn;
		stmt.parameters[7] = task.isCreated;
		stmt.parameters[8] = task.isUpdated;
		stmt.parameters[9] = oldId;
		stmt.parameters[10] = token.userId;

	}
	
	/* 取得したTaskXMLをSTTaskに変換する */
	static public function parse(tasks:ArrayCollection, resultData:Object):void {
		resultData.ignoreWhite = true;
		for (var i:int = 0; i < resultData.length; i++) {
			var task:STTask = new STTask();
			var obj:Object = resultData[i];

			if (obj["id"] == null || obj["id"] == 0) {
				continue;
			}

			for (var col:String in obj) {
				if (col == "id") {
					task.id = obj[col];
				} else if (col == "name") {
					task.name = obj[col];
				} else if (col == "tags") {
					task.tags = obj[col];
				} else if (col == "hours") {
					task.hours = obj[col];
				} else if (col == "role") {
					task.role = obj[col];
				} else if (col == "created_at") {
					task.createdAt = obj[col];
				} else if (col == "updated_at") {
					task.updatedAt = obj[col];
				} else if (col == "completed_on") {
					task.completedOn = obj[col];
				} else if (col == "owner_id") {
					task.ownerId = obj[col];
				} else if (col == "is_created") {
					task.isCreated = obj[col];
				} else if (col == "is_updated") {
					task.isUpdated = obj[col];
				} else if (col == "is_offline_deleted") {
					task.isOfflineDeleted = obj[col];
				} else {
					//trace(col + ":" + obj[col]);
				}
			}
			tasks.addItem(task);
		}
	}	
	
		
	/* SQLStatementにオフライン時に作成したTASKのSELECT文の設定を行なう */
	static public function setSelectSynchroCreateStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM tasks WHERE user_id = ? AND is_created = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = false;
	}
	
	/* SQLStatementにオフライン時に更新したTASKのSELECT文の設定を行なう */
	static public function setSelectSynchroUpdateStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM tasks WHERE user_id = ? AND is_updated = ? AND is_created = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = false;
		stmt.parameters[2] = true;
	}
	
	/* SQLStatementにオフライン時に更新した削除用のSELECT文の設定を行なう */
	static public function setSelectSynchroSelectDeleteStatement(token:STToken, stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM tasks WHERE user_id = ? AND is_offline_deleted = ?";
		stmt.text = sql;
		stmt.parameters[0] = token.userId;
		stmt.parameters[1] = true;
	}
}
}
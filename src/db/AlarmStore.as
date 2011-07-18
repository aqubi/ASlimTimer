package db {
import mx.collections.ArrayCollection;
import flash.data.SQLStatement;
import model.STAlarm;


/* Alarm情報のDB保存関連の処理を行なう */
public class AlarmStore {
		
	/* CreateTable文の作成 */
	static public function getCreateTableSql():String {
		var sql:String = "CREATE TABLE IF NOT EXISTS alarms ("
		+ "id INTEGER PRIMARY KEY,"
		+ "name TEXT,"
		+ "hours NUMERIC,"
		+ "minutes NUMERIC,"
		+ "date DATE,"
		+ "mp3 TEXT,"
		+ "task_id NUMBER,"
		+ "onetime_only INTEGER)";
		return sql;
	}
		
	/* SQLStatementにInsert文の設定を行なう */
	static public function setInsertStatement(alarm:STAlarm, stmt:SQLStatement):void {
		var sql:String = "INSERT INTO alarms (" + 
		 	"id, name, hours, minutes, date, " +
		 	"mp3, task_id, onetime_only) VALUES (?,?,?,?,?,?,?,?)";		

		stmt.text = sql;
		stmt.parameters[0] = alarm.id;
		stmt.parameters[1] = alarm.name; 
		stmt.parameters[2] = alarm.hours;	
		stmt.parameters[3] = alarm.minutes;
		stmt.parameters[4] = alarm.date;
		stmt.parameters[5] = alarm.mp3;
		stmt.parameters[6] = alarm.taskId;
		stmt.parameters[7] = alarm.oneTimeOnly;
	}

	/* SQLStatementにDelete文の設定を行なう */
	static public function setDeleteStatement(alarm:STAlarm, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM alarms WHERE id = ?";
		stmt.text = sql;
		stmt.parameters[0] = alarm.id;
	}
	
	/* SQLStatementにTaskIDをKeyにDelete文の設定を行なう */
	static public function setDeleteTaskIDStatement(taskId:Number, stmt:SQLStatement):void {
		var sql:String = "DELETE FROM alarms WHERE task_id = ?";
		stmt.text = sql;
		stmt.parameters[0] = taskId;
	}
	
	/* SQLStatementにSelect文の設定を行なう */
	static public function setSelectStatement(stmt:SQLStatement):void {
		var sql:String = "SELECT * FROM alarms ORDER BY hours, minutes";
		stmt.text = sql;
	}
	
	/* SQLStatementにUpdate文の設定を行なう */
	static public function setUpdateStatement(alarm:STAlarm, stmt:SQLStatement):void {
		var sql:String = "UPDATE alarms SET "
		 + " name = ?, hours= ?, minutes = ?, date = ?"
		 + ", mp3 = ?,  task_id = ?, onetime_only = ?  "
		 + " WHERE id = ?";
		stmt.text = sql;
		stmt.parameters[0] = alarm.name;
		stmt.parameters[1] = alarm.hours;
		stmt.parameters[2] = alarm.minutes;
		stmt.parameters[3] = alarm.date;
		stmt.parameters[4] = alarm.mp3;
		stmt.parameters[5] = alarm.taskId;
		stmt.parameters[6] = alarm.oneTimeOnly;
		stmt.parameters[7] = alarm.id;
	}

	
	/* 取得したTaskXMLをSTTaskに変換する */
	static public function parse(alarms:ArrayCollection, resultData:Object):void {
		resultData.ignoreWhite = true;
		for (var i:int = 0; i < resultData.length; i++) {
			var alarm:STAlarm = new STAlarm();
			var obj:Object = resultData[i];

			if (obj["id"] == null || obj["id"] == 0) {
				continue;
			}

			for (var col:String in obj) {
				if (col == "id") {
					alarm.id = obj[col];
				} else if (col == "name") {
					alarm.name = obj[col];
				} else if (col == "hours") {
					alarm.hours = obj[col];
				} else if (col == "minutes") {
					alarm.minutes = obj[col];
				} else if (col == "date") {
					alarm.date = obj[col];
				} else if (col == "mp3") {
					alarm.mp3 = obj[col];
				} else if (col == "task_id") {
					alarm.taskId = obj[col];
				} else if (col == "onetime_only") {
					alarm.oneTimeOnly = obj[col];
				}
			}
			alarms.addItem(alarm);
		}
	}	

}
}
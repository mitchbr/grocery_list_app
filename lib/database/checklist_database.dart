import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class ChecklistDatabase {
  String dbName = 'grocery_checklist';

  Future<Database> loadSqlStartup() async {
    Database db = await openDatabase(
      'grocery.db',
      version: 3,
      onCreate: (Database db, int version) async {
        var sqlScript = await rootBundle.loadString('assets/grocery.txt');
        List<String> sqlScripts = sqlScript.split(";");
        for (var v in sqlScripts) {
          if (v.isNotEmpty) {
            db.execute(v.trim());
          }
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          var sqlScript = await rootBundle.loadString('assets/grocery.txt');
          List<String> sqlScripts = sqlScript.split(";");
          for (var v in sqlScripts) {
            if (v.isNotEmpty) {
              db.execute(v.trim());
            }
          }
        }
      },
    );

    return db;
  }

  Future<List<Map>> loadItems() async {
    Database db = await loadSqlStartup();

    List<Map> entries = await db.rawQuery('SELECT * FROM $dbName');

    return entries;
  }

  Future<void> deleteItem(title) async {
    Database db = await loadSqlStartup();

    await db.transaction((txn) async {
      // TODO: Change to use id
      await txn.rawDelete('DELETE FROM $dbName WHERE title = ?', [title]);
    });
  }

  Future<void> deleteChecked() async {
    Database db = await loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM $dbName WHERE checked = 1');
    });
  }

  Future<void> addItem(index, title, source) async {
    Database db = await loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO $dbName(list_index, title, checked, source) VALUES(?, ?, ?, ?)', [index, title, 0, source]);
    });
  }

  Future<void> updateItem(id, {checked = -1, listIndex = -1}) async {
    Database db = await loadSqlStartup();

    List queryItems = [id];
    var queryString = "";

    if (checked != -1) {
      queryString = "$queryString checked = ?";
      queryItems.insert(0, checked);
    }
    if (listIndex != -1) {
      queryString = "$queryString list_index = ?";
      queryItems.insert(0, listIndex);
    }

    await db.transaction((txn) async {
      await txn.rawInsert('UPDATE $dbName SET $queryString WHERE id = ?', queryItems);
    });
  }
}

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class ChecklistDatabase {
  Future<String> loadSqlStartup() async {
    return await rootBundle.loadString('assets/grocery.txt');
  }

  Future<List<Map>> loadItems() async {
    String dbString = await loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(dbString);
    });
    List<Map> entries = await db.rawQuery('SELECT * FROM grocery_checklist');
    db.close();
    return entries;
  }

  Future<void> deleteItem(title) async {
    String dbString = await loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(dbString);
    });

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM grocery_checklist WHERE item = ?', [title]);
    });
    db.close();
  }

  Future<void> addItem(item) async {
    String dbString = await loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(dbString);
    });

    await db.transaction((txn) async {
      await txn.rawInsert('INSERT INTO grocery_checklist(item) VALUES(?)', [item]);
    });

    db.close();
  }
}

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class RecipesDatabase {
  String dbName = 'recipes_list';

  Future<Database> loadSqlStartup() async {
    Database db = await openDatabase('recipes.db', version: 2, onCreate: (Database db, int version) async {
      var sqlScript = await rootBundle.loadString('assets/recipes.txt');
      List<String> sqlScripts = sqlScript.split(";");
      sqlScripts.forEach((v) {
        if (v.isNotEmpty) {
          print(v.trim());
          db.execute(v.trim());
        }
      });
    });

    return db;
  }

  Future<List<Map>> loadItems() async {
    Database db = await loadSqlStartup();

    List<Map> entries = await db.rawQuery('SELECT * FROM recipes_list');
    db.close();
    return entries;
  }
}

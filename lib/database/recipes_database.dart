import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'package:groceries/types/recipe_entry.dart';

class RecipesDatabase {
  String dbName = 'recipes_list';

  Future<Database> _loadSqlStartup() async {
    Database db = await openDatabase('recipes.db', version: 2, onCreate: (Database db, int version) async {
      var sqlScript = await rootBundle.loadString('assets/recipes.txt');
      List<String> sqlScripts = sqlScript.split(";");
      for (var v in sqlScripts) {
        if (v.isNotEmpty) {
          db.execute(v.trim());
        }
      }
    });

    return db;
  }

  Future<List<Map>> loadItems() async {
    Database db = await _loadSqlStartup();

    List<Map> entries = await db.rawQuery('SELECT * FROM recipes_list');
    return entries;
  }

  Future<void> addItem(RecipeEntry entry) async {
    Database db = await _loadSqlStartup();

    await db.transaction(
      (txn) async {
        await txn.rawInsert('INSERT INTO recipes_list(recipe, ingredients, instructions) VALUES(?, ?, ?)',
            [entry.recipe, json.encode(entry.ingredients), entry.instructions]);
      },
    );
  }

  Future<void> deleteItem(title) async {
    Database db = await _loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM recipes_list WHERE recipe = ?', [title]);
    });
  }
}

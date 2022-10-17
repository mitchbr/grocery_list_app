import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'package:groceries/types/recipe_entry.dart';

class RecipesDatabase {
  String dbName = 'recipes_list';

  Future<Database> _loadSqlStartup() async {
    Database db = await openDatabase('recipes.db', version: 1, onCreate: (Database db, int version) async {
      var sqlScript = await rootBundle.loadString('assets/recipes.txt');
      List<String> sqlScripts = sqlScript.split(";");
      for (var v in sqlScripts) {
        if (v.isNotEmpty) {
          await db.execute(v.trim());
        }
      }
    });

    return db;
  }

  Future<List<Map>> loadItems({sort, category}) async {
    Database db = await _loadSqlStartup();

    const sortOptions = {
      "updatedAtNewest": "ORDER BY updatedAt DESC",
      "updatedAtOldest": "ORDER BY updatedAt ASC",
      "createdAtNewest": "ORDER BY createdAt DESC",
      "createdAtOldest": "ORDER BY createdAt ASC",
      "timesMadeMost": "ORDER BY timesMade DESC",
      "timesMadeLeast": "ORDER BY timesMade ASC",
    };

    sort = sortOptions.containsKey(sort) ? sort : "updatedAtNewest";
    final String categoryQuery = (category != "None") ? "WHERE category = '$category'" : "";

    List<Map> entries = await db.rawQuery("SELECT * FROM recipes_list  $categoryQuery ${sortOptions[sort]}");
    return entries;
  }

  Future<void> addItem(RecipeEntry entry) async {
    Database db = await _loadSqlStartup();

    await db.transaction(
      (txn) async {
        await txn.rawInsert(
            'INSERT INTO recipes_list(recipe, ingredients, instructions, category, tags, updatedAt, createdAt, timesMade) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
            [
              entry.recipe,
              json.encode(entry.ingredients),
              entry.instructions,
              entry.category,
              json.encode(entry.tags),
              entry.updatedAt,
              entry.createdAt,
              entry.timesMade
            ]);
      },
    );
  }

  Future<void> deleteItem(id) async {
    Database db = await _loadSqlStartup();

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM recipes_list WHERE id = ?', [id]);
    });
  }
}

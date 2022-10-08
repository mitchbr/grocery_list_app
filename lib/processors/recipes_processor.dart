import 'dart:convert';

import 'package:groceries/components/recipe_entry.dart';
import 'package:groceries/database/recipes_database.dart';

class RecipesProcessor {
  RecipesDatabase database = RecipesDatabase();

  Future<List> loadRecipes() async {
    List<Map> entries = await database.loadItems();

    return entries.map((record) {
      return RecipeEntry(
        recipe: record['recipe'],
        ingredients: json.decode(record['ingredients']),
        instructions: record['instructions'],
      );
    }).toList();
  }
}

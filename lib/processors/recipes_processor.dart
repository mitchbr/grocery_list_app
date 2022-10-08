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

  Future<void> addRecipe(recipe) async {
    await database.addItem(recipe);
  }

  Future<void> deleteRecipe(recipe) async {
    await database.deleteItem(recipe.title);
  }

  Future<void> updateRecipe(recipe, oldTitle) async {
    await database.deleteItem(oldTitle);
    await database.addItem(recipe);
  }
}

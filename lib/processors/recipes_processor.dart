import 'dart:convert';

import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/database/recipes_database.dart';

class RecipesProcessor {
  RecipesDatabase database = RecipesDatabase();
  String sort = "updatedAtNewest";

  Future<List> loadRecipes() async {
    List<Map> entries = await database.loadItems(sort: sort);

    return entries.map((record) {
      return RecipeEntry(
          recipe: record['recipe'],
          ingredients: json.decode(record['ingredients']),
          instructions: record['instructions'],
          category: "Entree",
          tags: "temp",
          updatedAt: record['updatedAt'],
          createdAt: record['createdAt'],
          timesMade: record['timesMade']);
    }).toList();
  }

  void setSort(newSort) {
    const sortOptions = {
      "Newest Updated": "updatedAtNewest",
      "Oldest Updated": "updatedAtOldest",
      "Newest": "createdAtNewest",
      "Oldest": "createdAtOldest",
      "Most Times Made": "timesMadeMost",
      "Least Times Made": "timesMadeLeast"
    };
    sort = (sortOptions.containsKey(newSort) ? sortOptions[newSort] : sortOptions["Newest Updated"])!;
  }

  Future<void> addRecipe(recipe) async {
    await database.addItem(recipe);
  }

  Future<void> deleteRecipe(title) async {
    await database.deleteItem(title);
  }

  Future<void> updateRecipe(RecipeEntry recipe, String oldTitle) async {
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    // TODO: use update query
    await database.deleteItem(oldTitle);
    await database.addItem(recipe);
  }

  Future<void> incrementTimesMade(RecipeEntry recipe, String oldTitle) async {
    recipe.timesMade += 1;
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    // TODO: Use update query
    await database.deleteItem(oldTitle);
    await database.addItem(recipe);
  }
}

import 'package:groceries/api/recipe_api.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class RecipesProcessor {
  // RecipesDatabase database = RecipesDatabase();
  RecipesApi recipesApi = RecipesApi();
  ProfileProcessor profileProcessor = ProfileProcessor();

  String sort;
  String category;

  RecipesProcessor()
      : category = "None",
        sort = "updatedAtNewest";

  Future<List> loadRecipes() async {
    String username = await profileProcessor.getUsername();
    List<Map> entries = await recipesApi.getEntries(username);

    // Filter
    entries.where((entry) => category != 'None' ? entry['category'] == category : true);

    // Sort

    return entries.map((record) {
      return RecipeEntry(
          id: record["id"],
          recipe: record['recipe'],
          ingredients: record['ingredients'],
          instructions: record['instructions'],
          category: record["category"],
          tags: record["tags"],
          updatedAt: record['updatedAt'],
          createdAt: record['createdAt'],
          timesMade: record['timesMade'],
          author: record['author']);
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

  void setCategory(newCategory) {
    category = newCategory;
  }

  Future<void> addRecipe(recipe) async {
    recipe.author = await profileProcessor.getUsername();

    await recipesApi.addItem(recipe);
  }

  Future<void> deleteRecipe(id) async {
    await recipesApi.deleteItem(id);
  }

  Future<void> updateRecipe(RecipeEntry recipe) async {
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await recipesApi.updateItem(recipe);
  }

  Future<void> incrementTimesMade(RecipeEntry recipe) async {
    recipe.timesMade += 1;
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    recipesApi.updateItem(recipe);
  }
}

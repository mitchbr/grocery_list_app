import 'package:groceries/api/recipe_api.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class RecipesProcessor {
  RecipesApi recipesApi = RecipesApi();
  ProfileProcessor profileProcessor = ProfileProcessor();

  Map sort;
  String category;
  Map sortOptions = {
    "Newest Updated": {"key": "updatedAt", "order": "asc"},
    "Oldest Updated": {"key": "updatedAt", "order": "desc"},
    "Newest": {"key": "createdAt", "order": "asc"},
    "Oldest": {"key": "createdAt", "order": "desc"},
    "Most Times Made": {"key": "timesMade", "order": "asc"},
    "Least Times Made": {"key": "timesMade", "order": "desc"},
  };

  RecipesProcessor()
      : category = "None",
        sort = {"key": "updatedAt", "order": "asc"};

  List<RecipeEntry> processEntries(List<Map> entries) {
    // Filter
    entries = entries.where((entry) => category != 'None' ? entry['category'] == category : true).toList();

    // Sort
    if (sort["order"] == "asc") {
      entries.sort((a, b) => b[sort["key"]].compareTo(a[sort["key"]]));
    } else {
      entries.sort((a, b) => a[sort["key"]].compareTo(b[sort["key"]]));
    }

    return entries.map((record) {
      return processEntry(record);
    }).toList();
  }

  RecipeEntry processEntry(entry) {
    return RecipeEntry(
        id: entry["id"],
        recipe: entry['recipe'],
        ingredients: entry['ingredients'],
        instructions: entry['instructions'],
        category: entry["category"],
        tags: entry["tags"],
        updatedAt: entry['updatedAt'],
        createdAt: entry['createdAt'],
        timesMade: entry['timesMade'],
        author: entry['author']);
  }

  Future<List> loadRecipes() async {
    String username = await profileProcessor.getUsername();
    List<Map> entries = await recipesApi.getEntries(username);

    // Filter
    entries = entries.where((entry) => category != 'None' ? entry['category'] == category : true).toList();

    // Sort
    if (sort["order"] == "asc") {
      entries.sort((a, b) => b[sort["key"]].compareTo(a[sort["key"]]));
    } else {
      entries.sort((a, b) => a[sort["key"]].compareTo(b[sort["key"]]));
    }

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
    sort = (sortOptions.containsKey(newSort) ? sortOptions[newSort]! : sortOptions["Newest Updated"])!;
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

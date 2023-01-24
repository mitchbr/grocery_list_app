import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class RecipesProcessor {
  ProfileProcessor profileProcessor = ProfileProcessor();

  final _fireStore = FirebaseFirestore.instance;
  final List<String> _availableTags;
  List<String> _tagFilters;
  Map sort;
  String category;
  String source;
  String sourceUser = "";
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
        source = "All",
        _tagFilters = [],
        _availableTags = [],
        sort = {"key": "updatedAt", "order": "asc"};

  List<RecipeEntry> processEntries(List entries) {
    // Filter
    entries = entries
        .where((entry) => category != 'None' ? entry['category'] == category : true)
        .where((entry) => source != "All"
            ? (source == "Personal" ? entry["author"] == sourceUser : entry["author"] != sourceUser)
            : true)
        .where((entry) => _tagFilters.every((tag) => tagInTags(entry, tag)))
        .toList();

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

  bool tagInTags(entry, tag) {
    var entryTags = entry["tags"].map((tag) => tag.toLowerCase()).toList();
    bool inTags = entryTags.contains(tag);
    return inTags;
  }

  RecipeEntry processEntry(entry) {
    for (String tag in entry['tags']) {
      !_availableTags.contains(tag.toLowerCase()) ? _availableTags.add(tag.toLowerCase()) : null;
    }

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

  void setSort(newSort) {
    sort = (sortOptions.containsKey(newSort) ? sortOptions[newSort]! : sortOptions["Newest Updated"])!;
  }

  void setCategory(newCategory) {
    category = newCategory;
  }

  setSource(newSource, username) {
    source = newSource;
    sourceUser = username;
  }

  getAvailableTags() {
    return _availableTags;
  }

  getActiveTags() {
    return _tagFilters;
  }

  setTagFilter(newTags) {
    _tagFilters = newTags;
  }

  Future<void> addRecipe(recipe) async {
    recipe.author = await profileProcessor.getUsername();

    await addItem(recipe);
  }

  Future<void> deleteRecipe(id) async {
    await deleteItem(id);
  }

  Future<void> updateRecipe(RecipeEntry recipe) async {
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await updateItem(recipe);
  }

  Future<void> incrementTimesMade(RecipeEntry recipe) async {
    recipe.timesMade += 1;
    recipe.updatedAt = DateTime.now().millisecondsSinceEpoch;
    updateItem(recipe);
  }

  Future<void> addItem(RecipeEntry entry) async {
    var recipesCollection = _fireStore.collection('recipes');
    recipesCollection.add({
      'recipe': entry.recipe,
      'ingredients': entry.ingredients,
      'instructions': entry.instructions,
      'category': entry.category,
      'tags': entry.tags,
      'updatedAt': entry.updatedAt,
      'createdAt': entry.createdAt,
      'timesMade': entry.timesMade,
      'author': entry.author
    });
  }

  Future<void> deleteItem(id) async {
    var checklistCollection = _fireStore.collection('recipes');
    await checklistCollection.doc(id).delete();
  }

  Future<void> updateItem(recipe) async {
    var checklistCollection = _fireStore.collection('recipes');
    await checklistCollection.doc(recipe.id).update({
      'recipe': recipe.recipe,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'category': recipe.category,
      'tags': recipe.tags,
      'updatedAt': recipe.updatedAt,
      'createdAt': recipe.createdAt,
      'timesMade': recipe.timesMade,
    });
  }
}

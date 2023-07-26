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
  String _search = "";
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

  Future<List<RecipeEntry>> processEntries(List entries) async {
    List pinnedRecipes = await profileProcessor.fetchPinnedRecipes();

    // Filter
    entries = filterEntries(entries);

    // Sort
    entries.sort((a, b) {
      // Sort by pinned first
      int pinnedComp = pinnedRecipes.contains(b["id"]).toString().compareTo(pinnedRecipes.contains(a["id"]).toString());

      // Then sort by chosen attribute
      if (pinnedComp == 0 && sort["order"] == "asc") {
        return b[sort["key"]].compareTo(a[sort["key"]]);
      } else if ((pinnedComp == 0 && sort["order"] != "asc")) {
        return a[sort["key"]].compareTo(b[sort["key"]]);
      }
      return pinnedComp;
    });

    return entries.map((record) {
      return processEntry(record, pinnedRecipes);
    }).toList();
  }

  List filterEntries(unfilteredEntries) {
    // Category filter
    var entries =
        unfilteredEntries.where((entry) => category != 'None' ? entry['category'] == category : true).toList();

    // source filter
    entries = entries
        .where((entry) => source != "All"
            ? (source == "Personal" ? entry["author"] == sourceUser : entry["author"] != sourceUser)
            : true)
        .toList();

    // tags filter
    entries = entries.where((entry) => _tagFilters.every((tag) => tagInTags(entry, tag))).toList();

    // search
    entries = entries
        .where((entry) => _search != ""
            ? (entry['recipe'].toLowerCase().contains(_search.toLowerCase()) ||
                entry['author'].toLowerCase().contains(_search.toLowerCase()))
            : true)
        .toList();
    return entries;
  }

  bool tagInTags(entry, tag) {
    var entryTags = entry["tags"].map((tag) => tag.toLowerCase()).toList();
    bool inTags = entryTags.contains(tag);
    return inTags;
  }

  RecipeEntry processEntry(entry, pinnedRecipes) {
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
      author: entry['author'],
      private: entry.containsKey('private') ? entry['private'] : false,
      pinned: pinnedRecipes.contains(entry["id"]),
    );
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

  void setSearch(enteredSearch) {
    _search = enteredSearch;
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
      'author': entry.author,
      'private': entry.private
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
      'private': recipe.private,
    });
  }
}

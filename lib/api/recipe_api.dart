import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/types/recipe_entry.dart';

CollectionReference recipes = FirebaseFirestore.instance.collection('recipes');

class RecipesApi {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<Map>> getEntries(author, {sort, category}) async {
    var querySnapshot = await _fireStore.collection('recipes').where('author', isEqualTo: author).get();
    var entries = querySnapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();

    return entries;
  }

  Future<void> addItem(RecipeEntry entry) async {
    var recipesCollection = _fireStore.collection('recipes');
    recipesCollection.add({
      'recipe': entry.recipe,
      'ingredients': entry.ingredients,
      'instructions': entry.instructions,
      'category': entry.category,
      'tags': entry.tags,
      'updatedAd': entry.updatedAt,
      'createdAt': entry.createdAt,
      'timesMade': entry.timesMade,
    });
  }

  Future<void> deleteItem(id) async {
    // TODO: Add error catching
    var checklistCollection = _fireStore.collection('recipes');
    await checklistCollection.doc(id).delete();
  }

  Future<void> updateItem(recipe) async {
    var checklistCollection = _fireStore.collection('recipes');
    await checklistCollection.doc(recipe.uuid).update({
      'recipe': recipe.recipe,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'category': recipe.category,
      'tags': recipe.tags,
      'updatedAd': recipe.updatedAt,
      'createdAt': recipe.createdAt,
      'timesMade': recipe.timesMade,
    });
  }
}

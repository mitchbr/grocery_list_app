import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProcessor {
  bool savedUsername = false;

  Future<SharedPreferences> _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<String> getUsername() async {
    var prefs = await _getPrefs();
    String username = prefs.getString('username') ?? 'no_username_set';

    return username;
  }

  Future<void> setUsername(String username) async {
    var prefs = await _getPrefs();
    await prefs.setString('username', username);
  }

  Future<List> fetchFollowedRecipes() async {
    String username = await getUsername();
    DocumentSnapshot recipes = await FirebaseFirestore.instance.collection('authors').doc(username).get();
    return recipes.get('recipes_following');
  }

  Future<void> addFollowedRecipe(recipeId) async {
    List recipesList = await fetchFollowedRecipes();
    recipesList.add(recipeId);

    String username = await getUsername();
    DocumentReference recipes = FirebaseFirestore.instance.collection('authors').doc(username);
    recipes.update({'recipes_following': recipesList});
  }

  Future<void> removeFromLibrary(recipeId) async {
    List recipesList = await fetchFollowedRecipes();
    recipesList.remove(recipeId);

    String username = await getUsername();
    DocumentReference recipes = FirebaseFirestore.instance.collection('authors').doc(username);
    recipes.update({'recipes_following': recipesList});
  }

  Future<List> fetchFollowedAuthors() async {
    String username = await getUsername();
    DocumentSnapshot recipes = await FirebaseFirestore.instance.collection('authors').doc(username).get();
    return recipes.get('authors_following');
  }

  Future<void> addFollowedAuthor(authorId) async {
    List recipesList = await fetchFollowedAuthors();
    recipesList.add(authorId);

    String username = await getUsername();
    DocumentReference recipes = FirebaseFirestore.instance.collection('authors').doc(username);
    recipes.update({'authors_following': recipesList});
  }

  Future<void> removeFollowedAuthor(authorId) async {
    List recipesList = await fetchFollowedAuthors();
    recipesList.remove(authorId);

    String username = await getUsername();
    DocumentReference recipes = FirebaseFirestore.instance.collection('authors').doc(username);
    recipes.update({'authors_following': recipesList});
  }
}

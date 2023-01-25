import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/layouts/personal_recipe_details_layout.dart';
import 'package:groceries/layouts/saved_recipe_details_layout.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/widgets/filter_sort.dart';

import 'package:groceries/widgets/firestore_list.dart';
import 'package:groceries/processors/recipes_processor.dart';

class PersonalRecipesView extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const PersonalRecipesView({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  State<PersonalRecipesView> createState() => _PersonalRecipesViewState();
}

class _PersonalRecipesViewState extends State<PersonalRecipesView> {
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();
  List<dynamic> followedRecipes = [];
  String username = '';

  @override
  void initState() {
    profileProcessor.fetchFollowedRecipes().then((value) {
      setState(() {
        followedRecipes = value;
      });
    });
    profileProcessor.getUsername().then((value) {
      setState(() {
        username = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterSort(
            recipesProcessor: widget.recipesProcessor,
            callback: callback,
          ),
          FirestoreList(
            stream: _recipesStream,
            dataProcessor: dataProcessor,
            listTile: groceryTile,
            scroll: false,
          ),
        ],
      ),
    );
  }

  List<RecipeEntry> dataProcessor(snapshot, username) {
    var personalRecipes = snapshot.data!.docs
        .where((element) => element['author'] == username)
        .map((e) => {'id': e.id, ...e.data()! as Map})
        .toList();
    var savedRecipes = snapshot.data!.docs
        .where((element) => followedRecipes.contains(element.id))
        .map((e) => {'id': e.id, ...e.data()! as Map})
        .toList();
    return widget.recipesProcessor.processEntries([...personalRecipes, ...savedRecipes]);
  }

  void pushRecipeDetails(BuildContext context, recipe) {
    if (recipe.author == username) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalRecipeDetailsLayout(recipeEntry: recipe)))
          .then((data) => setState(() => {}));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SavedRecipeDetailsLayout(recipeEntry: recipe)))
          .then((data) => setState(() => {}));
    }
  }

  Widget groceryTile(var item) {
    return ListTile(
      title: Text(item.recipe),
      subtitle: item.author == username ? const Text("Personal") : Text("Author: ${item.author}"),
      onTap: () => pushRecipeDetails(context, item),
    );
  }

  void callback() {
    setState(() {});
  }
}

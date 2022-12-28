import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

import 'package:groceries/widgets/firestore_list.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';

class SavedRecipesView extends StatefulWidget {
  const SavedRecipesView({Key? key}) : super(key: key);

  @override
  State<SavedRecipesView> createState() => _SavedRecipesViewState();
}

class _SavedRecipesViewState extends State<SavedRecipesView> {
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final ProfileProcessor profileProcessor = ProfileProcessor();

  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();
  List<dynamic> followedRecipes = [];

  @override
  void initState() {
    profileProcessor.fetchFollowedRecipes().then((value) {
      setState(() {
        followedRecipes = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreList(
        stream: _recipesStream, dataProcessor: dataProcessor, listTitle: listTitle, pushDetails: pushRecipeDetails);
  }

  List<RecipeEntry> dataProcessor(snapshot, username) {
    return recipesProcessor.processEntries(snapshot.data!.docs
        .where((element) => followedRecipes.contains(element.id))
        .map((e) => {'id': e.id, ...e.data()! as Map})
        .toList());
  }

  void pushRecipeDetails(BuildContext context, recipe) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetails(recipeEntry: recipe)))
        .then((data) => setState(() => {}));
  }

  Widget listTitle(item) {
    return Text(item.recipe);
  }
}

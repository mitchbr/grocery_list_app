import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/types/recipe_entry.dart';

import 'package:groceries/widgets/firestore_list.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';

class FollowedAuthorRecipesView extends StatefulWidget {
  final String userId;
  const FollowedAuthorRecipesView({Key? key, required this.userId}) : super(key: key);

  @override
  State<FollowedAuthorRecipesView> createState() => _FollowedAuthorRecipesViewState();
}

class _FollowedAuthorRecipesViewState extends State<FollowedAuthorRecipesView> {
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();

  @override
  Widget build(BuildContext context) {
    return FirestoreList(
        stream: _recipesStream, dataProcessor: dataProcessor, listTitle: listTitle, pushDetails: pushRecipeDetails);
  }

  List<RecipeEntry> dataProcessor(snapshot, username) {
    return recipesProcessor.processEntries(snapshot.data!.docs
        .where((element) => element['author'] == widget.userId)
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

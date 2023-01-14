import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/layouts/authors_recipe_details_layout.dart';
import 'package:groceries/types/recipe_entry.dart';

import 'package:groceries/widgets/firestore_list.dart';
import 'package:groceries/processors/recipes_processor.dart';

class FollowedAuthorRecipesView extends StatefulWidget {
  final String userId;
  final RecipesProcessor recipesProcessor;
  const FollowedAuthorRecipesView({Key? key, required this.userId, required this.recipesProcessor}) : super(key: key);

  @override
  State<FollowedAuthorRecipesView> createState() => _FollowedAuthorRecipesViewState();
}

class _FollowedAuthorRecipesViewState extends State<FollowedAuthorRecipesView> {
  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();

  @override
  Widget build(BuildContext context) {
    return FirestoreList(stream: _recipesStream, dataProcessor: dataProcessor, listTile: groceryTile);
  }

  List<RecipeEntry> dataProcessor(snapshot, username) {
    return widget.recipesProcessor.processEntries(snapshot.data!.docs
        .where((element) => element['author'] == widget.userId)
        .map((e) => {'id': e.id, ...e.data()! as Map})
        .toList());
  }

  void pushRecipeDetails(BuildContext context, recipe) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthorsRecipeDetailsLayout(recipeEntry: recipe)))
        .then((data) => setState(() => {}));
  }

  Widget groceryTile(var item) {
    return ListTile(
      title: Text(item.recipe),
      onTap: () => pushRecipeDetails(context, item),
    );
  }
}

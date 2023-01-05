import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/layouts/personal_recipe_details_layout.dart';
import 'package:groceries/types/recipe_entry.dart';

import 'package:groceries/widgets/firestore_list.dart';
import 'package:groceries/processors/recipes_processor.dart';

class PersonalRecipesView extends StatefulWidget {
  const PersonalRecipesView({Key? key}) : super(key: key);

  @override
  State<PersonalRecipesView> createState() => _PersonalRecipesViewState();
}

class _PersonalRecipesViewState extends State<PersonalRecipesView> {
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();

  @override
  Widget build(BuildContext context) {
    return FirestoreList(
        stream: _recipesStream, dataProcessor: dataProcessor, listTitle: listTitle, pushDetails: pushRecipeDetails);
  }

  List<RecipeEntry> dataProcessor(snapshot, username) {
    return recipesProcessor.processEntries(snapshot.data!.docs
        .where((element) => element['author'] == username)
        .map((e) => {'id': e.id, ...e.data()! as Map})
        .toList());
  }

  void pushRecipeDetails(BuildContext context, recipe) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalRecipeDetailsLayout(recipeEntry: recipe)))
        .then((data) => setState(() => {}));
  }

  Widget listTitle(item) {
    return Text(item.recipe);
  }
}

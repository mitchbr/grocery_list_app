import 'package:flutter/material.dart';

import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';
import 'package:groceries/custom_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeEntries extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const RecipeEntries({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  _RecipeEntriesState createState() => _RecipeEntriesState();
}

class _RecipeEntriesState extends State<RecipeEntries> {
  var bodyWidget;
  var recipesList;
  var sqlCreate;
  String username = 'initial_username';

  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();

  late RecipesProcessor recipesProcessor;
  ProfileProcessor profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  @override
  void initState() {
    setState(() {
      profileProcessor.getUsername().then((value) => username = value);
    });

    recipesProcessor = widget.recipesProcessor;

    super.initState();
  }

  /*
   *
   * Page Entry Point
   * 
   */
  @override
  Widget build(BuildContext context) {
    return bodyBuilder(context);
  }

  /*
   *
   * Page Views
   * 
   */
  Widget bodyBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _recipesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return errorIndicator(context);
        }

        if (snapshot.connectionState == ConnectionState.waiting || username == 'initial_username') {
          return circularIndicator(context);
        }

        recipesList = recipesProcessor.processEntries(snapshot.data!.docs
            .where((element) => element['author'] == username)
            .map((e) => {'id': e.id, ...e.data()! as Map})
            .toList());

        if (recipesList.isEmpty) {
          return emptyWidget(context);
        }

        return entriesList(context);
      },
    );
  }

  Widget emptyWidget(BuildContext context) {
    return const Center(
        child: Icon(
      Icons.book,
      size: 100,
    ));
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  Widget errorIndicator(BuildContext context) {
    return const Center(child: Text("Error loading checklist"));
  }

  /*
   *
   * Recipes ListView
   * 
   */
  Widget entriesList(BuildContext context) {
    return ListView.builder(
      itemCount: recipesList.length,
      itemBuilder: (context, index) {
        return groceryTile(index);
      },
    );
  }

  Widget groceryTile(int index) {
    return ListTile(
      title: Text('${recipesList[index].recipe}'),
      onTap: () => pushRecipeDetails(context, recipesList[index]),
    );
  }

  void pushRecipeDetails(BuildContext context, recipeEntry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetails(recipeEntry: recipeEntry)))
        .then((data) => setState(() => {}));
  }
}

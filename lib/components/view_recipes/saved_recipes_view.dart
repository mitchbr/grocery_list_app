import 'package:flutter/material.dart';

import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';
import 'package:groceries/custom_theme.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRecipesView extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const SavedRecipesView({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  _RecipeEntriesState createState() => _RecipeEntriesState();
}

class _RecipeEntriesState extends State<SavedRecipesView> {
  var recipesList = [];
  String username = 'initial_username';
  List<dynamic> followedRecipes = [];
  bool loadedFollowedRecipes = false;

  final Stream<QuerySnapshot> _recipesStream = FirebaseFirestore.instance.collection('recipes').snapshots();

  late RecipesProcessor recipesProcessor;
  ProfileProcessor profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  @override
  void initState() {
    profileProcessor.fetchFollowedRecipes().then((value) {
      setState(() {
        followedRecipes = value;
        loadedFollowedRecipes = true;
      });
    });

    recipesProcessor = widget.recipesProcessor;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _recipesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return errorIndicator(context);
        }

        bool waiting = snapshot.connectionState == ConnectionState.waiting;
        if (waiting || loadedFollowedRecipes == false) {
          return circularIndicator(context);
        }

        recipesList = recipesProcessor.processEntries(snapshot.data!.docs
            .where((element) => followedRecipes.contains(element.id))
            .map((e) => {'id': e.id, ...e.data()! as Map})
            .toList());

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
      title: Text(recipesList[index].recipe),
      onTap: () => pushRecipeDetails(context, recipesList[index]),
    );
  }

  void pushRecipeDetails(BuildContext context, recipeEntry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetails(recipeEntry: recipeEntry)))
        .then((data) => setState(() => {}));
  }
}

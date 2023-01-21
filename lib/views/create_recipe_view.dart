import 'package:flutter/material.dart';
import 'package:groceries/widgets/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class CreateRecipeView extends StatefulWidget {
  const CreateRecipeView({Key? key}) : super(key: key);

  @override
  State<CreateRecipeView> createState() => _CreateRecipeViewState();
}

class _CreateRecipeViewState extends State<CreateRecipeView> {
  final recipesProcessor = RecipesProcessor();

  var entryData = RecipeEntry(
      id: 'init',
      recipe: '',
      ingredients: [],
      instructions: '',
      category: "",
      tags: [],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      timesMade: 0,
      author: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: RecipeForm(
        entryData: entryData,
        processorFunction: recipesProcessor.addRecipe,
      ),
    );
  }
}

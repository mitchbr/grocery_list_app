import 'package:flutter/material.dart';
import 'package:groceries/components/recipes_edit/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({Key? key}) : super(key: key);

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final recipesProcessor = RecipesProcessor();

  var entryData = RecipeEntry(
      id: 'init',
      recipe: '',
      ingredients: [],
      instructions: '',
      category: "",
      tags: "tag",
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

import 'package:flutter/material.dart';
import 'package:groceries/components/recipes_edit/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class CreateRecipeV2 extends StatefulWidget {
  const CreateRecipeV2({Key? key}) : super(key: key);

  @override
  State<CreateRecipeV2> createState() => _CreateRecipeV2State();
}

class _CreateRecipeV2State extends State<CreateRecipeV2> {
  final recipesProcessor = RecipesProcessor();

  var entryData = RecipeEntry(
      id: 0,
      recipe: '',
      ingredients: [],
      instructions: '',
      category: "",
      tags: "tag",
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      timesMade: 0);

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

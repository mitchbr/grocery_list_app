import 'package:flutter/material.dart';
import 'package:groceries/widgets/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class EditRecipeView extends StatefulWidget {
  final RecipeEntry entryData;
  const EditRecipeView({Key? key, required this.entryData}) : super(key: key);

  @override
  State<EditRecipeView> createState() => _EditRecipeViewState();
}

class _EditRecipeViewState extends State<EditRecipeView> {
  final recipesProcessor = RecipesProcessor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Recipe"),
      ),
      body: RecipeForm(
        entryData: widget.entryData,
        processorFunction: recipesProcessor.updateRecipe,
      ),
    );
  }
}

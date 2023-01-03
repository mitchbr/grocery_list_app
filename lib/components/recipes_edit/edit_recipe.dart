import 'package:flutter/material.dart';
import 'package:groceries/components/recipes_edit/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class EditRecipe extends StatefulWidget {
  final RecipeEntry entryData;
  const EditRecipe({Key? key, required this.entryData}) : super(key: key);

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
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

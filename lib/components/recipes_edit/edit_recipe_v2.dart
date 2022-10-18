import 'package:flutter/material.dart';
import 'package:groceries/components/recipes_edit/recipe_form.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class EditRecipeV2 extends StatefulWidget {
  final RecipeEntry entryData;
  const EditRecipeV2({Key? key, required this.entryData}) : super(key: key);

  @override
  State<EditRecipeV2> createState() => _EditRecipeV2State();
}

class _EditRecipeV2State extends State<EditRecipeV2> {
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

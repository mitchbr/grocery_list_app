import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/checklist_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/views/recipe_details/authors_recipe_details_enddrawer_view.dart';
import 'package:groceries/widgets/recipe_details.dart';

class AuthorsRecipeDetailsLayout extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const AuthorsRecipeDetailsLayout({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  State<AuthorsRecipeDetailsLayout> createState() => _AuthorsRecipeDetailsLayoutState();
}

class _AuthorsRecipeDetailsLayoutState extends State<AuthorsRecipeDetailsLayout> {
  final checklistProcessor = ChecklistProcessor();
  final recipesProcessor = RecipesProcessor();

  final theme = CustomTheme();

  late List<bool> checkedValues;

  @override
  void initState() {
    super.initState();
    checkedValues = List.filled(widget.recipeEntry.ingredients.length, false, growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AuthorsRecipeDetailsEndDrawerView(
        recipeEntry: widget.recipeEntry,
      ),
      appBar: AppBar(
        title: Text(widget.recipeEntry.recipe),
      ),
      body: RecipeDetails(
        checkedValues: checkedValues,
        recipeEntry: widget.recipeEntry,
      ),
      floatingActionButton: addToGroceryList(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget addToGroceryList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        child: const Text('Save to Grocery List'),
        onPressed: () async {
          List<GroceryEntry> entries = [];
          for (int i = 0; i < widget.recipeEntry.ingredients.length; i++) {
            if (checkedValues[i]) {
              entries.add(checklistProcessor.processEntry({'title': widget.recipeEntry.ingredients[i], 'checked': 0}));
            }
          }
          await checklistProcessor.updateChecklistFromUnknown(entries);
          await recipesProcessor.incrementTimesMade(widget.recipeEntry);

          Navigator.of(context).pop();
        },
      ),
    );
  }
}

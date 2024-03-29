import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/checklist_processor.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/views/edit_recipe_view.dart';
import 'package:groceries/widgets/bordered_icon_button.dart';
import 'package:groceries/widgets/recipe_details.dart';

class PersonalRecipeDetailsLayout extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const PersonalRecipeDetailsLayout({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  State<PersonalRecipeDetailsLayout> createState() => _PersonalRecipeDetailsLayoutState();
}

class _PersonalRecipeDetailsLayoutState extends State<PersonalRecipeDetailsLayout> {
  final checklistProcessor = ChecklistProcessor();
  final recipesProcessor = RecipesProcessor();
  final profileProcessor = ProfileProcessor();

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
      appBar: AppBar(
        title: Text(widget.recipeEntry.recipe),
      ),
      body: RecipeDetails(
        checkedValues: checkedValues,
        recipeEntry: widget.recipeEntry,
        actions: [
          BorderedIconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => shareRecipeId(context),
              );
            },
            icon: const Icon(Icons.share),
          ),
          BorderedIconButton(
            onPressed: () => pushEditEntry(context),
            icon: const Icon(Icons.edit),
          ),
          BorderedIconButton(
            onPressed: () =>
                showDialog<String>(context: context, builder: (BuildContext context) => verifyDeleteRecipe(context)),
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
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

          if (!widget.recipeEntry.pinned) {
            showDialog<String>(context: context, builder: (BuildContext context) => pinRecipePopupDialog());
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void pushEditEntry(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeView(entryData: widget.recipeEntry)))
        .then((data) {
      setState(() => {});
    });
  }

  Widget pinRecipePopupDialog() {
    return AlertDialog(
        title: const Text('Pin Recipe?'),
        content: const Text('The recipe will appear at the top of your recipe list'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              profileProcessor.addPinnedRecipe(widget.recipeEntry.id);
              Navigator.of(context).pop();
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ]);
  }

  Widget shareRecipeId(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Recipe'),
      content: Text(widget.recipeEntry.id),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            ClipboardData data = ClipboardData(text: widget.recipeEntry.id);
            await Clipboard.setData(data);
          },
          child: const Icon(Icons.copy),
        ),
      ],
    );
  }

  Widget verifyDeleteRecipe(BuildContext context) {
    return AlertDialog(
        title: const Text('Delete Recipe?'),
        content: const Text('This will permanently remove the recipe'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              recipesProcessor.deleteRecipe(widget.recipeEntry.id);
              setState(() {});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

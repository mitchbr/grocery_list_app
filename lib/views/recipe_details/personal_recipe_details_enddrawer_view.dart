import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/widgets/page_drawer.dart';
import 'package:groceries/views/edit_recipe_view.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class PersonalRecipeDetailsEndDrawerView extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const PersonalRecipeDetailsEndDrawerView({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  State<PersonalRecipeDetailsEndDrawerView> createState() => _PersonalRecipeDetailsEndDrawerViewState();
}

class _PersonalRecipeDetailsEndDrawerViewState extends State<PersonalRecipeDetailsEndDrawerView> {
  final recipesProcessor = RecipesProcessor();

  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return PageDrawer(children: <Widget>[
      TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => shareRecipeId(context),
          );
        },
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
      TextButton.icon(
        onPressed: () => pushEditEntry(context),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      TextButton.icon(
        onPressed: () =>
            showDialog<String>(context: context, builder: (BuildContext context) => verifyDeleteRecipe(context)),
        icon: const Icon(Icons.delete_rounded),
        label: const Text('Delete'),
      ),
    ]);
  }

  void pushEditEntry(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeView(entryData: widget.recipeEntry)))
        .then((data) {
      setState(() => {});
    });
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
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

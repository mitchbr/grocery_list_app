import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/widgets/page_drawer.dart';
import 'package:groceries/views/edit_recipe_view.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class AuthorsRecipeDetailsEndDrawerView extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const AuthorsRecipeDetailsEndDrawerView({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  State<AuthorsRecipeDetailsEndDrawerView> createState() => _AuthorsRecipeDetailsEndDrawerViewState();
}

class _AuthorsRecipeDetailsEndDrawerViewState extends State<AuthorsRecipeDetailsEndDrawerView> {
  final recipesProcessor = RecipesProcessor();
  final profileProcessor = ProfileProcessor();

  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return PageDrawer(children: <Widget>[
      TextButton.icon(
        onPressed: () =>
            showDialog<String>(context: context, builder: (BuildContext context) => verifySaveRecipe(context)),
        icon: const Icon(Icons.save_alt),
        label: const Text('Add to Library'),
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

  Widget verifySaveRecipe(BuildContext context) {
    return AlertDialog(
        title: const Text('Add Recipe to Library?'),
        content: const Text('The recipe will appear under the Saved tab'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              profileProcessor.addFollowedRecipe(widget.recipeEntry.id);
              setState(() {});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

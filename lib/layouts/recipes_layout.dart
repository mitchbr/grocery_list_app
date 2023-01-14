import 'package:flutter/material.dart';

import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/widgets/filters_page.dart';
import 'package:groceries/widgets/page_drawer.dart';
import 'package:groceries/views/create_recipe_view.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/views/personal_recipes_view.dart';

class RecipesLayout extends StatefulWidget {
  const RecipesLayout({Key? key}) : super(key: key);

  @override
  State<RecipesLayout> createState() => _RecipesLayoutState();
}

class _RecipesLayoutState extends State<RecipesLayout> {
  final TextEditingController _recipeFromIdTextController = TextEditingController();
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final theme = CustomTheme();

  final sortOptions = ["Newest Updated", "Oldest Updated", "Newest", "Oldest", "Most Times Made", "Least Times Made"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(child: filterDropDown(context), padding: const EdgeInsets.all(2)),
            Padding(child: sortDropDown(context), padding: const EdgeInsets.all(2)),
          ],
        ),
      ),
      endDrawer: PageDrawer(children: <Widget>[
        TextButton.icon(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) => fromTextPopupDialog(),
            );
          },
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Import'),
        ),
        TextButton.icon(
            onPressed: () => pushCreateRecipe(context), icon: const Icon(Icons.add), label: const Text('New Recipe')),
      ]),
      body: PersonalRecipesView(recipesProcessor: recipesProcessor),
    );
  }

  Widget fromTextPopupDialog() {
    return AlertDialog(
      title: const Text('Import Items'),
      content: TextField(
        controller: _recipeFromIdTextController,
        decoration: theme.textFormDecoration('Enter Items'),
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 100,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await profileProcessor.addFollowedRecipe(_recipeFromIdTextController.text);
            setState(() {
              Navigator.of(context).pop();
              _recipeFromIdTextController.clear();
            });
          },
          child: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }

  pushCreateRecipe(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipeView())).then((data) {
      setState(() => {});
      Navigator.of(context).pop();
    });
  }

  Widget sortDropDown(BuildContext context) {
    return TextButton.icon(
      onPressed: () => {
        showDialog(
          context: context,
          builder: (BuildContext context) => sortPopupDialog(context),
        )
      },
      label: const Text("Sort"),
      icon: const Icon(Icons.arrow_drop_down),
    );
  }

  Widget filterDropDown(BuildContext context) {
    return TextButton.icon(
      onPressed: () => pushFilterPage(context),
      label: const Text("Filter"),
      icon: const Icon(Icons.filter_list),
    );
  }

  Widget sortPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort Recipes'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortOptions.map((option) => sortTile(option, context)).toList(),
      ),
    );
  }

  Widget sortTile(title, context) {
    return TextButton(
      onPressed: () {
        setState(() {
          recipesProcessor.setSort(title);
        });

        Navigator.of(context).pop();
      },
      child: Text(title),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.01))),
    );
  }

  void pushFilterPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FiltersPage(
                  recipesProcessor: recipesProcessor,
                ))).then((data) => {setState(() {})});
  }
}

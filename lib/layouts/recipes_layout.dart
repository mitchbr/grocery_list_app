import 'package:flutter/material.dart';

import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
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
  final TextEditingController _searchControl = TextEditingController();
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final theme = CustomTheme();

  final sortOptions = ["Newest Updated", "Oldest Updated", "Newest", "Oldest", "Most Times Made", "Least Times Made"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchFormField(),
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) => fromTextPopupDialog(),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            onPressed: () => pushCreateRecipe(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PersonalRecipesView(recipesProcessor: recipesProcessor),
    );
  }

  Widget fromTextPopupDialog() {
    return AlertDialog(
      title: const Text('Save Recipe to Library'),
      content: TextField(
        controller: _recipeFromIdTextController,
        decoration: theme.textFormDecoration('Enter Recipe ID'),
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

  Widget searchFormField() {
    return TextFormField(
      controller: _searchControl,
      cursorColor: theme.accentHighlightColor,
      decoration: theme.textFormIconDecoration('Search Recipes', Icons.search),
      onChanged: (value) {
        recipesProcessor.setSearch(value);
        setState(() {});
      },
    );
  }

  pushCreateRecipe(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipeView())).then((data) {
      setState(() => {});
    });
  }
}

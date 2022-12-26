import 'package:flutter/material.dart';

import 'package:groceries/components/view_recipes/recipes_view.dart';
import 'package:groceries/components/view_recipes/saved_recipes_view.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipes_filter_sort.dart';
import 'package:groceries/components/additional_pages/page_drawer.dart';
import 'package:groceries/components/recipes_edit/create_recipe_v2.dart';
import 'package:groceries/custom_theme.dart';

class RecipesLayout extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const RecipesLayout({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  State<RecipesLayout> createState() => _RecipesLayoutState();
}

class _RecipesLayoutState extends State<RecipesLayout> {
  final TextEditingController _recipeFromIdTextController = TextEditingController();
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: FilterSortRecipes(
            recipesProcessor: widget.recipesProcessor,
          ),
          bottom: TabBar(
            indicatorColor: theme.accentColor,
            tabs: const [
              Tab(
                text: "My Recipes",
              ),
              Tab(
                text: "Saved",
              ),
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
        body: TabBarView(
          children: [
            RecipeEntries(recipesProcessor: widget.recipesProcessor),
            SavedRecipesView(recipesProcessor: widget.recipesProcessor)
          ],
        ),
      ),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipeV2())).then((data) {
      setState(() => {});
      Navigator.of(context).pop();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:groceries/components/additional_pages/page_drawer.dart';
import 'package:groceries/components/view_recipes/recipes_filter_sort.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';
import 'package:groceries/custom_theme.dart';

import '../recipes_edit/create_recipe_v2.dart';

class RecipeEntries extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const RecipeEntries({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  _RecipeEntriesState createState() => _RecipeEntriesState();
}

class _RecipeEntriesState extends State<RecipeEntries> {
  var bodyWidget;
  var checklistEntries;
  var sqlCreate;

  late RecipesProcessor recipesProcessor;
  final theme = CustomTheme();

  @override
  void initState() {
    recipesProcessor = widget.recipesProcessor;
    super.initState();
  }

  /*
   *
   * Load SQL Data
   * 
   */
  void loadEntries() async {
    var entries = await recipesProcessor.loadRecipes();
    if (mounted) {
      setState(() {
        checklistEntries = entries;
      });
    }
  }

  /*
   *
   * Page Entry Point
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FilterSortRecipes(
        recipesProcessor: recipesProcessor,
      )),
      body: bodyBuilder(context),
      endDrawer: PageDrawer(children: <Widget>[
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Import'),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share),
          label: const Text('Share'),
        ),
        TextButton.icon(
            onPressed: () => pushCreateRecipe(context), icon: const Icon(Icons.add), label: const Text('New Recipe')),
      ]),
    );
  }

  /*
   *
   * Page Views
   * 
   */
  Widget bodyBuilder(BuildContext context) {
    loadEntries();
    if (checklistEntries == null) {
      return circularIndicator(context);
    } else if (checklistEntries.length == 0) {
      return emptyWidget(context);
    } else {
      return entriesList(context);
    }
  }

  Widget emptyWidget(BuildContext context) {
    return const Center(
        child: Icon(
      Icons.book,
      size: 100,
    ));
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  /*
   *
   * Recipes ListView
   * 
   */
  Widget entriesList(BuildContext context) {
    return ListView.builder(
      itemCount: checklistEntries.length,
      itemBuilder: (context, index) {
        return groceryTile(index);
      },
    );
  }

  Widget groceryTile(int index) {
    return ListTile(
      title: Text('${checklistEntries[index].recipe}'),
      onTap: () => pushRecipeDetails(context, checklistEntries[index]),
    );
  }

  /*
   *
   * Paths for Different Pages
   * 
   */
  void pushRecipeDetails(BuildContext context, recipeEntry) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetails(recipeEntry: recipeEntry)))
        .then((data) => setState(() => {}));
  }

  pushCreateRecipe(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipeV2())).then((data) {
      setState(() => {});
      Navigator.of(context).pop();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:groceries/components/view_recipes/appbar_recipes.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/components/recipes_edit/create_recipe.dart';
import 'package:groceries/components/view_recipes/recipe_details.dart';
import 'package:groceries/custom_theme.dart';

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
      appBar: RecipesAppBar(height: 56, recipesProcessor: recipesProcessor),
      body: bodyBuilder(context),
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
}

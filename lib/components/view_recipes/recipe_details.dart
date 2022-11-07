import 'package:flutter/material.dart';

import 'package:groceries/components/recipes_edit/edit_recipe_v2.dart';
import 'package:groceries/processors/checklist_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/custom_theme.dart';
import 'package:intl/intl.dart';

class RecipeDetails extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const RecipeDetails({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState(recipeEntry);
}

class _RecipeDetailsState extends State<RecipeDetails> {
  final RecipeEntry recipeEntry;
  _RecipeDetailsState(this.recipeEntry);

  final checklistProcessor = ChecklistProcessor();
  final recipesProcessor = RecipesProcessor();
  final theme = CustomTheme();

  late List<bool> checkedValues;

  @override
  void initState() {
    super.initState();
    checkedValues = List.filled(recipeEntry.ingredients.length, true, growable: false);
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
        title: Text(recipeEntry.recipe),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => pushEditEntry(context),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () =>
                  showDialog<String>(context: context, builder: (BuildContext context) => verifyDeleteRecipe(context)),
            ),
          ),
        ],
      ),
      body: entriesList(context),
      floatingActionButton: addToGroceryList(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void pushEditEntry(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeV2(entryData: recipeEntry))).then((data) {
      setState(() => {});
    });
  }

  /*
   *
   * Recipe Detail ListView
   * 
   */
  Widget entriesList(BuildContext context) {
    return ListView.builder(
        itemCount: recipeEntry.ingredients.length + 1,
        itemBuilder: (context, index) {
          if (index == recipeEntry.ingredients.length) {
            return metaDataDisplay();
          } else if (index == 0) {
            return Column(children: [
              const ListTile(
                  title: Text(
                'Ingredients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
              itemTile(index)
            ]);
          } else {
            return itemTile(index);
          }
        });
  }

  Widget itemTile(int index) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return CheckboxListTile(
        title: Text(recipeEntry.ingredients[index]),
        value: checkedValues[index],
        onChanged: (newValue) {
          setState(() {
            checkedValues[index] = newValue!;
          });
        },
        activeColor: theme.accentHighlightColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    });
  }

  Widget metaDataDisplay() {
    return Column(children: [
      const ListTile(
          title: Text(
        'Instructions',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      )),
      ListTile(title: Text(recipeEntry.instructions)),
      ExpansionTile(
        title: const Text(
          'More',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textColor: theme.accentHighlightColor,
        iconColor: theme.accentHighlightColor,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: moreChildren(),
      ),
      const SizedBox(
        height: 75,
      ),
    ]);
  }

  List<Widget> moreChildren() {
    return <Widget>[
      SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accentColor, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(recipeEntry.category, style: const TextStyle(fontSize: 15)),
          ),
        ),
        width: 100,
        height: 30,
      ),
      const ListTile(
        title: Text("Tags:"),
      ),
      SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accentColor, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(recipeEntry.tags),
          ),
        ),
        width: 50,
        height: 25,
      ),
      ListTile(
        title: Text(
            "Last Updated: ${DateFormat.yMMMMd('en_US').format(DateTime.fromMicrosecondsSinceEpoch(recipeEntry.updatedAt * 1000))}"),
      ),
      ListTile(
        title: Text(
            "Created: ${DateFormat.yMMMMd('en_US').format(DateTime.fromMicrosecondsSinceEpoch(recipeEntry.createdAt * 1000))}"),
      ),
      ListTile(
        title: Text("Times Made: ${recipeEntry.timesMade}"),
      ),
    ];
  }

  /*
   *
   * Add to SQL
   * 
   */
  Widget addToGroceryList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        child: const Text('Save to Grocery List'),
        onPressed: () async {
          for (int i = 0; i < recipeEntry.ingredients.length; i++) {
            if (checkedValues[i]) {
              await checklistProcessor.addEntry(recipeEntry.ingredients[i], recipeEntry.recipe);
            }
          }
          await recipesProcessor.incrementTimesMade(recipeEntry);

          Navigator.of(context).pop();
        },
      ),
    );
  }

  /*
   *
   * Delete Recipe
   * 
   */
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
              recipesProcessor.deleteRecipe(recipeEntry.id);
              setState(() {});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

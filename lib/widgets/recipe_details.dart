import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/types/recipe_entry.dart';

class RecipeDetails extends StatelessWidget {
  List<bool> checkedValues;
  final RecipeEntry recipeEntry;
  RecipeDetails({Key? key, required this.checkedValues, required this.recipeEntry}) : super(key: key);

  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: recipeEntry.ingredients.length + 2,
        itemBuilder: (context, index) {
          if (index == recipeEntry.ingredients.length + 1) {
            return metaDataDisplay();
          } else if (index == 0) {
            return Column(children: const [
              ListTile(
                  title: Text(
                'Ingredients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ]);
          } else {
            if (recipeEntry.ingredients[index - 1].length >= 3 &&
                recipeEntry.ingredients[index - 1].substring(0, 3) == '---') {
              return titleItemTile(index - 1);
            }
            return itemTile(index - 1);
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

  Widget titleItemTile(int index) {
    return ListTile(
      title: Text(
        recipeEntry.ingredients[index].substring(3),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget metaDataDisplay() {
    return Column(children: [
      const ListTile(
          title: Text(
        'Instructions',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      )),
      ListTile(title: Text(recipeEntry.instructions)),
      const SizedBox(
        height: 75,
      ),
    ]);
  }
}

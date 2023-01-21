import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:intl/intl.dart';

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
            return metaDataDisplay(context);
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

  Widget metaDataDisplay(BuildContext context) {
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
        children: moreChildren(context),
      ),
      const SizedBox(
        height: 75,
      ),
    ]);
  }

  List<Widget> moreChildren(BuildContext context) {
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
      tagsListView(context),
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

  Widget tagsListView(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recipeEntry.tags.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(color: theme.accentColor, borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: Text(recipeEntry.tags[index]),
                ),
              ),
              width: recipeEntry.tags[0].length * 8.5,
              height: 25,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }
}

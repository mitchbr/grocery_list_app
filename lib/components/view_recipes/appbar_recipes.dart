import 'package:flutter/material.dart';
import 'package:groceries/components/view_recipes/filters_page.dart';
import 'package:groceries/custom_theme.dart';

import 'package:groceries/processors/recipes_processor.dart';

class RecipesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final RecipesProcessor recipesProcessor;

  final sortOptions = ["Newest Updated", "Oldest Updated", "Newest", "Oldest", "Most Times Made", "Least Times Made"];
  final theme = CustomTheme();

  RecipesAppBar({Key? key, required this.height, required this.recipesProcessor}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).viewPadding.top,
        ),
        Flexible(
          child: DecoratedBox(
            decoration: BoxDecoration(color: theme.secondaryColor),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Text("Recipes", style: TextStyle(fontSize: 20.0, color: theme.textColor)),
                const Spacer(),
                Padding(child: filterDropDown(context), padding: const EdgeInsets.all(2)),
                Padding(child: sortDropDown(context), padding: const EdgeInsets.all(2)),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
        ),
      ],
    );
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
        recipesProcessor.setSort(title);
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
                ))).then((data) => {});
  }
}

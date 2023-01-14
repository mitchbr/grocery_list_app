import 'package:flutter/material.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/widgets/filters_page.dart';

class FilterSort extends StatelessWidget {
  final RecipesProcessor recipesProcessor;
  final Function callback;
  final bool sourceFilterEnabled;
  FilterSort({
    Key? key,
    required this.recipesProcessor,
    required this.callback,
    this.sourceFilterEnabled = true,
  }) : super(key: key);

  final sortOptions = ["Newest Updated", "Oldest Updated", "Newest", "Oldest", "Most Times Made", "Least Times Made"];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(child: filterDropDown(context), padding: const EdgeInsets.all(2)),
        Padding(child: sortDropDown(context), padding: const EdgeInsets.all(2)),
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
        callback();

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
                  sourceFilterEnabled: sourceFilterEnabled,
                ))).then((data) => {callback()});
  }
}

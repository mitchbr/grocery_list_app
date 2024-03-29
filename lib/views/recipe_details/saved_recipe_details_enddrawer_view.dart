import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/widgets/page_drawer.dart';
import 'package:groceries/views/edit_recipe_view.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';
import 'package:intl/intl.dart';

class SavedRecipeDetailsEndDrawerView extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const SavedRecipeDetailsEndDrawerView({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  State<SavedRecipeDetailsEndDrawerView> createState() => _SavedRecipeDetailsEndDrawerViewState();
}

class _SavedRecipeDetailsEndDrawerViewState extends State<SavedRecipeDetailsEndDrawerView> {
  final recipesProcessor = RecipesProcessor();
  final profileProcessor = ProfileProcessor();

  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return PageDrawer(children: <Widget>[
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
      TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => shareRecipeId(context),
          );
        },
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
      TextButton.icon(
        onPressed: () =>
            showDialog<String>(context: context, builder: (BuildContext context) => verifyRemoveRecipe(context)),
        icon: const Icon(Icons.delete_rounded),
        label: const Text('Remove'),
      ),
    ]);
  }

  List<Widget> moreChildren() {
    return <Widget>[
      SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accentColor, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(widget.recipeEntry.category, style: const TextStyle(fontSize: 15)),
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
            child: Text(widget.recipeEntry.tags[0]),
          ),
        ),
        width: 50,
        height: 25,
      ),
      ListTile(
        title: Text(
            "Last Updated: ${DateFormat.yMMMMd('en_US').format(DateTime.fromMicrosecondsSinceEpoch(widget.recipeEntry.updatedAt * 1000))}"),
      ),
      ListTile(
        title: Text(
            "Created: ${DateFormat.yMMMMd('en_US').format(DateTime.fromMicrosecondsSinceEpoch(widget.recipeEntry.createdAt * 1000))}"),
      ),
      ListTile(
        title: Text("Times Made: ${widget.recipeEntry.timesMade}"),
      ),
    ];
  }

  void pushEditEntry(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecipeView(entryData: widget.recipeEntry)))
        .then((data) {
      setState(() => {});
    });
  }

  Widget shareRecipeId(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Recipe'),
      content: Text(widget.recipeEntry.id),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            ClipboardData data = ClipboardData(text: widget.recipeEntry.id);
            await Clipboard.setData(data);
          },
          child: const Icon(Icons.copy),
        ),
      ],
    );
  }

  Widget verifyRemoveRecipe(BuildContext context) {
    return AlertDialog(
        title: const Text('Remove Recipe From Library?'),
        content: const Text('You will no longer be able to view this recipe'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              profileProcessor.removeFromLibrary(widget.recipeEntry.id);
              setState(() {});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

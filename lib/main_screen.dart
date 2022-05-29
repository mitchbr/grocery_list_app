import 'package:flutter/material.dart';

import 'components/checklist_view.dart';
import 'components/recipes_view.dart';

class Groceries extends StatefulWidget {
  const Groceries({Key? key}) : super(key: key);

  @override
  _GroceriesState createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  _GroceriesState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Groceries',
        theme: ThemeData(colorScheme: ColorScheme.dark()),
        home: DefaultTabController(
            length: 2,
            child: Builder(builder: (context) => groceriesScaffold(context))));
  }

  Widget groceriesScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Grocery Checklist"),
          bottom: TabBar(
            tabs: [Tab(text: 'Checklist'), Tab(text: 'Recipes')],
          )),
      body: TabBarView(children: [ChecklistEntries(), RecipeEntries()]),
    );
  }
}

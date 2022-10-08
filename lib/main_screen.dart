import 'package:flutter/material.dart';

import 'package:groceries/components/checklist_view.dart';
import 'package:groceries/components/recipes_view.dart';

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
      theme: ThemeData(colorScheme: const ColorScheme.dark()),
      home: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) => groceriesScaffold(context),
        ),
      ),
    );
  }

  Widget groceriesScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Grocery Checklist"),
          bottom: const TabBar(
            tabs: [Tab(text: 'Checklist'), Tab(text: 'Recipes')],
          )),
      body: const TabBarView(children: [ChecklistEntries(), RecipeEntries()]),
    );
  }
}

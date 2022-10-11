import 'package:flutter/material.dart';
import 'package:groceries/components/checklist/checklist_view.dart';
import 'package:groceries/components/view_recipes/recipes_view.dart';
import 'package:groceries/components/recipes_edit/new_recipe.dart';
import 'package:groceries/custom_theme.dart';

class Groceries extends StatefulWidget {
  const Groceries({Key? key}) : super(key: key);

  @override
  _GroceriesState createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  _GroceriesState();

  final List<Widget> _views = [const ChecklistEntries(), const RecipeEntries(), const NewRecipe()];
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Groceries',
        theme: CustomTheme().customTheme(),
        home: DefaultTabController(
            length: _views.length, child: Builder(builder: (context) => groceriesScaffold(context))));
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget groceriesScaffold(BuildContext context) {
    return Scaffold(
      body: _views.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

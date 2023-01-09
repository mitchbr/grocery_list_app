import 'package:flutter/material.dart';

import 'package:groceries/views/checklist_view.dart';
import 'package:groceries/layouts/authors_layout.dart';
import 'package:groceries/layouts/recipes_layout.dart';

class MainScreenLayout extends StatefulWidget {
  const MainScreenLayout({Key? key}) : super(key: key);

  @override
  State<MainScreenLayout> createState() => _MainScreenLayoutState();
}

class _MainScreenLayoutState extends State<MainScreenLayout> {
  List<Widget> _views = [];
  var selectedIndex = 0;

  @override
  void initState() {
    _views = [const ChecklistEntries(), const RecipesLayout(), const AuthorsLayout()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _views.length, child: Builder(builder: (context) => groceriesScaffold(context)));
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
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Authors',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

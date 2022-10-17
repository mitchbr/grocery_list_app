import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/processors/recipes_processor.dart';

class FiltersPage extends StatefulWidget {
  final RecipesProcessor recipesProcessor;
  const FiltersPage({Key? key, required this.recipesProcessor}) : super(key: key);

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  List<Map> listItems = [];
  List<String> categories = [];
  late String currentCategory;

  @override
  void initState() {
    currentCategory = widget.recipesProcessor.category;
    getCategories().whenComplete(() => null);
    setupListItems();
    super.initState();
  }

  Future<void> getCategories() async {
    var categoriesJson = await rootBundle.loadString('assets/recipe_categories.json');
    categories = jsonDecode(categoriesJson)["categories"].cast<String>();
    setState(() {});
  }

  void setupListItems() {
    // Add categories to the filters list
    listItems.add({"item": categoryDropDown, "type": "Category"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
      ),
      body: filtersList(),
    );
  }

  Widget filtersList() {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return categoryDropDown();
        });
  }

  Widget categoryDropDown() {
    return Column(
      children: [
        const ListTile(title: Text("Category", style: TextStyle(fontSize: 20))),
        ListTile(
          title: DropdownButton(
            value: currentCategory,
            items: categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                currentCategory = value!;
                widget.recipesProcessor.setCategory(value);
              });
            },
          ),
        )
      ],
    );
  }
}

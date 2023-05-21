import 'package:flutter/material.dart';

class RecipeEntry {
  late String author;
  late String id;
  late String recipe;
  late List<dynamic> ingredients;
  late String instructions;
  late String category;
  late List tags;
  late int updatedAt;
  late int createdAt;
  late int timesMade;
  late bool private;
  late bool pinned;

  RecipeEntry(
      {required this.author,
      required this.id,
      required this.recipe,
      required this.ingredients,
      required this.instructions,
      required this.category,
      required this.tags,
      required this.updatedAt,
      required this.createdAt,
      required this.timesMade,
      required this.private,
      required this.pinned});

  IconData iconFromCategory() {
    // TODO: Bring category enums into this class
    final icons = {
      "None": Icons.takeout_dining_outlined,
      "Entree": Icons.takeout_dining_outlined,
      "Baked Good": Icons.bakery_dining_outlined,
      "Breakfast": Icons.local_cafe_outlined,
      "Lunch": Icons.lunch_dining_outlined,
      "Soup": Icons.ramen_dining_outlined,
      "Cocktail": Icons.local_bar_outlined,
      "Dessert": Icons.icecream_outlined,
      "Misc": Icons.local_grocery_store_outlined
    };
    return icons[category]!;
  }
}

import 'package:flutter/material.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'main_screen.dart';

void main() async {
  final recipesProcessor = RecipesProcessor();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Groceries(
    recipesProcessor: recipesProcessor,
  ));
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'main_screen.dart';

void main() async {
  final recipesProcessor = RecipesProcessor();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Groceries(
    recipesProcessor: recipesProcessor,
  ));
}

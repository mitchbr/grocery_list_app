import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final recipesProcessor = RecipesProcessor();
  runApp(Groceries(
    recipesProcessor: recipesProcessor,
  ));
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'main_screen.dart';
import 'package:groceries/custom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final recipesProcessor = RecipesProcessor();
  runApp(
    MaterialApp(
      title: 'Groceries',
      theme: CustomTheme().customTheme(),
      home: const Groceries(),
    ),
  );
}

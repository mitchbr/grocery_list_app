import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Groceries());
}

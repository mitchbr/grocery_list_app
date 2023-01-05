import 'package:flutter/material.dart';

import 'create_recipe.dart';

class NewRecipeOptions extends StatefulWidget {
  const NewRecipeOptions({Key? key}) : super(key: key);

  @override
  State<NewRecipeOptions> createState() => _NewRecipeOptionsState();
}

class _NewRecipeOptionsState extends State<NewRecipeOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Recipe"),
      ),
      body: optionsBody(context),
    );
  }

  Widget optionsBody(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: (() => pushCreateRecipe(context)),
            child: const Text("Create Recipe"),
          ),
        ],
      ),
    );
  }

  pushCreateRecipe(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipe()))
        .then((data) => setState(() => {}));
  }
}

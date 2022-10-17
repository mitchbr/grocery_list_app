import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries/custom_theme.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({Key? key}) : super(key: key);

  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  /*
   *
   * Variable Declaration
   * 
   */
  final formKey = GlobalKey<FormState>();
  final recipeKey = GlobalKey<FormState>();
  final ingredientKey = GlobalKey<FormState>();
  final instructionsKey = GlobalKey<FormState>();

  var entryData = RecipeEntry(
      recipe: '',
      ingredients: [],
      instructions: '',
      category: "",
      tags: "tag",
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      timesMade: 0);
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _recipeNameControl = TextEditingController();
  final TextEditingController _instructionsControl = TextEditingController();
  late List<String> categories;
  var savedRecipe = false;
  var savedInstructions = false;

  final recipesProcessor = RecipesProcessor();
  final theme = CustomTheme();

  @override
  void initState() {
    categories = [];
    getCategories().then((value) {
      entryData.category = categories[0];
    });
    super.initState();
  }

  Future<void> getCategories() async {
    var categoriesJson = await rootBundle.loadString('assets/recipe_categories.json');
    categories = jsonDecode(categoriesJson)["categories"].cast<String>();
    setState(() {
      categories.remove("None");
    });
  }

  /*
   *
   * Page Entry Point
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: formContent(context),
    );
  }

  Widget formContent(BuildContext context) {
    return Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
              itemCount: entryData.ingredients.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(children: [
                    showRecipe(),
                    const ListTile(
                        title: Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                  ]);
                } else if (index == entryData.ingredients.length + 1) {
                  return Column(children: [
                    newEntryBox(context),
                    const ListTile(
                        title: Text(
                      'Instructions',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                    showInstructions(),
                    categoryDropdown(),
                    saveButton(context)
                  ]);
                } else {
                  return ingredientTile(index - 1);
                }
              }),
        ));
  }

// TODO: Let user know when name or instructions aren't valid.
  Widget saveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate() && savedRecipe && savedInstructions) {
              currState.save();
              recipesProcessor.addRecipe(entryData);
              Navigator.of(context).pop();
            }
          }
        },
        child: const Text('Save Recipe'),
      ),
    );
  }

  /*
   *
   * Recipe Name Widgets
   * 
   */
  Widget showRecipe() {
    if (savedRecipe) {
      return recipeTile();
    } else {
      return recipeTextField();
    }
  }

  Widget recipeTile() {
    return ListTile(
        title: Text(entryData.recipe),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() {
            savedRecipe = false;
          }),
        ));
  }

  Widget recipeTextField() {
    return Form(
        key: recipeKey,
        child: ListTile(
          title: TextFormField(
            controller: _recipeNameControl,
            cursorColor: theme.accentHighlightColor,
            decoration: theme.textFormDecoration('Recipe Name'),
            textCapitalization: TextCapitalization.words,
            onSaved: (value) {
              if (value != null) {
                entryData.recipe = value;
              }
            },
            validator: (value) {
              var val = value;
              if (val != null) {
                if (val.isEmpty) {
                  return 'Please enter a recipe title';
                } else {
                  return null;
                }
              }
            },
          ),
          trailing: IconButton(
            onPressed: (() => saveRecipeName()),
            icon: const Icon(Icons.check),
          ),
        ));
  }

  void saveRecipeName() {
    var currState = recipeKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {
          savedRecipe = true;
        });
      }
    }
  }

  /*
   *
   * Ingredient Widgets
   * 
   */
  Widget newEntryBox(BuildContext context) {
    return Form(
        key: ingredientKey,
        child: ListTile(
          title: ingredientTextField(),
          trailing: IconButton(onPressed: (() => saveIngredient()), icon: const Icon(Icons.add)),
        ));
  }

  void saveIngredient() {
    var currState = ingredientKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();

        setState(() {
          _entryController.clear();
        });
      }
    }
  }

  Widget ingredientTextField() {
    return TextFormField(
      controller: _entryController,
      cursorColor: theme.accentHighlightColor,
      decoration: theme.textFormDecoration('New Ingredient'),
      textCapitalization: TextCapitalization.words,
      onSaved: (value) {
        if (value != null) {
          entryData.ingredients.add(value);
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter a value';
          } else {
            return null;
          }
        }
      },
    );
  }

  Widget ingredientTile(int index) {
    return ListTile(
      title: Text('${entryData.ingredients[index]}'),
      trailing: IconButton(onPressed: (() => removeIngredient(index)), icon: const Icon(Icons.close)),
    );
  }

  void removeIngredient(int index) {
    setState(() {
      entryData.ingredients.removeAt(index);
    });
  }

  /*
   *
   * Instructions Widgets
   * 
   */

  Widget showInstructions() {
    if (savedInstructions) {
      return instructionsTile();
    } else {
      return instructionsTextField();
    }
  }

  Widget instructionsTile() {
    return ListTile(
        title: Text(entryData.instructions),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() {
            savedInstructions = false;
          }),
        ));
  }

  Widget instructionsTextField() {
    return Form(
        key: instructionsKey,
        child: ListTile(
          title: TextFormField(
            controller: _instructionsControl,
            cursorColor: theme.accentHighlightColor,
            decoration: theme.textFormDecoration('Instructions'),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onSaved: (value) {
              if (value != null) {
                entryData.instructions = value;
              }
            },
            validator: (value) {
              var val = value;
              if (val != null) {
                if (val.isEmpty) {
                  return 'Please enter instructions';
                } else {
                  return null;
                }
              }
            },
          ),
          trailing: IconButton(onPressed: (() => saveInstructions()), icon: const Icon(Icons.check)),
        ));
  }

  void saveInstructions() {
    var currState = instructionsKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {
          savedInstructions = true;
        });
      }
    }
  }

  /*
   *
   * Category Widgets
   * 
   */
  Widget categoryDropdown() {
    return ListTile(
      title: const Text(
        'Category',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: DropdownButton(
        value: entryData.category,
        items: categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            entryData.category = value!;
          });
        },
      ),
    );
  }
}

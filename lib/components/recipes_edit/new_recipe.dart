import 'package:flutter/material.dart';

import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({Key? key}) : super(key: key);

  @override
  _NewRecipeState createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  /*
   *
   * Variable Declaration
   * 
   */
  final formKey = GlobalKey<FormState>();
  final recipeKey = GlobalKey<FormState>();
  final ingredientKey = GlobalKey<FormState>();
  final instructionsKey = GlobalKey<FormState>();

  var entryData = RecipeEntry(recipe: '', ingredients: [], instructions: '');
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _recipeNameControl = TextEditingController();
  final TextEditingController _instructionsControl = TextEditingController();
  var savedRecipe = false;
  var savedInstructions = false;

  final recipesProcessor = RecipesProcessor();

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
    return TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate() && savedRecipe && savedInstructions) {
              currState.save();
              recipesProcessor.addRecipe(entryData);
            }
          }
        },
        child: const Text('Save Recipe'));
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
            decoration: const InputDecoration(labelText: 'Recipe Name', border: OutlineInputBorder()),
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
      decoration: const InputDecoration(labelText: 'New Ingredient', border: OutlineInputBorder()),
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
            decoration: const InputDecoration(labelText: 'Instructions', border: OutlineInputBorder()),
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
}

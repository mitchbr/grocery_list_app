import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:groceries/types/recipe_entry.dart';
import 'package:groceries/custom_theme.dart';

class RecipeForm extends StatefulWidget {
  final RecipeEntry entryData;
  final Function processorFunction;
  const RecipeForm({Key? key, required this.entryData, required this.processorFunction}) : super(key: key);

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final formKey = GlobalKey<FormState>();
  final recipeKey = GlobalKey<FormState>();
  final ingredientKey = GlobalKey<FormState>();
  final instructionsKey = GlobalKey<FormState>();

  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _recipeNameControl = TextEditingController();
  final TextEditingController _instructionsControl = TextEditingController();
  late List<String> categories;
  late FocusNode ingredientFocusNode;

  final theme = CustomTheme();

  @override
  void initState() {
    ingredientFocusNode = FocusNode();
    categories = [];
    getCategories().then((value) {
      if (widget.entryData.id != 'init') {
        _recipeNameControl.text = widget.entryData.recipe;
        _instructionsControl.text = widget.entryData.instructions;
      } else {
        widget.entryData.category = categories[0];
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    ingredientFocusNode.dispose();

    super.dispose();
  }

  Future<void> getCategories() async {
    var categoriesJson = await rootBundle.loadString('assets/recipe_categories.json');
    categories = jsonDecode(categoriesJson)["categories"].cast<String>();
    setState(() {
      categories.remove("None");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: formColumn(context),
        ));
  }

  Widget formColumn(BuildContext context) {
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            recipeTextField(),
            const ListTile(
                title: Text(
              'Ingredients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            const ListTile(
                title: Text('Hint: Swipe an ingredient to a side to delete it, or hold it down to reorder',
                    style: TextStyle(color: Color(0xFFA4A4A4)))),
            ingredientsListView(context),
            const ListTile(
                title: Text('Hint: Enter three dashes (---) at the front to make a header item',
                    style: TextStyle(color: Color(0xFFA4A4A4)))),
            newEntryBox(context),
            const ListTile(
                title: Text(
              'Instructions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            instructionsTextField(),
            categoryDropdown(),
            saveButton(context),
          ],
        ));
  }

  Widget ingredientsListView(BuildContext context) {
    return ReorderableListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (widget.entryData.ingredients[index].length >= 3 &&
              widget.entryData.ingredients[index].substring(0, 3) == '---') {
            return ingredientSectionTile(index);
          }
          return ingredientTile(index);
        },
        itemCount: widget.entryData.ingredients.length,
        onReorder: (int oldIndex, int newIndex) async {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = widget.entryData.ingredients.removeAt(oldIndex);
          widget.entryData.ingredients.insert(newIndex, item);
          setState(() {});
        });
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
              widget.entryData.recipe = value;
            }
          },
          onFieldSubmitted: (value) => saveRecipeName(),
          validator: (value) {
            var val = value;
            if (val != null) {
              if (val.isEmpty) {
                return 'Please enter a recipe title';
              } else {
                return null;
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  void saveRecipeName() {
    var currState = recipeKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {});
      }
    }
  }

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
          _ingredientController.clear();
          ingredientFocusNode.requestFocus();
        });
      }
    }
  }

  Widget ingredientTextField() {
    return TextFormField(
      controller: _ingredientController,
      cursorColor: theme.accentHighlightColor,
      decoration: theme.textFormDecoration('New Ingredient'),
      textCapitalization: TextCapitalization.words,
      focusNode: ingredientFocusNode,
      onFieldSubmitted: (value) {
        if (value != "") {
          saveIngredient();
        }
      },
      onSaved: (value) {
        if (value != null) {
          widget.entryData.ingredients.add(value);
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
        return null;
      },
    );
  }

  Widget ingredientTile(int index) {
    return Dismissible(
      key: Key('$index+${widget.entryData.ingredients[index]}'),
      onDismissed: ((direction) {
        widget.entryData.ingredients.removeAt(index);
        setState(() {});
      }),
      child: ListTile(
        title: Text('${widget.entryData.ingredients[index]}'),
      ),
    );
  }

  Widget ingredientSectionTile(int index) {
    return Dismissible(
      key: Key('$index+${widget.entryData.ingredients[index]}'),
      onDismissed: ((direction) {
        widget.entryData.ingredients.removeAt(index);
        setState(() {});
      }),
      child: ListTile(
        title: Text(
          '${widget.entryData.ingredients[index].substring(3)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
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
              widget.entryData.instructions = value;
            }
          },
          onFieldSubmitted: (value) => saveInstructions(),
          validator: (value) {
            var val = value;
            if (val != null) {
              if (val.isEmpty) {
                return 'Please enter instructions';
              } else {
                return null;
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  void saveInstructions() {
    var currState = instructionsKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {});
      }
    }
  }

  Widget categoryDropdown() {
    return ListTile(
      title: const Text(
        'Category',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: DropdownButton(
        value: widget.entryData.category,
        items: categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            widget.entryData.category = value!;
          });
        },
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: () async {
          saveRecipeName();
          saveInstructions();
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();
              widget.processorFunction(widget.entryData);
              if (widget.entryData.id != 'init') {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
          }
        },
        child: const Text('Save Recipe'),
      ),
    );
  }
}

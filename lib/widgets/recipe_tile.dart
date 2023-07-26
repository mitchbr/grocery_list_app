import 'package:flutter/material.dart';

import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/types/recipe_entry.dart';

class RecipeTile extends StatefulWidget {
  final RecipeEntry recipe;
  final Function onTap;
  const RecipeTile({Key? key, required this.recipe, required this.onTap}) : super(key: key);

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  String username = '';
  Icon pinnedIcon = const Icon(Icons.push_pin_outlined);

  final recipesProcessor = RecipesProcessor();
  final profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  @override
  void initState() {
    profileProcessor.getUsername().then((value) {
      setState(() {
        username = value;
      });
    });

    profileProcessor.fetchPinnedRecipes().then((value) {
      setState(() {
        if (value.contains(widget.recipe.id)) {
          pinnedIcon = const Icon(Icons.push_pin);
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onTap(),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                  color: theme.secondaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.recipe,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 5),
                        Text(
                          widget.recipe.author == username ? "You" : widget.recipe.author,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          widget.recipe.private == true ? "Private" : "",
                          style: const TextStyle(fontSize: 14),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: theme.accentColor,
                  border: Border.all(color: theme.secondaryColor, width: 2),
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(widget.recipe.iconFromCategory()),
                    const SizedBox(width: 5),
                    Text(widget.recipe.category),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        if (!widget.recipe.pinned) {
                          await profileProcessor.addPinnedRecipe(widget.recipe.id);
                        } else {
                          await profileProcessor.removePinnedRecipe(widget.recipe.id);
                        }
                        setState(() {
                          widget.recipe.pinned = !widget.recipe.pinned;
                        });
                      },
                      icon: widget.recipe.pinned ? const Icon(Icons.push_pin) : const Icon(Icons.push_pin_outlined),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/views/followed_author_recipes_view.dart';

class FollowedAuthorsRecipesLayout extends StatefulWidget {
  final String userId;
  const FollowedAuthorsRecipesLayout({Key? key, required this.userId}) : super(key: key);

  @override
  State<FollowedAuthorsRecipesLayout> createState() => _FollowedAuthorsRecipesLayoutState();
}

class _FollowedAuthorsRecipesLayoutState extends State<FollowedAuthorsRecipesLayout> {
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final RecipesProcessor recipesProcessor = RecipesProcessor();
  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.userId}'s Recipes"),
          actions: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => _removeAuthorFollowPopup(context),
              ),
              icon: const Icon(Icons.remove),
            ),
          ],
        ),
        body: FollowedAuthorRecipesView(
          userId: widget.userId,
          recipesProcessor: recipesProcessor,
        ));
  }

  Widget _removeAuthorFollowPopup(BuildContext context) {
    return AlertDialog(
        title: const Text('Stop Following?'),
        content: const Text('This author can be followed again later'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              profileProcessor.removeFollowedAuthor(widget.userId);
              setState(() {});
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

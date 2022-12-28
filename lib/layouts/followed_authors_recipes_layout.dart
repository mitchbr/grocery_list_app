import 'package:flutter/material.dart';
import 'package:groceries/components/additional_pages/page_drawer.dart';
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
  final theme = CustomTheme();

  final TextEditingController _removeAuthorFollowTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Authors')),
        endDrawer: PageDrawer(children: <Widget>[
          TextButton.icon(
              onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => _removeAuthorFollowPopup(context),
                  ),
              icon: const Icon(Icons.remove),
              label: const Text('Stop Following')),
        ]),
        body: FollowedAuthorRecipesView(userId: widget.userId));
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
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ]);
  }
}

import 'package:flutter/material.dart';

import 'package:groceries/widgets/page_drawer.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/views/authors_view.dart';

class AuthorsLayout extends StatefulWidget {
  const AuthorsLayout({Key? key}) : super(key: key);

  @override
  State<AuthorsLayout> createState() => _AuthorsLayoutState();
}

class _AuthorsLayoutState extends State<AuthorsLayout> {
  final ProfileProcessor profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  final TextEditingController _addAuthorFollowTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Authors')),
        endDrawer: PageDrawer(children: <Widget>[
          TextButton.icon(
              onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => _addAuthorFollowPopup(),
                  ),
              icon: const Icon(Icons.add),
              label: const Text('Follow User')),
        ]),
        body: const AuthorsView());
  }

  Widget _addAuthorFollowPopup() {
    return AlertDialog(
      title: const Text('Follow User'),
      content: TextField(
        controller: _addAuthorFollowTextController,
        decoration: theme.textFormDecoration('Enter Username'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            profileProcessor.addFollowedAuthor(_addAuthorFollowTextController.text);
            Navigator.of(context).pop();
            _addAuthorFollowTextController.clear();
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

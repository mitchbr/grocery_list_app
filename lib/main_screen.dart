import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';

import 'package:groceries/layouts/main_screen_layout.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/processors/recipes_processor.dart';
import 'package:groceries/widgets/profile_widgets.dart';

class Groceries extends StatefulWidget {
  const Groceries({Key? key}) : super(key: key);

  @override
  _GroceriesState createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  _GroceriesState();

  final theme = CustomTheme();

  Future getUsername = ProfileProcessor().checkUserExists();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUsername,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == false) {
            return bodyWidget(signIn());
          } else {
            return const MainScreenLayout();
          }
        } else if (snapshot.hasError) {
          return bodyWidget(loadingError());
        } else {
          return bodyWidget(circularIndicator(context));
        }
      },
    );
  }

  Widget bodyWidget(Widget child) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groceries")),
      body: child,
    );
  }

  Widget signIn() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Center(
          child: Text(
            "If you do not already have a profile, please reach out to Mitchell to have one made",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
        const ProfileWidgets(),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: (() async {
            var userExists = await ProfileProcessor().checkUserExists();
            if (userExists) {
              setState(() {
                getUsername = ProfileProcessor().checkUserExists();
              });
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) => showUserDoesNotExistDialog(),
              );
            }
          }),
          child: const Text("Sign In"),
        )
      ],
    );
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  Widget loadingError() {
    return Center(
        child: Column(
      children: [
        const Text(
          "There was an error loading data, please try again",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        IconButton(
            onPressed: (() async {
              setState(() {
                getUsername = ProfileProcessor().checkUserExists();
              });
            }),
            icon: const Icon(Icons.refresh))
      ],
    ));
  }

  Widget showUserDoesNotExistDialog() {
    return AlertDialog(
      title: const Text('User does not exist'),
      content: const Text("Please provide an existing username"),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text("Ok"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';

import 'package:groceries/layouts/main_screen_layout.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/widgets/profile_widgets.dart';

class Groceries extends StatefulWidget {
  const Groceries({Key? key}) : super(key: key);

  @override
  _GroceriesState createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  _GroceriesState();
  final theme = CustomTheme();
  bool signedIn = false;
  Future<bool> getUsername = ProfileProcessor().checkUserExists();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUsername,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (!snapshot.data) {
            return ProfileWidgets(callback: callback);
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

  void callback(BuildContext context) {
    setState(() {
      signedIn = true;
    });
  }
}

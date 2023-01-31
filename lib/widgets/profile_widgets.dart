import 'package:flutter/material.dart';

import 'package:groceries/custom_theme.dart';
import 'package:groceries/processors/profile_processor.dart';

class ProfileWidgets extends StatefulWidget {
  final Function callback;
  const ProfileWidgets({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  State<ProfileWidgets> createState() => _ProfileWidgetsState();
}

class _ProfileWidgetsState extends State<ProfileWidgets> {
  final profileKey = GlobalKey<FormState>();
  final TextEditingController _profileController = TextEditingController();
  late String username;

  final theme = CustomTheme();
  final processor = ProfileProcessor();

  Future getUsername = ProfileProcessor().checkUserExists();

  @override
  void initState() {
    username = 'no_username_set';
    processor.getUsername().then((value) {
      if (value != 'no_username_set') {
        _profileController.text = value;
        setState(() => username = value);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUsername,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return bodyWidget(signIn());
        } else if (snapshot.hasError) {
          return bodyWidget(loadingError());
        } else {
          return bodyWidget(circularIndicator(context));
        }
      },
    );
  }

  profileTextField() {
    return Form(
        key: profileKey,
        child: ListTile(
          title: TextFormField(
            controller: _profileController,
            cursorColor: theme.accentHighlightColor,
            decoration: theme.textFormDecoration('Username'),
            validator: (value) {
              var val = value;
              if (val != null) {
                if (val.isEmpty) {
                  return 'Please enter username';
                } else {
                  return null;
                }
              }
              return null;
            },
          ),
        ));
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
        profileTextField(),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: (() async {
            await processor.setUsername(_profileController.text);
            var userExists = await processor.checkUserExists();
            if (userExists) {
              saveUsername();
              setState(() {
                getUsername = processor.checkUserExists();
                widget.callback(context);
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
                getUsername = processor.checkUserExists();
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

  saveUsername() {
    var currState = profileKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        processor.setUsername(_profileController.text);
        setState(() {});
      }
    }
  }
}

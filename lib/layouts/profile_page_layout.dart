import 'package:flutter/material.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/widgets/profile_widgets.dart';

class ProfilePageLayout extends StatelessWidget {
  ProfilePageLayout({Key? key}) : super(key: key);

  final TextEditingController _showSignedInTextController = TextEditingController();
  final theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return ProfileWidgets(
      callback: callback,
    );
  }

  void callback(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _addAuthorFollowPopup(context),
    );
  }

  Widget _addAuthorFollowPopup(BuildContext context) {
    return AlertDialog(
      title: const Text('Successfully Signed In'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _showSignedInTextController.clear();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

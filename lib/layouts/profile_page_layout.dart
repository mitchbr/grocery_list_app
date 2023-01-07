import 'package:flutter/material.dart';
import 'package:groceries/widgets/profile_widgets.dart';

class ProfilePageLayout extends StatelessWidget {
  const ProfilePageLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: const ProfileWidgets(),
    );
  }
}

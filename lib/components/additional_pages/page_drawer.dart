import 'package:flutter/material.dart';
import 'package:groceries/components/additional_pages/profile_page.dart';

class PageDrawer extends StatelessWidget {
  final List<Widget> children;
  const PageDrawer({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add space between buttons
    for (int i = 0; i < children.length; i += 2) {
      children.insert(
          i,
          const SizedBox(
            height: 5,
          ));
    }

    return Drawer(
      child: ListView(children: [
        TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            icon: const Icon(Icons.person),
            label: const Text("Profile")),
        ...children
      ]),
    );
  }
}

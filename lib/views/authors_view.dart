import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:groceries/layouts/followed_authors_recipes_layout.dart';
import 'package:groceries/widgets/firestore_list.dart';

class AuthorsView extends StatefulWidget {
  const AuthorsView({Key? key}) : super(key: key);

  @override
  State<AuthorsView> createState() => _AuthorsViewState();
}

class _AuthorsViewState extends State<AuthorsView> {
  final Stream<QuerySnapshot> _authorsStream = FirebaseFirestore.instance.collection('authors').snapshots();

  @override
  Widget build(BuildContext context) {
    return FirestoreList(
      stream: _authorsStream,
      dataProcessor: dataProcessor,
      listTile: authorTile,
      asyncProcessor: false,
    );
  }

  List<dynamic> dataProcessor(snapshot, username) {
    return snapshot.data!.docs.where((element) => element.id == username).toList()[0]['authors_following'];
  }

  void pushAuthorRecipes(BuildContext context, username) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowedAuthorsRecipesLayout(userId: username)))
        .then((data) => setState(() => {}));
  }

  Widget authorTile(var item) {
    return ListTile(
      title: Text(item),
      onTap: () => pushAuthorRecipes(context, item),
    );
  }
}

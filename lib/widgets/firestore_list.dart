import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/custom_theme.dart';

class FirestoreList extends StatefulWidget {
  Stream<QuerySnapshot> stream;
  final Function dataProcessor;
  final Function listTile;
  bool scroll;
  FirestoreList(
      {Key? key, required this.stream, required this.dataProcessor, required this.listTile, this.scroll = true})
      : super(key: key);

  @override
  _FirestoreListState createState() => _FirestoreListState();
}

class _FirestoreListState extends State<FirestoreList> {
  List listData = [false];
  String username = 'initial_username';

  ProfileProcessor profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  @override
  void initState() {
    setState(() {
      profileProcessor.getUsername().then((value) => username = value);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return errorIndicator(context);
        }

        if (snapshot.connectionState == ConnectionState.waiting || username == 'initial_username') {
          return circularIndicator(context);
        }

        listData = widget.dataProcessor(snapshot, username);

        if (listData.isEmpty) {
          return emptyWidget(context);
        }

        return entriesList(context);
      },
    );
  }

  Widget emptyWidget(BuildContext context) {
    return const Center(
        child: Icon(
      Icons.book,
      size: 100,
    ));
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  Widget errorIndicator(BuildContext context) {
    return const Center(child: Text("Error loading data"));
  }

  Widget entriesList(BuildContext context) {
    return ListView.builder(
      // TODO: These need to be in only the followed_authors_recipe_view
      shrinkWrap: !widget.scroll,
      physics: (widget.scroll) ? null : const NeverScrollableScrollPhysics(),
      itemCount: listData.length,
      itemBuilder: (context, index) {
        return widget.listTile(listData[index]);
      },
    );
  }
}

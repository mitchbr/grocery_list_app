import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:groceries/processors/checklist_processor.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/custom_theme.dart';
import 'package:groceries/components/additional_pages/page_drawer.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistEntries extends StatefulWidget {
  const ChecklistEntries({Key? key}) : super(key: key);

  @override
  _ChecklistEntriesState createState() => _ChecklistEntriesState();
}

class _ChecklistEntriesState extends State<ChecklistEntries> {
  var checklistEntries;
  var prevDeleted;
  String username = 'initial_username';

  final Stream<QuerySnapshot> _checklistStream = FirebaseFirestore.instance.collection('authors').snapshots();

  final checklistProcessor = ChecklistProcessor();
  final profileProcessor = ProfileProcessor();
  final theme = CustomTheme();

  final formKey = GlobalKey<FormState>();
  var entryData = GroceryEntry(title: '', checked: 0);
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _checklistFromTextController = TextEditingController();

  @override
  void initState() {
    setState(() {
      profileProcessor.getUsername().then((value) => username = value);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
      ),
      endDrawer: PageDrawer(
        children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              checklistProcessor.shareByText(checklistEntries);
              showDialog(
                context: context,
                builder: (BuildContext context) => fromTextPopupDialog(),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Import'),
          ),
          TextButton.icon(
            onPressed: () async {
              var checklistString = checklistProcessor.shareByText(checklistEntries);
              showDialog(
                context: context,
                builder: (BuildContext context) => toTextPopupDialog(checklistString),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
      body: bodyBuilder(context),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [undoButton(), clearCheckedButton()],
      ),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _checklistStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return errorIndicator(context);
          }

          if (snapshot.connectionState == ConnectionState.waiting || username == 'initial_username') {
            return circularIndicator(context);
          }

          checklistEntries = checklistProcessor
              .processEntries(snapshot.data!.docs.where((element) => element.id == username).toList()[0]['checklist']);

          return entriesList(context);
        });
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  Widget errorIndicator(BuildContext context) {
    return const Center(child: Text("Error loading checklist"));
  }

  Widget entriesList(BuildContext context) {
    return ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        itemCount: checklistEntries.length + 1,
        itemBuilder: (context, index) {
          if (index == checklistEntries.length) {
            return Column(key: Key('$index'), children: [
              newEntryBox(context),
              const ListTile(
                  title: SizedBox(
                height: 20,
              ))
            ]);
          } else {
            return groceryTile(index);
          }
        },
        onReorder: (int oldIndex, int newIndex) async {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = checklistEntries.removeAt(oldIndex);
          checklistEntries.insert(newIndex, item);
          await checklistProcessor.updateChecklist(checklistEntries);
          setState(() {});
        });
  }

  Widget groceryTile(int index) {
    return Dismissible(
      key: Key('${checklistEntries[index]}+${checklistEntries[index].title}'),
      onDismissed: (direction) async {
        prevDeleted = checklistEntries[index];
        checklistEntries.removeAt(index);
        await checklistProcessor.updateChecklist(checklistEntries);

        setState(() {});
      },
      child: ListTile(
        title: Transform.translate(
          offset: const Offset(-40, 0),
          child: CheckboxListTile(
            title: Text(checklistEntries[index].title),
            value: checklistEntries[index].checked == 0 ? false : true,
            onChanged: (newValue) async {
              // Swap checked value
              checklistEntries[index].checked = newValue! ? 1 : 0;

              // Move item to bottom/top for check/uncheck action respectively
              final item = checklistEntries.removeAt(index);
              int newIndex = newValue ? checklistEntries.length : 0;
              checklistEntries.insert(newIndex, item);

              await checklistProcessor.updateChecklist(checklistEntries);

              setState(() {});
            },
            activeColor: theme.accentHighlightColor,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ),
    );
  }

  Widget newEntryBox(BuildContext context) {
    return Form(
        key: formKey,
        child: ListTile(
          title: itemTextField(),
          trailing: IconButton(onPressed: (() => saveEntryItem()), icon: const Icon(Icons.add)),
        ));
  }

  Widget itemTextField() {
    return TextFormField(
      controller: _entryController,
      cursorColor: theme.accentHighlightColor,
      decoration: theme.textFormDecoration('New Item'),
      textCapitalization: TextCapitalization.sentences,
      onSaved: (value) {
        if (value != null) {
          entryData.title = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter a value';
          } else {
            return null;
          }
        }
        return null;
      },
    );
  }

  void saveEntryItem() async {
    var currState = formKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        GroceryEntry newEntry = checklistProcessor.processEntry({'title': entryData.title, 'checked': 0});
        checklistEntries.add(newEntry);
        await checklistProcessor.updateChecklist(checklistEntries);

        setState(() {
          _entryController.clear();
          prevDeleted = null;
        });
      }
    }
  }

  Widget undoButton() {
    return Visibility(
        visible: (prevDeleted != null),
        child: ElevatedButton.icon(
            onPressed: (() async {
              checklistEntries.add(prevDeleted);
              await checklistProcessor.updateChecklist(checklistEntries);
              prevDeleted = null;
              setState(() {});
            }),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(theme.accentHighlightColor),
            )));
  }

  Widget clearCheckedButton() {
    return Visibility(
      visible: checklistProcessor.getNumChecked() > 0,
      child: ElevatedButton.icon(
          onPressed: () async {
            checklistEntries = checklistProcessor.deleteChecked(checklistEntries);
            await checklistProcessor.updateChecklist(checklistEntries);
            prevDeleted = null;
            setState(() {});
          },
          icon: const Icon(Icons.close),
          label: const Text("Clear Checked"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(theme.accentHighlightColor),
          )),
    );
  }

  Widget toTextPopupDialog(checklist) {
    return AlertDialog(
      title: const Text('Share Checklist'),
      content: Text(checklist),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            ClipboardData data = ClipboardData(text: checklist);
            await Clipboard.setData(data);
          },
          child: const Icon(Icons.copy),
        ),
      ],
    );
  }

  Widget fromTextPopupDialog() {
    return AlertDialog(
      title: const Text('Import Items'),
      content: TextField(
        controller: _checklistFromTextController,
        decoration: theme.textFormDecoration('Enter Items'),
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: 100,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            checklistEntries = checklistProcessor.addTextToList(_checklistFromTextController.text, checklistEntries);
            await checklistProcessor.updateChecklist(checklistEntries);
            Navigator.of(context).pop();
            _checklistFromTextController.clear();
          },
          child: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }
}

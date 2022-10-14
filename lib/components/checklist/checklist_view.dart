import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:groceries/processors/checklist_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/custom_theme.dart';

class ChecklistEntries extends StatefulWidget {
  const ChecklistEntries({Key? key}) : super(key: key);

  @override
  _ChecklistEntriesState createState() => _ChecklistEntriesState();
}

class _ChecklistEntriesState extends State<ChecklistEntries> {
  var checklistEntries;
  var prevDeleted;

  final processor = ChecklistProcessor();
  final theme = CustomTheme();

  final formKey = GlobalKey<FormState>();
  var entryData = GroceryEntry(item: '');
  final TextEditingController _entryController = TextEditingController();
  late List<bool> checkedValues;

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  /*
   *
   * Load SQL data
   *
   */
  void loadEntries() async {
    if (mounted) {
      var entries = await processor.loadEntries();
      setState(() {
        checklistEntries = entries;
        checkedValues = List.filled(checklistEntries.length, false, growable: true);
      });
    }
  }

  /*
   *
   * Page Entry Point
   * 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checklist"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              var checklistString = await processor.shareByText();
              showDialog(
                context: context,
                builder: (BuildContext context) => buildPopupDialog(checklistString),
              );
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: bodyBuilder(context),
      floatingActionButton: undoButton(),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    if (checklistEntries == null) {
      return circularIndicator(context);
    } else {
      return entriesList(context);
    }
  }

  Widget circularIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: theme.accentHighlightColor,
    ));
  }

  /*
   *
   * Entry List Widgets
   * 
   */
  Widget entriesList(BuildContext context) {
    return ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = checklistEntries.removeAt(oldIndex);
            checklistEntries.insert(newIndex, item);
          });
        });
  }

  Widget groceryTile(int index) {
    return ListTile(
      key: Key('$index'),
      leading: const Icon(Icons.reorder_rounded),
      trailing: checkedValues[index] == true
          ? IconButton(
              onPressed: () async {
                prevDeleted = await processor.deleteEntry(checklistEntries[index].item);
                setState(() {
                  loadEntries();
                });
              },
              icon: const Icon(Icons.close))
          : null,
      title: Transform.translate(
        offset: const Offset(-40, 0),
        child: CheckboxListTile(
          title: Text(checklistEntries[index].item),
          value: checkedValues[index],
          onChanged: (newValue) {
            setState(() {
              checkedValues[index] = newValue!;
            });
          },
          activeColor: theme.accentHighlightColor,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }

  /*
   *
   * Add New Entries
   * 
   */
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
          entryData.item = value;
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
      },
    );
  }

  void saveEntryItem() async {
    var currState = formKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        processor.addEntry(entryData.item);

        setState(() {
          loadEntries();
          _entryController.clear();
          prevDeleted = null;
        });
      }
    }
  }

  /*
   *
   * Undo
   * 
   */
  Widget undoButton() {
    return Visibility(
        visible: (prevDeleted != null),
        child: ElevatedButton.icon(
            onPressed: (() => setState(() {
                  processor.addEntry(prevDeleted);
                  prevDeleted = null;
                  loadEntries();
                })),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(theme.accentHighlightColor),
            )));
  }

  /*
   *
   * Share checklist text
   * 
   */
  Widget buildPopupDialog(checklist) {
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
}

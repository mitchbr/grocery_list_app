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
  var entryData = GroceryEntry(id: 0, listIndex: -1, title: '', checked: 0, source: 'Checklist');
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _checklistFromTextController = TextEditingController();

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
                builder: (BuildContext context) => fromTextPopupDialog(),
              );
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            onPressed: () async {
              var checklistString = await processor.shareByText();
              showDialog(
                context: context,
                builder: (BuildContext context) => toTextPopupDialog(checklistString),
              );
            },
            icon: const Icon(Icons.share),
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
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            // TODO: Move logic to processor
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = checklistEntries.removeAt(oldIndex);
            checklistEntries.insert(newIndex, item);
            processor.updateIndexes(checklistEntries);
          });
        });
  }

  Widget groceryTile(int index) {
    return ListTile(
      key: Key('$index'),
      leading: const Icon(Icons.reorder_rounded),
      trailing: checklistEntries[index].checked == 1
          ? IconButton(
              onPressed: () async {
                prevDeleted = await processor.deleteEntry(checklistEntries[index].title);
                setState(() {
                  loadEntries();
                });
              },
              icon: const Icon(Icons.close))
          : null,
      title: Transform.translate(
        offset: const Offset(-40, 0),
        child: CheckboxListTile(
          title: Text(checklistEntries[index].title),
          value: checklistEntries[index].checked == 0 ? false : true,
          onChanged: (newValue) async {
            checklistEntries[index].checked = newValue! ? 1 : 0;
            await processor.updateChecked(checklistEntries[index].id, checklistEntries[index].checked);

            // TODO: Move reorder to processor
            final item = checklistEntries.removeAt(index);
            int newIndex = newValue ? checklistEntries.length : 0;
            checklistEntries.insert(newIndex, item);
            processor.updateIndexes(checklistEntries);

            setState(() {});
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
        processor.addEntry(entryData.title, "checklist");

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
   * FloatinActionButtons
   * 
   */
  Widget undoButton() {
    return Visibility(
        visible: (prevDeleted != null),
        child: ElevatedButton.icon(
            onPressed: (() => setState(() {
                  processor.addEntry(prevDeleted, "undo");
                  prevDeleted = null;
                  loadEntries();
                })),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(theme.accentHighlightColor),
            )));
  }

  Widget clearCheckedButton() {
    return Visibility(
      visible: processor.getNumChecked() > 0,
      child: ElevatedButton.icon(
          onPressed: () async {
            await processor.deleteChecked();
            prevDeleted = null;
            setState(() {
              loadEntries();
            });
          },
          icon: const Icon(Icons.close),
          label: const Text("Clear Checked"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(theme.accentHighlightColor),
          )),
    );
  }

  /*
   *
   * Share checklist text
   * 
   */
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
            await processor.addTextToList(_checklistFromTextController.text);
            loadEntries();
            Navigator.of(context).pop();
            _checklistFromTextController.clear();
          },
          child: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }
}

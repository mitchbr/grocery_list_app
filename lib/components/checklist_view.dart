import 'package:flutter/material.dart';
import 'grocery_entry.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class ChecklistEntries extends StatefulWidget {
  @override
  _ChecklistEntriesState createState() => _ChecklistEntriesState();
}

class _ChecklistEntriesState extends State<ChecklistEntries> {
  var bodyWidget;
  var checklistEntries;
  var sqlCreate;
  var prevDeleted = null;

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

  void loadSqlStartup() async {
    sqlCreate = await rootBundle.loadString('assets/grocery.txt');
  }

  void loadEntries() async {
    loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });
    List<Map> entries = await db.rawQuery('SELECT * FROM grocery_checklist');
    final entriesList = entries.map((record) {
      return GroceryEntry(
        item: record['item'],
      );
    }).toList();
    if (mounted) {
      setState(() {
        checklistEntries = entriesList;
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
    return const Center(child: CircularProgressIndicator());
  }

  /*
   *
   * Entry List Widgets
   * 
   */
  //TODO: Get ReorderableListView working
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
            print('$oldIndex, $newIndex');
          });
        });
  }

  Widget groceryTile(int index) {
    return ListTile(
      key: Key('$index'),
      leading: const Icon(Icons.reorder_rounded),
      trailing: IconButton(onPressed: () => delete(checklistEntries[index].item), icon: const Icon(Icons.close)),
      title: Transform.translate(
        offset: const Offset(-40, 0),
        child: CheckboxListTile(
          title: Text('${checklistEntries[index].item}'),
          value: checkedValues[index],
          onChanged: (newValue) {
            setState(() {
              checkedValues[index] = newValue!;
            });
          },
          activeColor: Colors.teal,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }

  /*
   *
   * Delete Entries
   * 
   */
  void delete(String title) async {
    // TODO: Use delete without removing both duplicates
    prevDeleted = title;
    loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM grocery_checklist WHERE item = ?', [title]);
    });

    setState(() {
      loadEntries();
    });
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
      autofocus: true,
      decoration: const InputDecoration(labelText: 'New Item', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
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
        var sqlCreate = await rootBundle.loadString('assets/grocery.txt');
        var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
          await db.execute(sqlCreate);
        });

        await db.transaction((txn) async {
          await txn.rawInsert('INSERT INTO grocery_checklist(item) VALUES(?)', [entryData.item]);
        });

        await db.close();

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
            onPressed: (() => insertUndo()), icon: const Icon(Icons.undo), label: const Text('Undo')));
  }

  void insertUndo() async {
    var sqlCreate = await rootBundle.loadString('assets/grocery.txt');
    var db = await openDatabase('grocery.db', version: 1, onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });

    await db.transaction((txn) async {
      await txn.rawInsert('INSERT INTO grocery_checklist(item) VALUES(?)', [prevDeleted]);
    });

    await db.close();

    setState(() {
      prevDeleted = null;
    });
  }
}

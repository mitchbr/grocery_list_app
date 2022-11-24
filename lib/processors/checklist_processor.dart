import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/database/checklist_database.dart';
import 'package:groceries/database/checklist_firestore_database.dart';
import 'dart:math';

class ChecklistProcessor {
  ChecklistDatabase database = ChecklistDatabase();
  ChecklistFirestoreDatabase firestoreDatabase = ChecklistFirestoreDatabase();
  ProfileProcessor profileProcessor = ProfileProcessor();

  int listLength = 0;
  int numChecked = 0;

  Future<List<GroceryEntry>> loadEntries() async {
    String username = await profileProcessor.getUsername() ?? '';
    List<Map> entries = await firestoreDatabase.getItems(username);
    // List<Map> entries = await database.loadItems();
    List<GroceryEntry> entriesList = entries.map((record) {
      return GroceryEntry(
          id: record['id'],
          uuid: record['uuid'],
          listIndex: record['list_index'],
          title: record['title'],
          checked: record['checked'],
          source: record['source'],
          author: record['author']);
    }).toList();
    listLength = entriesList.length;
    for (var entry in entriesList) {
      numChecked += entry.checked;
    }
    entriesList.sort((a, b) => a.listIndex.compareTo(b.listIndex));
    return entriesList;
  }

  Future<String> deleteEntry(title, uuid) async {
    await database.deleteItem(title);
    await firestoreDatabase.deleteItem(uuid);
    listLength -= 1;
    return title;
  }

  Future<void> addEntry(title, source) async {
    await database.addItem(listLength, title, source);
    Random random = Random();
    var username = await profileProcessor.getUsername() ?? '';
    final newEntry = {
      'list_index': listLength,
      'title': title,
      'checked': 0,
      'source': source,
      'author': username,
      'id': random.nextInt(10000)
    };
    await firestoreDatabase.addItem(newEntry);
    listLength += 1;
  }

  Future<String> shareByText() async {
    // TODO: Update this
    List<Map> entries = await database.loadItems();
    String entriesString = 'Checklist:\n';
    for (var entry in entries) {
      entriesString += "- ${entry['title']}\n";
    }

    return entriesString;
  }

  Future<void> addTextToList(text) async {
    // TODO: Update this
    for (var item in text.split("\n")) {
      if (item.startsWith("- ")) {
        await database.addItem(listLength, item.replaceAll("- ", ""), "sharing");
        listLength += 1;
      }
    }
  }

  Future<void> updateChecked(id, uuid, checked) async {
    // TODO: Reorder based on check/uncheck
    // TODO: Update this
    await database.updateItem(id, checked: checked);
    await firestoreDatabase.updateItem(uuid, checked: checked);
    numChecked += (checked == 1) ? 1 : -1;
  }

  Future<void> updateIndexes(entriesList) async {
    // TODO: Batch update
    for (int i = 0; i < entriesList.length; i++) {
      await database.updateItem(entriesList[i].id, listIndex: i);
      await firestoreDatabase.updateItem(entriesList[i].uuid, listIndex: i);
    }
  }

  Future<void> deleteChecked(entries) async {
    await database.deleteChecked();
    await firestoreDatabase.deleteChecked(entries);
    numChecked = 0;
  }

  int getNumChecked() {
    return numChecked;
  }
}

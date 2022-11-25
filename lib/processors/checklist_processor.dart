import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/database/checklist_database.dart';
import 'package:groceries/database/checklist_firestore_database.dart';

class ChecklistProcessor {
  ChecklistDatabase database = ChecklistDatabase();
  ChecklistFirestoreDatabase firestoreDatabase = ChecklistFirestoreDatabase();
  int listLength = 0;
  int numChecked = 0;

  Future<List<GroceryEntry>> loadEntries() async {
    List<Map> entries = await firestoreDatabase.getItems('mitch');
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

  Future<String> deleteEntry(title) async {
    await database.deleteItem(title);
    listLength -= 1;
    return title;
  }

  Future<void> addEntry(title, source) async {
    await database.addItem(listLength, title, source);
    listLength += 1;
  }

  Future<String> shareByText() async {
    List<Map> entries = await database.loadItems();
    String entriesString = 'Checklist:\n';
    for (var entry in entries) {
      entriesString += "- ${entry['title']}\n";
    }

    return entriesString;
  }

  Future<void> addTextToList(text) async {
    for (var item in text.split("\n")) {
      if (item.startsWith("- ")) {
        await database.addItem(listLength, item.replaceAll("- ", ""), "sharing");
        listLength += 1;
      }
    }
  }

  Future<void> updateChecked(id, checked) async {
    // TODO: Reorder based on check/uncheck
    await database.updateItem(id, checked: checked);
    numChecked += (checked == 1) ? 1 : -1;
  }

  Future<void> updateIndexes(entriesList) async {
    // TODO: Batch update
    for (int i = 0; i < entriesList.length; i++) {
      await database.updateItem(entriesList[i].id, listIndex: i);
    }
  }

  Future<void> deleteChecked() async {
    await database.deleteChecked();
    numChecked = 0;
  }

  int getNumChecked() {
    return numChecked;
  }
}

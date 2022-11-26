import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/api/checklist_api.dart';
import 'dart:math';

class ChecklistProcessor {
  ChecklistApi checklistApi = ChecklistApi();
  ProfileProcessor profileProcessor = ProfileProcessor();

  int listLength = 0;
  int numChecked = 0;

  Future<List<GroceryEntry>> loadEntries() async {
    String username = await profileProcessor.getUsername();
    List<Map> entries = await checklistApi.getItems(username);
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
    await checklistApi.deleteItem(uuid);
    listLength -= 1;
    return title;
  }

  Future<void> addEntry(title, source) async {
    Random random = Random();
    var username = await profileProcessor.getUsername();
    final newEntry = {
      'list_index': listLength,
      'title': title,
      'checked': 0,
      'source': source,
      'author': username,
      'id': random.nextInt(10000)
    };
    await checklistApi.addItem(newEntry);
    listLength += 1;
  }

  Future<String> shareByText() async {
    String username = await profileProcessor.getUsername();
    List<Map> entries = await checklistApi.getItems(username);
    String entriesString = 'Checklist:\n';
    for (var entry in entries) {
      entriesString += "- ${entry['title']}\n";
    }

    return entriesString;
  }

  Future<void> addTextToList(text) async {
    for (var item in text.split("\n")) {
      if (item.startsWith("- ")) {
        await addEntry(item.replaceAll("- ", ""), "sharing");
        listLength += 1;
      }
    }
  }

  Future<void> updateChecked(id, uuid, checked) async {
    // TODO: Reorder based on check/uncheck
    await checklistApi.updateItem(uuid, checked: checked);
    numChecked += (checked == 1) ? 1 : -1;
  }

  Future<void> updateIndexes(entriesList) async {
    // TODO: Batch update
    for (int i = 0; i < entriesList.length; i++) {
      await checklistApi.updateItem(entriesList[i].uuid, listIndex: i);
    }
  }

  Future<void> deleteChecked(entries) async {
    await checklistApi.deleteChecked(entries);
    numChecked = 0;
  }

  int getNumChecked() {
    return numChecked;
  }
}

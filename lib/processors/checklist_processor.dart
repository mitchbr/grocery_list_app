import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/api/checklist_api.dart';

class ChecklistProcessor {
  ChecklistApi checklistApi = ChecklistApi();
  ProfileProcessor profileProcessor = ProfileProcessor();

  int listLength = 0;
  int numChecked = 0;

  List<GroceryEntry> processEntries(List<Map> entries) {
    List<GroceryEntry> entriesList = entries.map((record) {
      return GroceryEntry(
          id: record['id'],
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

  Future<List<GroceryEntry>> loadEntries() async {
    String username = await profileProcessor.getUsername();
    List<Map> entries = await checklistApi.getItems(username);
    List<GroceryEntry> entriesList = entries.map((record) {
      return GroceryEntry(
          id: record['id'],
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

  Future<String> deleteEntry(title, id) async {
    await checklistApi.deleteItem(id);
    listLength -= 1;
    return title;
  }

  Future<void> addEntry(title, source) async {
    var username = await profileProcessor.getUsername();
    listLength = await checklistApi.itemCount('mitchbr');
    final newEntry = {
      'list_index': listLength,
      'title': title,
      'checked': 0,
      'source': source,
      'author': username,
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

  Future<void> updateChecked(id, checked) async {
    // TODO: Reorder based on check/uncheck
    await checklistApi.updateItem(id, checked: checked);
    numChecked += (checked == 1) ? 1 : -1;
  }

  Future<void> updateIndexes(entriesList) async {
    // TODO: Batch update
    for (int i = 0; i < entriesList.length; i++) {
      await checklistApi.updateItem(entriesList[i].id, listIndex: i);
    }
  }

  Future<void> deleteChecked(entries) async {
    await checklistApi.deleteChecked(entries.where((entry) => entry.checked == 1).toList());
    numChecked = 0;
  }

  int getNumChecked() {
    return numChecked;
  }

  Future<int> getChecklistLength() async {
    String username = await profileProcessor.getUsername();
    await checklistApi.itemCount('mitchell');
    return 1;
  }
}

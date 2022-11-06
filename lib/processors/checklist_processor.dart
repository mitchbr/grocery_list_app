import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/database/checklist_database.dart';

class ChecklistProcessor {
  ChecklistDatabase database = ChecklistDatabase();

  Future<List<GroceryEntry>> loadEntries() async {
    List<Map> entries = await database.loadItems();
    final entriesList = entries.map((record) {
      return GroceryEntry(
        item: record['item'],
      );
    }).toList();
    return entriesList;
  }

  Future<String> deleteEntry(title) async {
    await database.deleteItem(title);
    return title;
  }

  Future<void> addEntry(item) async {
    await database.addItem(item);
  }

  Future<String> shareByText() async {
    List<Map> entries = await database.loadItems();
    String entriesString = 'Checklist:\n';
    for (var entry in entries) {
      entriesString += "- ${entry['item']}\n";
    }

    return entriesString;
  }

  Future<void> addTextToList(text) async {
    List<String> textList = text.split("\n");
    for (var item in textList) {
      if (item != "Checklist") {
        await addEntry(item.replaceAll("- ", ""));
      }
    }
  }
}

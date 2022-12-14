import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';
import 'package:groceries/api/checklist_api.dart';

class ChecklistProcessor {
  ChecklistApi checklistApi = ChecklistApi();
  ProfileProcessor profileProcessor = ProfileProcessor();

  int listLength = 0;
  int numChecked = 0;

  GroceryEntry processEntry(entry) {
    return GroceryEntry(title: entry['title'], checked: entry['checked']);
  }

  int calculateNumChecked(List<GroceryEntry> entries) {
    for (var entry in entries) {
      numChecked += entry.checked;
    }

    return numChecked;
  }

  List<GroceryEntry> processEntries(List entries) {
    List<GroceryEntry> entriesList = entries.map((record) {
      return processEntry(record);
    }).toList();
    listLength = entriesList.length;

    calculateNumChecked(entriesList);

    return entriesList;
  }

  Future<void> updateChecklist(List<GroceryEntry> checklist) async {
    calculateNumChecked(checklist);
    String username = await profileProcessor.getUsername();

    List<Map> firestoreChecklist = checklist.map((entry) => {'title': entry.title, 'checked': entry.checked}).toList();
    await checklistApi.updateChecklist(firestoreChecklist, username);
  }

  String shareByText(List<GroceryEntry> entries) {
    String entriesString = 'Checklist:\n';
    for (var entry in entries) {
      entriesString += "- ${entry.title}\n";
    }

    return entriesString;
  }

  Future<void> updateChecklistFromUnknown(List<GroceryEntry> newEntries) async {
    List<GroceryEntry> checklist = await getChecklist();
    var updatedChecklist = [...checklist, ...newEntries];
    // TODO: Make sure unchecked items get added above checked?
    await updateChecklist(checklist);
  }

  Future<List<GroceryEntry>> getChecklist() async {
    String username = await profileProcessor.getUsername();
    List<GroceryEntry> entries = processEntries(await checklistApi.getItems(username));
    return entries;
  }

  List<GroceryEntry> addTextToList(String text, List<GroceryEntry> entries) {
    for (var item in text.split("\n")) {
      if (item.startsWith("- ")) {
        GroceryEntry entry = processEntry({'title': item.replaceAll("- ", ""), 'checked': 0});
        entries.add(entry);
        listLength += 1;
      }
    }

    return entries;
  }

  List<GroceryEntry> deleteChecked(List<GroceryEntry> entries) {
    List<GroceryEntry> refreshedEntries = [];
    for (var entry in entries) {
      if (entry.checked != 1) {
        refreshedEntries.add(entry);
      }
    }
    return refreshedEntries;
  }

  int getNumChecked() {
    return numChecked;
  }
}

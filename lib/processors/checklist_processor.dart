import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries/processors/profile_processor.dart';
import 'package:groceries/types/grocery_entry.dart';

class ChecklistProcessor {
  ProfileProcessor profileProcessor = ProfileProcessor();

  int listLength = 0;
  int numChecked = 0;

  GroceryEntry processEntry(entry) {
    return GroceryEntry(title: entry['title'], checked: entry['checked']);
  }

  int calculateNumChecked(List<GroceryEntry> entries) {
    numChecked = 0;
    for (var entry in entries) {
      numChecked += entry.checked;
    }

    return numChecked;
  }

  Future<List<dynamic>> getItems(author) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('authors').doc(author).get();
    var entries = querySnapshot.data()!['checklist'];

    return entries;
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
    await sendChecklistToDb(firestoreChecklist, username);
  }

  Future<void> sendChecklistToDb(checklist, author) async {
    var checklistCollection = FirebaseFirestore.instance.collection('authors');
    checklistCollection.doc(author).update({'checklist': checklist});
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
    await updateChecklist(updatedChecklist);
  }

  Future<List<GroceryEntry>> getChecklist() async {
    String username = await profileProcessor.getUsername();
    var rawChecklist = await getItems(username);
    List<GroceryEntry> entries = processEntries(rawChecklist);
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

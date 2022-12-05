import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference checklist = FirebaseFirestore.instance.collection('checklist');

class ChecklistApi {
  final _fireStoreChecklist = FirebaseFirestore.instance.collection('checklist');

  Future<List<Map>> getItems(author) async {
    var querySnapshot = await _fireStoreChecklist.where('author', isEqualTo: author).get();
    var entries = querySnapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();

    return entries;
  }

  Future<void> addItem(item) async {
    var checklistCollection = _fireStoreChecklist;
    checklistCollection.add(item);
  }

  Future<void> deleteItem(id) async {
    // TODO: Add error catching
    var checklistCollection = _fireStoreChecklist;
    await checklistCollection.doc(id).delete();
  }

  Future<void> deleteChecked(entries) async {
    var checklistCollection = _fireStoreChecklist;
    for (var entry in entries) {
      await checklistCollection.doc(entry.id).delete();
    }
  }

  Future<void> updateItem(id, {checked = -1, listIndex = -1}) async {
    Map<String, Object?> updateData = {};
    if (checked != -1) {
      updateData['checked'] = checked;
    } else if (listIndex != -1) {
      updateData['list_index'] = listIndex;
    } else {
      return;
    }

    var checklistCollection = _fireStoreChecklist;
    await checklistCollection.doc(id).update(updateData);
  }

  Future<int> itemCount(author) async {
    var querySnapshot = await _fireStoreChecklist.where('author', isEqualTo: author).count().get();
    return querySnapshot.count;
  }
}

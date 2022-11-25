import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference checklist = FirebaseFirestore.instance.collection('checklist');

class ChecklistApi {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<Map>> getItems(author) async {
    var querySnapshot = await _fireStore.collection('checklist').where('author', isEqualTo: author).get();
    var entries = querySnapshot.docs.map((e) => {'uuid': e.id, ...e.data()}).toList();

    return entries;
  }

  Future<void> addItem(item) async {
    var checklistCollection = _fireStore.collection('checklist');
    checklistCollection.add(item);
  }

  Future<void> deleteItem(uuid) async {
    // TODO: Add error catching
    var checklistCollection = _fireStore.collection('checklist');
    await checklistCollection.doc(uuid).delete();
  }

  Future<void> deleteChecked(entries) async {
    var checklistCollection = _fireStore.collection('checklist');
    for (var entry in entries) {
      await checklistCollection.doc(entry.uuid).delete();
    }
  }

  Future<void> updateItem(uuid, {checked = -1, listIndex = -1}) async {
    Map<String, Object?> updateData = {};
    if (checked != -1) {
      updateData['checked'] = checked;
    } else if (listIndex != -1) {
      updateData['list_index'] = listIndex;
    } else {
      return;
    }

    var checklistCollection = _fireStore.collection('checklist');
    await checklistCollection.doc(uuid).update(updateData);
  }
}

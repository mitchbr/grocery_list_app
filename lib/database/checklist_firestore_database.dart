import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference checklist = FirebaseFirestore.instance.collection('checklist');

class ChecklistFirestoreDatabase {
  final _fireStore = FirebaseFirestore.instance;

  Future<List<Map>> getItems(author) async {
    var querySnapshot = await _fireStore.collection('checklist').where('author', isEqualTo: author).get();
    var entries = querySnapshot.docs.map((e) => e.data()).toList();

    return entries;
  }

  Future<void> addItem(item) async {
    var checklistCollection = _fireStore.collection('checklist');
    checklistCollection.add(item);
  }
}

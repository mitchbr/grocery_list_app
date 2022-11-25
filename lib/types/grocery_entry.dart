class GroceryEntry {
  late int id;
  String uuid;
  late int listIndex;
  late String title;
  late int checked;
  late String source;
  late String author;

  GroceryEntry(
      {required this.id,
      required this.listIndex,
      required this.title,
      required this.checked,
      required this.source,
      this.uuid = "default_uuid",
      this.author = "default_author"});
}

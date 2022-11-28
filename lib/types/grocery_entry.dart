class GroceryEntry {
  late String id;
  late int listIndex;
  late String title;
  late int checked;
  late String source;
  late String author;

  GroceryEntry(
      {required this.listIndex,
      required this.title,
      required this.checked,
      required this.source,
      required this.id,
      required this.author});
}

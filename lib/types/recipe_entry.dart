class RecipeEntry {
  late String author;
  late String id;
  late String recipe;
  late List<dynamic> ingredients;
  late String instructions;
  late String category;
  late String tags;
  late int updatedAt;
  late int createdAt;
  late int timesMade;

  RecipeEntry(
      {required this.author,
      required this.id,
      required this.recipe,
      required this.ingredients,
      required this.instructions,
      required this.category,
      required this.tags,
      required this.updatedAt,
      required this.createdAt,
      required this.timesMade});
}

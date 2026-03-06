
class WishTemplate {
  final String id;
  final String title;
  final String content;
  final List<String> targetGroups;
  final bool isFavorite;
  final int usageCount;
  final bool isSystem;
  final int? userId; // Null if it's a system template

  WishTemplate({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.targetGroups,
    this.isFavorite = false,
    this.usageCount = 0,
    this.isSystem = false,
  });

}

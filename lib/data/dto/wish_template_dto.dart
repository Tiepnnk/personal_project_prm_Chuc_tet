class WishTemplateDto {
  final String id;
  final String title;
  final String content;
  final String targetGroups;
  final int isFavorite;
  final int usageCount;
  final int isSystem;
  final int? userId; // Null if it's a system template

  WishTemplateDto({
    required this.id,
    this.userId,
    required this.title,
    required this.content,
    required this.targetGroups,
    this.isFavorite = 0,
    this.usageCount = 0,
    this.isSystem = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'targetGroups': targetGroups,
      'isFavorite': isFavorite,
      'usageCount': usageCount,
      'isSystem': isSystem,
    };
  }

  factory WishTemplateDto.fromMap(Map<String, dynamic> map) {
    return WishTemplateDto(
      id: map['id'] as String,
      userId: map['userId'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      targetGroups: map['targetGroups'] as String,
      isFavorite: map['isFavorite'] as int,
      usageCount: map['usageCount'] as int,
      isSystem: map['isSystem'] as int,
    );
  }
}

import 'package:personal_project_prm/data/dto/wish_template_dto.dart';
import 'package:personal_project_prm/data/implementations/local/app_database.dart';
import 'package:personal_project_prm/data/interfaces/api/iwish_template_api.dart';
import 'package:uuid/uuid.dart';

class WishTemplateApi implements IWishTemplateApi {
  final AppDatabase database;

  WishTemplateApi(this.database);

  @override
  Future<List<WishTemplateDto>> getAll() async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query('wish_templates');
    return maps.map((map) => WishTemplateDto.fromMap(map)).toList();
  }

  @override
  Future<WishTemplateDto?> getById(String id) async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'wish_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return WishTemplateDto.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> create(
    String title,
    String content,
    String targetGroups,
    int isFavorite,
    int? userId,
  ) async {
    final db = await database.db;
    final String newId = const Uuid().v4();
    await db.insert('wish_templates', {
      'id': newId,
      'userId': userId,
      'title': title,
      'content': content,
      'targetGroups': targetGroups,
      'isFavorite': isFavorite,
      'usageCount': 0,
      'isSystem': 0,
    });
  }

  @override
  Future<void> update(
    String id,
    String title,
    String content,
    String targetGroups,
    int isFavorite,
  ) async {
    final db = await database.db;
    await db.update(
      'wish_templates',
      {
        'title': title,
        'content': content,
        'targetGroups': targetGroups,
        'isFavorite': isFavorite,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await database.db;
    await db.delete(
      'wish_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleFavorite(String id, int isFavorite) async {
    final db = await database.db;
    await db.update(
      'wish_templates',
      {'isFavorite': isFavorite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> incrementUsage(String id) async {
    final db = await database.db;
    await db.rawUpdate(
      'UPDATE wish_templates SET usageCount = usageCount + 1 WHERE id = ?',
      [id],
    );
  }
}

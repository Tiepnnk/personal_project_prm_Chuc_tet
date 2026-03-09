import 'package:personal_project_prm/data/dto/wish_record_dto.dart';
import 'package:personal_project_prm/data/implementations/local/app_database.dart';
import 'package:personal_project_prm/data/interfaces/api/iwish_record_api.dart';
import 'package:uuid/uuid.dart';

class WishRecordApi implements IWishRecordApi {
  final AppDatabase database;

  WishRecordApi(this.database);

  @override
  Future<List<WishRecordDto>> getAll() async {
    final db = await database.db;
    final maps = await db.query('wish_records');
    return maps.map((m) => WishRecordDto.fromMap(m)).toList();
  }

  @override
  Future<WishRecordDto?> getByContactAndYear(String contactId, int year) async {
    final db = await database.db;
    final maps = await db.query(
      'wish_records',
      where: 'contactId = ? AND year = ?',
      whereArgs: [contactId, year],
      limit: 1,
    );
    if (maps.isNotEmpty) return WishRecordDto.fromMap(maps.first);
    return null;
  }

  @override
  Future<WishRecordDto> create(String contactId, int year, String status) async {
    final db = await database.db;
    final id = const Uuid().v4();
    await db.insert('wish_records', {
      'id': id,
      'contactId': contactId,
      'year': year,
      'status': status,
    });
    final maps = await db.query(
      'wish_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return WishRecordDto.fromMap(maps.first);
  }

  @override
  Future<void> updateStatus(
    String id,
    String status, {
    String? completedAt,
    String? customMessage,
    String? templateUsedId,
  }) async {
    final db = await database.db;
    final data = <String, dynamic>{'status': status};
    if (completedAt != null) data['completedAt'] = completedAt;
    if (customMessage != null) data['customMessage'] = customMessage;
    if (templateUsedId != null) data['templateUsedId'] = templateUsedId;
    await db.update('wish_records', data, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<String>> getPendingContactIds(int year) async {
    final db = await database.db;
    final maps = await db.query(
      'wish_records',
      columns: ['contactId'],
      where: "year = ? AND status = 'PENDING'",
      whereArgs: [year],
    );
    return maps.map((m) => m['contactId'] as String).toList();
  }

  @override
  Future<List<String>> getAllRecordedContactIds(int year) async {
    final db = await database.db;
    final maps = await db.query(
      'wish_records',
      columns: ['contactId'],
      where: 'year = ?',
      whereArgs: [year],
    );
    return maps.map((m) => m['contactId'] as String).toList();
  }

  @override
  Future<Map<String, String>> getStatusMapForYear(int year) async {
    final db = await database.db;
    final maps = await db.query(
      'wish_records',
      columns: ['contactId', 'status'],
      where: 'year = ?',
      whereArgs: [year],
    );
    return {for (final m in maps) m['contactId'] as String: m['status'] as String};
  }
}

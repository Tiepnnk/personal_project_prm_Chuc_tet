import 'package:personal_project_prm/data/dto/contact_dto.dart';
import 'package:personal_project_prm/data/dto/contacts/update_insert_contact_dto.dart';
import 'package:personal_project_prm/data/implementations/local/app_database.dart';
import 'package:personal_project_prm/data/interfaces/api/icontact_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ContactApi implements IContactApi {
  final AppDatabase database;

  ContactApi(this.database);

  @override
  Future<String> create(UpdateInsertContactDto req) async {
    final db = await database.db;
    
    // Generate UUID for the new contact
    final String newId = const Uuid().v4();
    
    await db.insert('contacts', req.toMapForInsert(newId));
    return newId;
  }

  @override
  Future<int> delete(String id) async {
    final db = await database.db;
    
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ContactDto>> getAll() async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return maps.map((map) => ContactDto.fromMap(map)).toList();
  }

  @override
  Future<ContactDto?> getById(String id) async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ContactDto.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> update(String id, UpdateInsertContactDto req) async {
    final db = await database.db;
    
    return await db.update(
      'contacts',
      req.toMapForUpdate(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<ContactDto?> getByPhone(String phone) async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    if (maps.isNotEmpty) {
      return ContactDto.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> seedDemoIfEmpty() async {
    final db = await database.db;
    final countSqflite = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM contacts'));

    if (countSqflite == null || countSqflite == 0) {
      // Create some demo data here if needed, linking them to admin (userId = 1)
      final dummyId1 = const Uuid().v4();
      final dummyId2 = const Uuid().v4();

      await db.insert('contacts', {
        'id': dummyId1,
        'userId': 1,
        'fullName': 'Nguyễn Văn A',
        'phone': '0912345678',
        'category': 'FRIEND',
        'priority': 'OPTIONAL',
        'isActive': 1,
      });

      await db.insert('contacts', {
        'id': dummyId2,
        'userId': 1,
        'fullName': 'Trần Thị B',
        'phone': '0987654321',
        'category': 'FAMILY',
        'priority': 'MUST',
        'isActive': 1,
      });
    }
  }
}

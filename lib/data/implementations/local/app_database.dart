
import 'package:path/path.dart';
import 'package:personal_project_prm/data/implementations/local/password_hasher.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async{
    _db ??= await _open();
    return _db!;
  }
  Future<Database> _open() async{
    final doPath = await getDatabasesPath();
    final path = join(doPath, 'personal_project_prm.db');
    final dbInstance = await openDatabase(
        path,
        version: 5,
        onCreate: (Database db, int version) async{
          // users: lưu username +  password_hash + phone + full_name
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_name TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              phone TEXT UNIQUE,
              full_name TEXT,
              avatar TEXT
          );
          ''');

          // session : chỉ lưu 1 session đang đăng nhập (id=1)
          await db.execute('''
          CREATE TABLE session (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id INTEGER NOT NULL,
            token TEXT NOT NULL,
            created_at TEXT NOT NULL
            );
            ''');
          
          await _createV3Tables(db);

          await db.insert('users', {
            'user_name': 'admin',
            'password_hash': PasswordHasher.sha256Hash('123456'),
            'phone': '0948711657',
            'full_name': 'Administrator'
          });
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            try { await db.execute('ALTER TABLE users ADD COLUMN phone TEXT;'); } catch (_) {}
            try { await db.execute('ALTER TABLE users ADD COLUMN full_name TEXT;'); } catch (_) {}
          }
          if (oldVersion < 3) {
            await _createV3Tables(db);
          }
          if (oldVersion < 4) {
             try { await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT;'); } catch (_) {}
             try { await db.execute('ALTER TABLE contacts ADD COLUMN avatar TEXT;'); } catch (_) {}
          }
          if (oldVersion < 5) {
             await _migrateToV5(db);
          }
        },
    );
    
    // Đảm bảo luôn có tài khoản admin (phòng trường hợp DB cũ không chạy qua onCreate)
    await _ensureAdminExists(dbInstance);

    return dbInstance;
  }

  static Future<void> _ensureAdminExists(Database db) async {
    final result = await db.query(
      'users',
      where: 'user_name = ?',
      whereArgs: ['admin'],
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert('users', {
        'user_name': 'admin',
        'password_hash': PasswordHasher.sha256Hash('123456'),
        'phone': '0948711657',
        'full_name': 'Administrator'
      });
    }
  }

  static Future<void> _createV3Tables(Database db) async {
    // 1. Bảng contacts (Quản lý Danh bạ)
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        fullName TEXT NOT NULL,
        nickname TEXT,
        phone TEXT NOT NULL,
        category TEXT NOT NULL CHECK(category IN ('FAMILY', 'BOSS', 'COLLEAGUE', 'PARTNER', 'FRIEND', 'TEACHER', 'NEIGHBOR', 'OTHER')) DEFAULT 'OTHER',
        priority TEXT NOT NULL CHECK(priority IN ('MUST', 'SHOULD', 'OPTIONAL')) DEFAULT 'OPTIONAL',
        note TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        avatar TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 2. Bảng wish_templates (Quản lý Mẫu lời chúc)
    await db.execute('''
      CREATE TABLE wish_templates (
        id TEXT PRIMARY KEY,
        userId INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        targetGroups TEXT NOT NULL, -- Lưu dưới dạng mảng JSON chuỗi
        isFavorite INTEGER NOT NULL DEFAULT 0,
        usageCount INTEGER NOT NULL DEFAULT 0,
        isSystem INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 3. Bảng wish_records (Theo dõi & Đánh dấu Gọi/Chúc)
    await db.execute('''
      CREATE TABLE wish_records (
        id TEXT PRIMARY KEY,
        contactId TEXT NOT NULL,
        year INTEGER NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('PENDING', 'CALLED', 'CALLED_BACK')) DEFAULT 'PENDING',
        completedAt TEXT,
        customMessage TEXT,
        followUpNote TEXT,
        templateUsedId TEXT,
        FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE,
        FOREIGN KEY (templateUsedId) REFERENCES wish_templates (id) ON DELETE SET NULL,
        UNIQUE(contactId, year)
      )
    ''');

    // 4. Bảng reminders (Nhắc nhở)
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        contactId TEXT,
        wishRecordId TEXT,
        remindAt TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('REMIND_CALL_BACK', 'REMIND_DATE')),
        isDone INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE,
        FOREIGN KEY (wishRecordId) REFERENCES wish_records (id) ON DELETE CASCADE
      )
    ''');

    // 5. Bảng user_settings (Cài đặt cá nhân, link với users)
    await db.execute('''
      CREATE TABLE user_settings (
        userId INTEGER PRIMARY KEY,
        myName TEXT,
        defaultTone TEXT,
        notifyEnabled INTEGER NOT NULL DEFAULT 1,
        notifyHours TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Default System Templates
    await db.execute('''
      INSERT INTO wish_templates (id, title, content, targetGroups, isFavorite, usageCount, isSystem) VALUES 
      ('sys-template-1', 'Chúc gia đình — ấm áp', 'Nhân dịp năm mới {{nam_am}}, {{ten_minh}} kính chúc {{chuc_danh}} {{ten}} sức khỏe dồi dào...', '["FAMILY", "RELATIVE"]', 0, 0, 1),
      ('sys-template-2', 'Chúc sếp — trang trọng', 'Kính chúc {{ten}} cùng gia đình một năm {{nam_am}} an khang thịnh vượng, sự nghiệp thăng tiến...', '["BOSS"]', 0, 0, 1),
      ('sys-template-3', 'Chúc đồng nghiệp — thân mật', 'Chúc mừng năm mới {{ten}} nhé! Năm {{nam_am}} mình cùng nhau...', '["COLLEAGUE", "FRIEND"]', 0, 0, 1),
      ('sys-template-4', 'Chúc đối tác — chuyên nghiệp', 'Nhân dịp Tết {{nam_am}}, công ty trân trọng gửi lời chúc đến {{ten}}...', '["PARTNER", "CLIENT"]', 0, 0, 1),
      ('sys-template-5', 'Chúc thầy/cô — kính trọng', 'Em {{ten_minh}} kính chúc {{ten}} năm mới sức khỏe, hạnh phúc và thành công...', '["TEACHER"]', 0, 0, 1),
      ('sys-template-6', 'Chúc bạn thân — vui vẻ', 'Năm mới năm me! Chúc {{ten}} ngập tràn năng lượng, tiền vào như nước...', '["FRIEND"]', 0, 0, 1);
    ''');
  }

  static Future<void> _migrateToV5(Database db) async {
    // SQLite doesn't directly support dropping columns or modifying CHECK constraints.
    // The standard way is to create a new table, copy data, and drop the old table.
    
    // 1. Create temporary table with new schema
    await db.execute('''
      CREATE TABLE wish_records_new (
        id TEXT PRIMARY KEY,
        contactId TEXT NOT NULL,
        year INTEGER NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('PENDING', 'CALLED', 'CALLED_BACK')) DEFAULT 'PENDING',
        completedAt TEXT,
        customMessage TEXT,
        followUpNote TEXT,
        templateUsedId TEXT,
        FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE,
        FOREIGN KEY (templateUsedId) REFERENCES wish_templates (id) ON DELETE SET NULL,
        UNIQUE(contactId, year)
      )
    ''');

    // 2. Copy data over.
    // Map NO_ANSWER and SKIPPED to PENDING or CALLED to fit new constraint (e.g., fallback to PENDING).
    await db.execute('''
      INSERT INTO wish_records_new (id, contactId, year, status, completedAt, customMessage, followUpNote, templateUsedId)
      SELECT 
        id, 
        contactId, 
        year, 
        CASE 
          WHEN status IN ('NO_ANSWER', 'SKIPPED') THEN 'PENDING'
          ELSE status 
        END,
        completedAt, 
        customMessage, 
        followUpNote, 
        templateUsedId
      FROM wish_records
    ''');

    // 3. Drop old table
    await db.execute('DROP TABLE wish_records');

    // 4. Rename new table to original name
    await db.execute('ALTER TABLE wish_records_new RENAME TO wish_records');
  }
}
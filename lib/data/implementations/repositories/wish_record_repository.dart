import 'package:personal_project_prm/data/implementations/api/wish_record_api.dart';
import 'package:personal_project_prm/data/implementations/mapper/wish_record_mapper.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_record_repository.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/domain/entities/wish_record.dart';

class WishRecordRepository implements IWishRecordRepository {
  final WishRecordApi wishRecordApi;
  final WishRecordMapper wishRecordMapper;

  const WishRecordRepository({
    required this.wishRecordApi,
    required this.wishRecordMapper,
  });

  @override
  Future<WishRecord> getOrCreate(String contactId, int year) async {
    final existing = await wishRecordApi.getByContactAndYear(contactId, year);
    if (existing != null) return wishRecordMapper.map(existing);

    // Không có → tạo mới với trạng thái PENDING
    final created = await wishRecordApi.create(contactId, year, 'PENDING');
    return wishRecordMapper.map(created);
  }

  @override
  Future<void> updateStatus(
    String id,
    WishStatus status, {
    DateTime? completedAt,
    String? customMessage,
    String? templateUsedId,
  }) async {
    await wishRecordApi.updateStatus(
      id,
      status.toDbString,
      completedAt: completedAt?.toIso8601String(),
      customMessage: customMessage,
      templateUsedId: templateUsedId,
    );
  }

  @override
  Future<List<String>> getPendingContactIds(int year) async {
    return wishRecordApi.getPendingContactIds(year);
  }

  @override
  Future<List<String>> getAllRecordedContactIds(int year) async {
    return wishRecordApi.getAllRecordedContactIds(year);
  }

  @override
  Future<Map<String, WishStatus>> getStatusMapForYear(int year) async {
    final raw = await wishRecordApi.getStatusMapForYear(year);
    return raw.map(
      (contactId, status) => MapEntry(
        contactId,
        WishStatusExtension.fromDbString(status),
      ),
    );
  }
}

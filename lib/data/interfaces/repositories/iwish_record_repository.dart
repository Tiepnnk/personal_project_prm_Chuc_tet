import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/domain/entities/wish_record.dart';

abstract class IWishRecordRepository {
  /// Lấy wish_record theo contactId + năm hiện tại, hoặc tạo mới với status PENDING
  Future<WishRecord> getOrCreate(String contactId, int year);

  /// Cập nhật trạng thái wish_record
  Future<void> updateStatus(
    String id,
    WishStatus status, {
    DateTime? completedAt,
    String? customMessage,
    String? templateUsedId,
  });

  /// Lấy danh sách contactId có wish_record PENDING trong năm
  Future<List<String>> getPendingContactIds(int year);

  /// Lấy tất cả contactId có bất kỳ wish_record nào trong năm
  Future<List<String>> getAllRecordedContactIds(int year);

  /// Lấy Map<contactId, WishStatus> cho tất cả record trong năm
  Future<Map<String, WishStatus>> getStatusMapForYear(int year);
}

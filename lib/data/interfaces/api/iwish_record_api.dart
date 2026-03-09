import 'package:personal_project_prm/data/dto/wish_record_dto.dart';

abstract class IWishRecordApi {
  Future<List<WishRecordDto>> getAll();
  Future<WishRecordDto?> getByContactAndYear(String contactId, int year);
  Future<WishRecordDto> create(String contactId, int year, String status);
  Future<void> updateStatus(
    String id,
    String status, {
    String? completedAt,
    String? customMessage,
    String? templateUsedId,
  });
  Future<List<String>> getPendingContactIds(int year);
  /// Lấy tất cả contactId có bất kỳ wish_record nào trong năm (không phân biệt status)
  Future<List<String>> getAllRecordedContactIds(int year);
  /// Lấy Map<contactId, status> cho tất cả record trong năm
  Future<Map<String, String>> getStatusMapForYear(int year);
}

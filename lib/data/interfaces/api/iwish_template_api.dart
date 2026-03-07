import 'package:personal_project_prm/data/dto/wish_template_dto.dart';

abstract class IWishTemplateApi {
  Future<List<WishTemplateDto>> getAll();
  Future<WishTemplateDto?> getById(String id);
  Future<void> create(
    String title,
    String content,
    String targetGroups,
    int isFavorite,
    int? userId,
  );
  Future<void> update(
    String id,
    String title,
    String content,
    String targetGroups,
    int isFavorite,
  );
  Future<void> delete(String id);
  Future<void> toggleFavorite(String id, int isFavorite);
  Future<void> incrementUsage(String id);
}

import 'package:personal_project_prm/domain/entities/wish_template.dart';

abstract class IWishTemplateRepository {
  Future<List<WishTemplate>> getAll();
  Future<WishTemplate?> getById(String id);
  Future<WishTemplate> create(
    String title,
    String content,
    List<String> targetGroups,
    bool isFavorite,
  );
  Future<WishTemplate> update(
    String id,
    String title,
    String content,
    List<String> targetGroups,
    bool isFavorite,
  );
  Future<void> delete(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> incrementUsage(String id);
}

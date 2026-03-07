import 'dart:convert';

import 'package:personal_project_prm/data/implementations/mapper/wish_template_mapper.dart';
import 'package:personal_project_prm/data/interfaces/api/iwish_template_api.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_template_repository.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';

class WishTemplateRepository implements IWishTemplateRepository {
  final IWishTemplateApi wishTemplateApi;
  final WishTemplateMapper wishTemplateMapper;
  final IAuthRepository authRepository;

  const WishTemplateRepository({
    required this.wishTemplateApi,
    required this.wishTemplateMapper,
    required this.authRepository,
  });

  @override
  Future<List<WishTemplate>> getAll() async {
    final session = await authRepository.getCurrentSession();
    if (session == null) {
      throw Exception('User is not logged in');
    }

    final dtoList = await wishTemplateApi.getAll();

    // Trả về system templates + templates của user hiện tại
    final filtered = dtoList.where((dto) {
      return dto.isSystem == 1 || dto.userId == session.user.id;
    }).toList();

    return filtered.map((dto) => wishTemplateMapper.map(dto)).toList();
  }

  @override
  Future<WishTemplate?> getById(String id) async {
    final dto = await wishTemplateApi.getById(id);
    if (dto == null) return null;
    return wishTemplateMapper.map(dto);
  }

  @override
  Future<WishTemplate> create(
    String title,
    String content,
    List<String> targetGroups,
    bool isFavorite,
  ) async {
    final session = await authRepository.getCurrentSession();
    if (session == null) {
      throw Exception('User is not logged in');
    }

    final targetGroupsJson = jsonEncode(targetGroups);
    await wishTemplateApi.create(
      title,
      content,
      targetGroupsJson,
      isFavorite ? 1 : 0,
      session.user.id,
    );

    // Fetch all và tìm bản ghi mới nhất của user hiện tại theo title+content
    final allDtos = await wishTemplateApi.getAll();
    final newDto = allDtos.lastWhere(
      (dto) =>
          dto.title == title &&
          dto.content == content &&
          dto.userId == session.user.id,
    );
    return wishTemplateMapper.map(newDto);
  }

  @override
  Future<WishTemplate> update(
    String id,
    String title,
    String content,
    List<String> targetGroups,
    bool isFavorite,
  ) async {
    final existingDto = await wishTemplateApi.getById(id);
    if (existingDto == null) {
      throw Exception('Template not found');
    }

    // Chỉ cho phép edit template không phải system
    if (existingDto.isSystem == 1) {
      throw Exception('Cannot edit a system template');
    }

    final session = await authRepository.getCurrentSession();
    if (session == null || existingDto.userId != session.user.id) {
      throw Exception('Unauthorized to update this template');
    }

    final targetGroupsJson = jsonEncode(targetGroups);
    await wishTemplateApi.update(
      id,
      title,
      content,
      targetGroupsJson,
      isFavorite ? 1 : 0,
    );

    final updatedDto = await wishTemplateApi.getById(id);
    return wishTemplateMapper.map(updatedDto!);
  }

  @override
  Future<void> delete(String id) async {
    final existingDto = await wishTemplateApi.getById(id);
    if (existingDto == null) return;

    if (existingDto.isSystem == 1) {
      throw Exception('Cannot delete a system template');
    }

    final session = await authRepository.getCurrentSession();
    if (session == null || existingDto.userId != session.user.id) {
      throw Exception('Unauthorized to delete this template');
    }

    await wishTemplateApi.delete(id);
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await wishTemplateApi.toggleFavorite(id, isFavorite ? 1 : 0);
  }

  @override
  Future<void> incrementUsage(String id) async {
    await wishTemplateApi.incrementUsage(id);
  }
}

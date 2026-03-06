import 'dart:convert';
import 'package:personal_project_prm/data/dto/wish_template_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';

class WishTemplateMapper implements IMapper<WishTemplateDto, WishTemplate> {
  @override
  WishTemplate map(WishTemplateDto input) {
    return WishTemplate(
      id: input.id,
      userId: input.userId,
      title: input.title,
      content: input.content,
      targetGroups: List<String>.from(jsonDecode(input.targetGroups)),
      isFavorite: input.isFavorite == 1,
      usageCount: input.usageCount,
      isSystem: input.isSystem == 1,
    );
  }

  WishTemplateDto mapToDto(WishTemplate entity) {
    return WishTemplateDto(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      content: entity.content,
      targetGroups: jsonEncode(entity.targetGroups),
      isFavorite: entity.isFavorite ? 1 : 0,
      usageCount: entity.usageCount,
      isSystem: entity.isSystem ? 1 : 0,
    );
  }
}

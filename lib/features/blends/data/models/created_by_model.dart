import 'package:one_atta/features/blends/domain/entities/created_by_entity.dart';

class CreatedByModel extends CreatedByEntity {
  const CreatedByModel({required super.id, required super.name});

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  CreatedByEntity toEntity() {
    return CreatedByEntity(id: id, name: name);
  }
}

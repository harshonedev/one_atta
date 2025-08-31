import 'package:equatable/equatable.dart';

class RecipeBlendEntity extends Equatable {
  final String id;
  final String name;
  final String? description;

  const RecipeBlendEntity({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

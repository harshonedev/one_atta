import 'package:equatable/equatable.dart';

class CreatedByEntity extends Equatable {
  final String id;
  final String name;

  const CreatedByEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

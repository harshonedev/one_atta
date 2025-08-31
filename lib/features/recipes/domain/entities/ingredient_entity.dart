import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  final String name;
  final double quantity;
  final String unit;

  const IngredientEntity({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [name, quantity, unit];
}

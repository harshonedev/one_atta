part of 'customizer_bloc.dart';

// Events
abstract class CustomizerEvent extends Equatable {
  const CustomizerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCustomizer extends CustomizerEvent {}

class LoadIngredients extends CustomizerEvent {}

class SelectPacketSize extends CustomizerEvent {
  final PacketSize packetSize;

  const SelectPacketSize(this.packetSize);

  @override
  List<Object?> get props => [packetSize];
}

class UpdateWheatPercentage extends CustomizerEvent {
  final double percentage;

  const UpdateWheatPercentage(this.percentage);

  @override
  List<Object?> get props => [percentage];
}

class AddIngredient extends CustomizerEvent {
  final Ingredient ingredient;

  const AddIngredient(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

class RemoveIngredient extends CustomizerEvent {
  final String ingredientName;

  const RemoveIngredient(this.ingredientName);

  @override
  List<Object?> get props => [ingredientName];
}

class UpdateIngredientPercentage extends CustomizerEvent {
  final String ingredientName;
  final double percentage;

  const UpdateIngredientPercentage(this.ingredientName, this.percentage);

  @override
  List<Object?> get props => [ingredientName, percentage];
}

class ShowCapacityExceededSnackbar extends CustomizerEvent {}

class AnalyzeBlend extends CustomizerEvent {}

class SaveBlend extends CustomizerEvent {
  final String blendName;

  const SaveBlend(this.blendName);

  @override
  List<Object?> get props => [blendName];
}

class LoadUserBlends extends CustomizerEvent {}

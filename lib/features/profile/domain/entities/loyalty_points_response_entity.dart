import 'package:equatable/equatable.dart';

class LoyaltyPointsResponseEntity extends Equatable {
  final String message;
  final int points;
  final int totalPoints;

  const LoyaltyPointsResponseEntity({
    required this.message,
    required this.points,
    required this.totalPoints,
  });

  @override
  List<Object?> get props => [message, points, totalPoints];
}

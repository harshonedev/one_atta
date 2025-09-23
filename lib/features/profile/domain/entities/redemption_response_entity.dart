import 'package:equatable/equatable.dart';

class RedemptionResponseEntity extends Equatable {
  final String message;
  final int redeemed;
  final int remainingPoints;

  const RedemptionResponseEntity({
    required this.message,
    required this.redeemed,
    required this.remainingPoints,
  });

  @override
  List<Object?> get props => [message, redeemed, remainingPoints];
}

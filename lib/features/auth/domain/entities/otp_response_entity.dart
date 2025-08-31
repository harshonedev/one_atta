import 'package:equatable/equatable.dart';

class OtpResponseEntity extends Equatable {
  final String requestId;
  final String message;
  final String? testOtp; // Only present in test mode

  const OtpResponseEntity({
    required this.requestId,
    required this.message,
    this.testOtp,
  });

  @override
  List<Object?> get props => [requestId, message, testOtp];
}

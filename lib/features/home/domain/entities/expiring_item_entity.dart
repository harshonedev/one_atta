import 'package:equatable/equatable.dart';

/// Represents the urgency level of an expiring item
enum ExpiryUrgency {
  normal, // 14-4 days left
  warning, // 4-3 days left
  critical, // 0-3 days left
}

/// Entity representing an item that is about to expire
class ExpiringItemEntity extends Equatable {
  final String orderId;
  final String orderItemId;
  final String itemName;
  final String itemType; // 'Product' or 'Blend'
  final DateTime orderDate;
  final DateTime expiryDate;
  final int daysUntilExpiry;
  final ExpiryUrgency urgency;
  final double quantity;
  final int weightInKg;

  const ExpiringItemEntity({
    required this.orderId,
    required this.orderItemId,
    required this.itemName,
    required this.itemType,
    required this.orderDate,
    required this.expiryDate,
    required this.daysUntilExpiry,
    required this.urgency,
    required this.quantity,
    required this.weightInKg,
  });

  /// Calculate urgency based on days until expiry
  factory ExpiringItemEntity.fromOrderItem({
    required String orderId,
    required String orderItemId,
    required String itemName,
    required String itemType,
    required DateTime orderDate,
    required int expiryDays,
    required double quantity,
    required int weightInKg,
  }) {
    final expiryDate = orderDate.add(Duration(days: expiryDays));
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    final urgency = _calculateUrgency(daysUntilExpiry);

    return ExpiringItemEntity(
      orderId: orderId,
      orderItemId: orderItemId,
      itemName: itemName,
      itemType: itemType,
      orderDate: orderDate,
      expiryDate: expiryDate,
      daysUntilExpiry: daysUntilExpiry,
      urgency: urgency,
      quantity: quantity,
      weightInKg: weightInKg,
    );
  }

  static ExpiryUrgency _calculateUrgency(int daysLeft) {
    if (daysLeft <= 3) {
      return ExpiryUrgency.critical;
    } else if (daysLeft <= 4) {
      return ExpiryUrgency.warning;
    } else {
      return ExpiryUrgency.normal;
    }
  }

  /// Get progress value between 0.0 and 1.0 for progress bar
  /// Assumes 14 days is the warning threshold
  double getProgressValue() {
    const maxWarningDays = 14;
    if (daysUntilExpiry >= maxWarningDays) return 1.0;
    if (daysUntilExpiry <= 0) return 0.0;
    return daysUntilExpiry / maxWarningDays;
  }

  @override
  List<Object?> get props => [
    orderId,
    orderItemId,
    itemName,
    itemType,
    orderDate,
    expiryDate,
    daysUntilExpiry,
    urgency,
    quantity,
    weightInKg,
  ];
}

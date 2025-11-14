import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/invoices/domain/entities/invoice_entity.dart';

abstract class InvoiceRepository {
  /// Get invoice by order ID
  Future<Either<Failure, InvoiceEntity>> getInvoiceByOrderId(String orderId);

  /// Get invoice download URL
  Future<Either<Failure, String>> getInvoiceDownloadUrl(String invoiceId);

  /// Get tracking details from invoice
  Future<Either<Failure, ShipmentDetails>> getTrackingDetails(String invoiceId);
}

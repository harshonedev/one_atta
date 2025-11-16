import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/invoices/domain/entities/invoice_entity.dart';

abstract class InvoiceRepository {
  /// Get invoice by order ID
  Future<Either<Failure, InvoiceEntity>> getInvoiceByOrderId(String orderId);

  /// Get invoice download URL (preview mode)
  Future<Either<Failure, String>> getInvoiceDownloadUrl(String invoiceId);

  /// Download invoice PDF as bytes
  Future<Either<Failure, Uint8List>> downloadInvoicePdf(String invoiceId);

  /// Get tracking details from invoice
  Future<Either<Failure, ShipmentDetails>> getTrackingDetails(String invoiceId);
}

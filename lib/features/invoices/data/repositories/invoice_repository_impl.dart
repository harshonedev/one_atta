import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:one_atta/features/invoices/domain/entities/invoice_entity.dart';
import 'package:one_atta/features/invoices/domain/repositories/invoice_repository.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoiceByOrderId(
    String orderId,
  ) async {
    try {
      final invoice = await remoteDataSource.getInvoiceByOrderId(orderId);
      return Right(invoice.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getInvoiceDownloadUrl(
    String invoiceId,
  ) async {
    try {
      final url = await remoteDataSource.getInvoiceDownloadUrl(invoiceId);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ShipmentDetails>> getTrackingDetails(
    String invoiceId,
  ) async {
    try {
      final tracking = await remoteDataSource.getTrackingDetails(invoiceId);
      return Right(tracking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

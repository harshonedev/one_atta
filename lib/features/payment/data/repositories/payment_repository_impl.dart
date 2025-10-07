import 'package:dartz/dartz.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:one_atta/features/payment/domain/entities/payment_method_entity.dart';
import 'package:one_atta/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final paymentMethods = await remoteDataSource.getPaymentMethods();
      return Right(paymentMethods);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required List<String> contactNumbers,
    required String paymentMethod,
    String? couponCode,
    int? loyaltyPointsUsed,
    required double deliveryCharges,
    required double codCharges,
  }) async {
    try {
      final orderData = await remoteDataSource.createOrder(
        items: items,
        deliveryAddress: deliveryAddress,
        contactNumbers: contactNumbers,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        loyaltyPointsUsed: loyaltyPointsUsed,
        deliveryCharges: deliveryCharges,
        codCharges: codCharges,
      );
      return Right(orderData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final orderData = await remoteDataSource.verifyPayment(
        orderId: orderId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      return Right(orderData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> confirmCODOrder({
    required String orderId,
  }) async {
    try {
      final orderData = await remoteDataSource.confirmCODOrder(
        orderId: orderId,
      );
      return Right(orderData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> handlePaymentFailure({
    required String orderId,
    required String razorpayPaymentId,
    required Map<String, dynamic> error,
  }) async {
    try {
      final orderData = await remoteDataSource.handlePaymentFailure(
        orderId: orderId,
        razorpayPaymentId: razorpayPaymentId,
        error: error,
      );
      return Right(orderData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }
}

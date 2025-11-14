import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/exceptions.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/invoices/data/models/invoice_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<InvoiceModel> getInvoiceByOrderId(String orderId);
  Future<String> getInvoiceDownloadUrl(String invoiceId);
  Future<ShipmentDetailsModel> getTrackingDetails(String invoiceId);
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final ApiRequest apiRequest;
  final String? token;

  InvoiceRemoteDataSourceImpl({required this.apiRequest, this.token});

  @override
  Future<InvoiceModel> getInvoiceByOrderId(String orderId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.invoices}/order/$orderId',
      token: token,
    );

    return switch (response) {
      ApiSuccess(:final data) => InvoiceModel.fromJson(
        data['data'] as Map<String, dynamic>,
      ),
      ApiError(:final failure) => throw ServerException(
        message: failure.message,
      ),
    };
  }

  @override
  Future<String> getInvoiceDownloadUrl(String invoiceId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.invoices}/$invoiceId/download',
      token: token,
    );

    return switch (response) {
      ApiSuccess(:final data) => () {
        final downloadUrl = data['data']['download_url'] as String;
        // Convert relative URL to absolute URL
        return 'https://api.oneatta.com$downloadUrl';
      }(),
      ApiError(:final failure) => throw ServerException(
        message: failure.message,
      ),
    };
  }

  @override
  Future<ShipmentDetailsModel> getTrackingDetails(String invoiceId) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '${ApiEndpoints.invoices}/$invoiceId/tracking',
      token: token,
    );

    return switch (response) {
      ApiSuccess(:final data) => ShipmentDetailsModel.fromJson(
        data['data']['tracking'] as Map<String, dynamic>,
      ),
      ApiError(:final failure) => throw ServerException(
        message: failure.message,
      ),
    };
  }
}

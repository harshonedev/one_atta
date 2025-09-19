import 'package:one_atta/features/daily_essentials/data/models/product_model.dart';

class ProductsApiResponse {
  final bool success;
  final String message;
  final ProductsData data;

  const ProductsApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductsApiResponse.fromJson(Map<String, dynamic> json) {
    return ProductsApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProductsData {
  final List<ProductModel> products;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const ProductsData({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory ProductsData.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'] as List<dynamic>? ?? [];

    return ProductsData(
      products: productsJson
          .map((productJson) => ProductModel.fromJson(productJson))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class SingleProductApiResponse {
  final bool success;
  final String message;
  final ProductModel data;

  const SingleProductApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SingleProductApiResponse.fromJson(Map<String, dynamic> json) {
    return SingleProductApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductModel.fromJson(json['data'] ?? {}),
    );
  }
}

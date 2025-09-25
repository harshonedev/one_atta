import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:one_atta/features/customizer/data/datasources/customizer_remote_data_source.dart';
import 'package:one_atta/features/customizer/data/models/blend_analysis_model.dart';
import 'package:one_atta/features/customizer/data/models/blend_request_model.dart';
import 'package:one_atta/features/customizer/data/models/ingredient_model.dart';

class CustomizerRemoteDataSourceImpl implements CustomizerRemoteDataSource {
  final AuthLocalDataSource authLocalDataSource;
  final ApiRequest apiRequest;

  CustomizerRemoteDataSourceImpl({
    required this.authLocalDataSource,
    required this.apiRequest,
  });

  @override
  Future<BlendAnalysisModel> analyzeBlend(
    BlendRequestModel blendRequest,
  ) async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw UnauthorizedFailure('No authentication token found');
    }
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '${ApiEndpoints.blends}/custom/analyze',
      token: token,
      data: blendRequest.toJson(),
    );
    if (response is ApiSuccess) {
      try {
        return BlendAnalysisModel.fromJson(response.data);
      } catch (e) {
        throw ServerFailure('Failed to parse server response: $e');
      }
    } else if (response is ApiError) {
      throw response.failure;
    } else {
      throw ServerFailure('Unknown error occurred');
    }
  }

  @override
  Future<SavedBlendModel> saveBlend(SaveBlendModel saveBlendRequest) async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw UnauthorizedFailure('No authentication token found');
    }
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '${ApiEndpoints.baseUrl}/blends',
      token: token,
      data: saveBlendRequest.toJson(),
    );
    if (response is ApiSuccess) {
      try {
        final data = response.data['data']['blend'];
        return SavedBlendModel.fromJson(data);
      } catch (e) {
        throw ServerFailure('Failed to parse server response: $e');
      }
    } else if (response is ApiError) {
      throw response.failure;
    } else {
      throw ServerFailure('Unknown error occurred');
    }
  }

  @override
  Future<List<IngredientModel>> getIngredients() async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: ApiEndpoints.ingredients,
    );
    if (response is ApiSuccess) {
      try {
        final apiResponse = IngredientsApiResponse.fromJson(response.data);
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw apiResponse.message;
        }
      } catch (e) {
        throw ServerFailure('Failed to parse server response: $e');
      }
    } else if (response is ApiError) {
      throw response.failure;
    } else {
      throw ServerFailure('Unknown error occurred');
    }
  }
}

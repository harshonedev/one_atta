import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/network/api_request.dart';
import 'package:one_atta/features/recipes/data/datasources/recipes_remote_data_source.dart';
import 'package:one_atta/features/recipes/data/models/recipe.dart';
import 'package:one_atta/features/recipes/data/models/recipe_request_model.dart';

class RecipesRemoteDataSourceImpl implements RecipesRemoteDataSource {
  final ApiRequest apiRequest;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/recipes';

  RecipesRemoteDataSourceImpl({required this.apiRequest});

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: baseUrl,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List<dynamic>)
                  .map((recipe) => RecipeModel.fromJson(recipe))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch recipes',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/$id',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? RecipeModel.fromJson(response.data['data'])
            : throw Exception(response.data['message'] ?? 'Recipe not found'),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<RecipeModel> createRecipe(CreateRecipeModel recipe) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: baseUrl,
      data: recipe.toJson(),
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? RecipeModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to create recipe',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<RecipeModel> updateRecipe(String id, UpdateRecipeModel recipe) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.put,
      url: '$baseUrl/$id',
      data: recipe.toJson(),
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? RecipeModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to update recipe',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<RecipeModel> deleteRecipe(String id) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.delete,
      url: '$baseUrl/$id',
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? RecipeModel.fromJson(response.data['data'])
            : throw Exception(
                response.data['message'] ?? 'Failed to delete recipe',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<Map<String, dynamic>> toggleRecipeLike(String token, String id) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.post,
      url: '$baseUrl/$id/like',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? response.data
            : throw Exception(
                response.data['message'] ?? 'Failed to toggle recipe like',
              ),
      ApiError() => throw response.failure,
    };
  }

  @override
  Future<List<RecipeModel>> getLikedRecipes(String token) async {
    final response = await apiRequest.callRequest(
      method: HttpMethod.get,
      url: '$baseUrl/liked',
      token: token,
    );

    return switch (response) {
      ApiSuccess() =>
        response.data['success'] == true
            ? (response.data['data'] as List<dynamic>)
                  .map((recipe) => RecipeModel.fromJson(recipe))
                  .toList()
            : throw Exception(
                response.data['message'] ?? 'Failed to fetch liked recipes',
              ),
      ApiError() => throw response.failure,
    };
  }
}

import 'package:dio/dio.dart';
import 'package:one_atta/core/constants/constants.dart';
import 'package:one_atta/core/error/failures.dart';
import 'package:one_atta/features/recipes/data/datasources/recipes_remote_data_source.dart';
import 'package:one_atta/features/recipes/data/models/recipe.dart';
import 'package:one_atta/features/recipes/data/models/recipe_request_model.dart';

class RecipesRemoteDataSourceImpl implements RecipesRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '${ApiEndpoints.baseUrl}/recipes';

  RecipesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    try {
      final response = await dio.get(baseUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> recipesData = response.data['data'];
        return recipesData
            .map((recipe) => RecipeModel.fromJson(recipe))
            .toList();
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to fetch recipes',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      final message = e.response?.data?['message'] ?? 'Failed to fetch recipes';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await dio.get('$baseUrl/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return RecipeModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(response.data['message'] ?? 'Recipe not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      if (e.response?.statusCode == 404) {
        throw ServerFailure('Recipe not found');
      }

      final message = e.response?.data?['message'] ?? 'Failed to fetch recipe';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<RecipeModel> createRecipe(CreateRecipeModel recipe) async {
    try {
      final response = await dio.post(baseUrl, data: recipe.toJson());

      if (response.statusCode == 200 && response.data['success'] == true) {
        return RecipeModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to create recipe',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      if (e.response?.statusCode == 400) {
        final message = e.response?.data?['message'] ?? 'Validation error';
        throw ValidationFailure(message);
      }

      final message = e.response?.data?['message'] ?? 'Failed to create recipe';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<RecipeModel> updateRecipe(String id, UpdateRecipeModel recipe) async {
    try {
      // Set authorization header if available
      final response = await dio.put('$baseUrl/$id', data: recipe.toJson());

      if (response.statusCode == 200 && response.data['success'] == true) {
        return RecipeModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to update recipe',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      if (e.response?.statusCode == 401) {
        throw const UnauthorizedFailure('Not authorized, token failed');
      }

      if (e.response?.statusCode == 404) {
        throw ServerFailure('Recipe not found');
      }

      final message = e.response?.data?['message'] ?? 'Failed to update recipe';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<RecipeModel> deleteRecipe(String id) async {
    try {
      final response = await dio.delete('$baseUrl/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return RecipeModel.fromJson(response.data['data']);
      } else {
        throw ServerFailure(
          response.data['message'] ?? 'Failed to delete recipe',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Network connection failed');
      }

      if (e.response?.statusCode == 401) {
        throw const UnauthorizedFailure('No token provided');
      }

      if (e.response?.statusCode == 404) {
        throw ServerFailure('Recipe not found');
      }

      final message = e.response?.data?['message'] ?? 'Failed to delete recipe';
      throw ServerFailure(message);
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: $e');
    }
  }
}

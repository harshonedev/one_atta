# Ingredient API Integration Blueprint

## Overview
This blueprint documents the implementation of ingredient API integration in the One Atta customizer feature. The implementation follows clean architecture principles and strictly adheres to the provided Ingredient API documentation.

## Features Implemented

### 1. Domain Layer
- **IngredientEntity**: Represents the core business object for ingredients
  - Contains all fields from API response including `id`, `sku`, `name`, `description`, etc.
  - Includes nutritional information as a separate entity
  - Follows immutability principles with Equatable

- **IngredientRepository**: Abstract repository defining the contract
  - `getIngredients()`: Fetches ingredients from API
  - Returns `Either<Failure, List<IngredientEntity>>` for error handling

- **GetIngredientsUseCase**: Business logic for fetching ingredients
  - Encapsulates the use case of retrieving ingredients
  - Depends on IngredientRepository interface

### 2. Data Layer
- **IngredientModel**: Data transfer object matching API response
  - Extends IngredientEntity for type safety
  - Includes `fromJson()` and `toJson()` methods
  - Contains `IngredientsApiResponse` wrapper class
  - Handles API response structure with success/message/data pattern

- **IngredientRepositoryImpl**: Repository implementation
  - Uses CustomizerRemoteDataSource for API calls
  - Converts models to entities
  - Handles error propagation

- **API Integration**: Added to CustomizerRemoteDataSource
  - `getIngredients()` method calls `/api/ingredients` endpoint
  - No authentication required (as per API docs)
  - Includes proper error handling for different HTTP status codes

### 3. Presentation Layer
- **CustomizerBloc Updates**:
  - Added `LoadIngredients` event
  - Added `isLoadingIngredients` state
  - Added `_onLoadIngredients` method
  - Dynamic icon mapping for ingredient names
  - Converts API entities to presentation models

- **Icon Mapping**: Intelligent mapping of ingredient names to icons
  - Wheat → Grain icon
  - Chana/Gram → Seed icon  
  - Makka/Corn → Corn icon
  - Rice → Rice icon
  - And more with fallback to grain icon

## API Endpoint Used
```
GET /api/ingredients
```
- **Base URL**: https://api.oneatta.com/api
- **Authentication**: None required (public endpoint)
- **Response Format**: JSON with success/message/data structure

## File Structure
```
lib/features/customizer/
├── domain/
│   ├── entities/
│   │   └── ingredient_entity.dart       # Core business objects
│   ├── repositories/
│   │   └── ingredient_repository.dart   # Repository interface
│   └── usecases/
│       └── get_ingredients.dart         # Business logic use case
├── data/
│   ├── models/
│   │   └── ingredient_model.dart        # API response models
│   ├── repositories/
│   │   └── ingredient_repository_impl.dart # Repository implementation
│   └── datasources/
│       ├── customizer_remote_data_source.dart      # Updated interface
│       └── customizer_remote_data_source_impl.dart # Updated implementation
└── presentation/
    └── bloc/
        └── customizer_bloc.dart         # Updated with ingredient loading
```

## Dependency Injection Updates
Added to `injection_container.dart`:
- `GetIngredientsUseCase` registration
- `IngredientRepository` and `IngredientRepositoryImpl` registration  
- Updated `CustomizerBloc` to include `GetIngredientsUseCase` dependency

## API Response Structure Handled
```json
{
  "success": true,
  "message": "Fetched Ingredients", 
  "data": [
    {
      "id": "string",
      "sku": "string",
      "name": "string",
      "description": "string",
      "isSeasonal": boolean,
      "is_available": boolean,
      "price_per_kg": number,
      "ing_picture": "string",
      "nutritional_info": {
        "calories": number,
        "protein": number, 
        "carbs": number
      },
      "displayName": "string",
      "createdAt": "datetime",
      "updatedAt": "datetime"
    }
  ]
}
```

## Usage in UI
To load ingredients from API, dispatch the `LoadIngredients` event:
```dart
context.read<CustomizerBloc>().add(LoadIngredients());
```

The bloc will:
1. Set loading state to true
2. Call the use case to fetch ingredients
3. Convert entities to presentation models with appropriate icons
4. Update available ingredients list
5. Set loading state to false

## Error Handling
- Network errors: Displays user-friendly network failure messages
- Server errors: Displays server failure messages with HTTP status codes
- Validation errors: Displays validation failure messages
- Loading states: Shows loading indicators while fetching data

## Benefits of This Implementation

1. **Clean Architecture**: Separation of concerns with clear layer boundaries
2. **API Compliance**: Strictly follows the provided API documentation
3. **Type Safety**: Strong typing with domain entities and data models
4. **Error Handling**: Comprehensive error handling with Either pattern
5. **Testability**: All dependencies are injected and can be mocked
6. **Maintainability**: Clear separation makes code easy to maintain and extend
7. **Reusability**: Repository pattern allows for easy data source switching

## Future Enhancements
- Add caching for offline support
- Implement pagination if ingredient list grows large
- Add search/filter functionality for ingredients
- Consider lazy loading for ingredient images
- Add ingredient detail views with full nutritional information

## Notes
- The presentation layer Ingredient model is separate from the domain entity to maintain UI-specific concerns
- Icon mapping is handled at the presentation layer as it's a UI concern
- No authentication is required for ingredients endpoint as per API documentation
- The implementation is ready for both hardcoded ingredients (fallback) and API ingredients
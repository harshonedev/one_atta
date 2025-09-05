# Recipe Like Functionality Implementation

## Overview

This implementation adds a comprehensive recipe like functionality to the One Atta Flutter application with optimistic UI updates and proper error handling. The feature follows clean architecture principles and includes local state management with remote synchronization.

## Features Implemented

### 1. Optimistic UI Updates
- **Instant Feedback**: Like button responds immediately when tapped
- **Visual States**: Shows loading indicator while syncing with server
- **Error Recovery**: Reverts changes if server request fails

### 2. Complete Architecture Layers

#### Domain Layer
- **Repository Interface**: `RecipesRepository` with like methods
- **Use Cases**: 
  - `ToggleRecipeLike`: Handles like/unlike operations
  - `GetLikedRecipes`: Retrieves user's liked recipes
- **Entities**: Updated `RecipeEntity` with like-related properties

#### Data Layer
- **Remote Data Source**: API endpoints for like operations
  - `POST /recipes/:id/like` - Toggle like status
  - `GET /recipes/liked` - Get liked recipes
- **Repository Implementation**: Handles data flow and error mapping
- **Models**: Updated to support like functionality

#### Presentation Layer
- **BLoC State Management**: 
  - `RecipeDetailsBloc`: Manages like state with optimistic updates
  - `RecipesBloc`: Handles liked recipes loading
- **UI Components**:
  - Enhanced recipe details page with like button
  - Liked recipes page
  - Loading states and error handling

### 3. User Experience Features

#### Like Button States
- **Unliked**: Outlined heart icon
- **Liked**: Filled red heart icon  
- **Loading**: Circular progress indicator
- **Disabled**: During sync operations

#### Real-time Updates
- Like count updates immediately
- Visual feedback on button state
- Error messages for failed operations
- Automatic reversion on errors

#### Liked Recipes Page
- Dedicated page for user's liked recipes
- Empty state with call-to-action
- Same recipe card UI as main recipes

## API Integration

### Authentication Required
- Like/unlike operations require Bearer token
- Liked recipes endpoint requires authentication
- Proper error handling for unauthorized access

### Server Response Format
```json
{
  "success": true,
  "message": "Recipe liked",
  "data": {
    "isLiked": true,
    "likesCount": 26,
    "message": "Recipe liked"
  }
}
```

## Technical Implementation

### Optimistic Updates Flow
1. User taps like button
2. UI immediately updates (like count +/- 1, icon changes)
3. Show loading indicator
4. Send request to server
5. On success: Keep optimistic changes
6. On failure: Revert to previous state + show error

### State Management
```dart
class RecipeDetailsLoaded extends RecipeDetailsState {
  final RecipeEntity recipe;
  final bool isFavorite;
  final bool isLiked;        // Current like status
  final int likesCount;      // Current like count
  final bool isLiking;       // Loading state
}
```

### Error Handling
- Network failures
- Server errors (404, 401, etc.)
- Optimistic update reversal
- User-friendly error messages

## Files Modified/Created

### Domain Layer
- `lib/features/recipes/domain/repositories/recipes_repository.dart`
- `lib/features/recipes/domain/usecases/toggle_recipe_like.dart`
- `lib/features/recipes/domain/usecases/get_liked_recipes.dart`

### Data Layer
- `lib/features/recipes/data/datasources/recipes_remote_data_source.dart`
- `lib/features/recipes/data/datasources/recipes_remote_data_source_impl.dart`
- `lib/features/recipes/data/repositories/recipes_repository_impl.dart`

### Presentation Layer
- `lib/features/recipes/presentation/bloc/recipe_details_bloc.dart`
- `lib/features/recipes/presentation/bloc/recipe_details_event.dart`
- `lib/features/recipes/presentation/bloc/recipe_details_state.dart`
- `lib/features/recipes/presentation/bloc/recipes_bloc.dart`
- `lib/features/recipes/presentation/bloc/recipes_event.dart`
- `lib/features/recipes/presentation/bloc/recipes_state.dart`
- `lib/features/recipes/presentation/pages/recipe_details_page.dart`
- `lib/features/recipes/presentation/pages/liked_recipes_page.dart`

### Tests
- `test/features/recipes/presentation/bloc/recipe_like_test.dart`

## Usage Examples

### Like a Recipe
```dart
// In RecipeDetailsPage
IconButton(
  onPressed: state.isLiking ? null : () => _toggleLike(context, recipe.id),
  icon: state.isLiking 
      ? CircularProgressIndicator()
      : Icon(state.isLiked ? Icons.favorite : Icons.favorite_border),
)

void _toggleLike(BuildContext context, String recipeId) {
  context.read<RecipeDetailsBloc>().add(LikeRecipe(recipeId));
}
```

### Load Liked Recipes
```dart
// In LikedRecipesPage
BlocProvider(
  create: (context) => RecipesBloc(repository: di.sl())
    ..add(const LoadLikedRecipes()),
  child: const LikedRecipesView(),
)
```

## Testing

The implementation includes unit tests for:
- State management logic
- Optimistic updates
- Error recovery
- Like count calculations

Run tests with:
```bash
flutter test test/features/recipes/presentation/bloc/recipe_like_test.dart
```

## Future Enhancements

1. **Offline Support**: Cache liked recipes locally
2. **Batch Operations**: Sync multiple likes when online
3. **Real-time Updates**: WebSocket for live like count updates
4. **Social Features**: See who liked recipes
5. **Analytics**: Track like patterns for recommendations

## API Dependencies

Requires backend implementation of:
- `POST /recipes/:id/like` - Toggle like endpoint
- `GET /recipes/liked` - Get user's liked recipes
- JWT authentication for user identification

See `docs/RECIPE_API_DOCS.md` for complete API specification.

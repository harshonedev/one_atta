import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_atta/features/blends/domain/repositories/blends_repository.dart';
import 'package:one_atta/features/cart/domain/entities/cart_item_entity.dart';
import 'package:one_atta/features/daily_essentials/domain/repositories/daily_essentials_repository.dart';

class ItemCubit extends Cubit<ItemState> {
  final BlendsRepository _blendsRepository;
  final DailyEssentialsRepository _dailyEssentialsRepository;

  ItemCubit({
    required BlendsRepository blendsRepository,
    required DailyEssentialsRepository dailyEssentialsRepository,
  }) : _blendsRepository = blendsRepository,
       _dailyEssentialsRepository = dailyEssentialsRepository,
       super(ItemInitial());

  Future<void> loadItem(String itemId, String itemType, int weight) async {
    emit(ItemLoading());
    try {
      if (itemType.toLowerCase() == 'blend') {
        final result = await _blendsRepository.getBlendDetails(itemId);
        result.fold((failure) => emit(ItemError(failure.message)), (blend) {
          final cartItem = CartItemEntity(
            productId: blend.id,
            productName: blend.name,
            productType: 'blend',
            quantity: 1,
            price: blend.pricePerKg * weight,
            mrp: blend.pricePerKg * weight,
            pricePerKg: blend.pricePerKg,
            imageUrl: blend.imageUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            weightInKg: weight,
          );
          emit(ItemLoaded(cartItem));
        });
      } else if (itemType.toLowerCase() == 'product') {
        final result = await _dailyEssentialsRepository.getProductById(itemId);
        result.fold((failure) => emit(ItemError(failure.message)), (essential) {
          final cartItem = CartItemEntity(
            productId: essential.id,
            productName: essential.name,
            productType: 'product',
            quantity: 1,
            weightInKg: weight,
            price: essential.price * weight,
            pricePerKg: essential.price,
            mrp: essential.originalPrice,
            imageUrl: essential.imageUrls.isNotEmpty
                ? essential.imageUrls[0]
                : '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          emit(ItemLoaded(cartItem));
        });
      } else {
        emit(ItemError('Unknown item type'));
      }
    } catch (e) {
      emit(ItemError('Failed to load item details'));
    }
  }
}

abstract class ItemState extends Equatable {}

class ItemInitial extends ItemState {
  @override
  List<Object> get props => [];
}

class ItemLoading extends ItemState {
  @override
  List<Object> get props => [];
}

class ItemLoaded extends ItemState {
  final CartItemEntity item;

  ItemLoaded(this.item);

  @override
  List<Object> get props => [item];
}

class ItemError extends ItemState {
  final String message;

  ItemError(this.message);

  @override
  List<Object> get props => [message];
}

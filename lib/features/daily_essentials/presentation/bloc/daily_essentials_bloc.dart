import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:one_atta/features/daily_essentials/domain/repositories/daily_essentials_repository.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_event.dart';
import 'package:one_atta/features/daily_essentials/presentation/bloc/daily_essentials_state.dart';

class DailyEssentialsBloc
    extends Bloc<DailyEssentialsEvent, DailyEssentialsState> {
  final DailyEssentialsRepository repository;
  final Logger logger = Logger();

  DailyEssentialsBloc({required this.repository})
    : super(const DailyEssentialsInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadProductById>(_onLoadProductById);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<DailyEssentialsState> emit,
  ) async {
    emit(const DailyEssentialsLoading());

    final result = await repository.getAllProducts(
      isSeasonal: event.isSeasonal,
      search: event.search,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(
        DailyEssentialsError(message: failure.message, failure: failure),
      ),
      (products) => emit(DailyEssentialsLoaded(products: products)),
    );
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<DailyEssentialsState> emit,
  ) async {
    emit(const ProductDetailLoading());

    final result = await repository.getProductById(event.id);

    result.fold((failure) {
      logger.e('Error loading product by ID: ${failure.message}');
      emit(ProductDetailError(message: failure.message, failure: failure));
    }, (product) => emit(ProductDetailLoaded(product: product)));
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<DailyEssentialsState> emit,
  ) async {
    if (state is DailyEssentialsLoaded) {
      final currentState = state as DailyEssentialsLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      final result = await repository.getAllProducts();

      result.fold(
        (failure) => emit(
          DailyEssentialsError(message: failure.message, failure: failure),
        ),
        (products) => emit(DailyEssentialsLoaded(products: products)),
      );
    } else {
      // If not currently loaded, perform initial load
      add(const LoadAllProducts());
    }
  }
}

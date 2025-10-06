# Separated Cart and Delivery Blocs Usage Guide

This guide shows how to use the separated Cart and Delivery blocs in your Flutter application.

## Overview

The delivery functionality has been separated from the cart to maintain single responsibility principle:

- **CartBloc**: Handles cart operations (add, remove, update quantities, coupons, loyalty points)
- **DeliveryBloc**: Handles delivery operations (pincode check, delivery charges, COD, ETA)

## Setup

### 1. Dependencies Injection

```dart
// In your dependency injection setup
class AppDependencies {
  // Data sources
  late final DeliveryRemoteDataSource deliveryRemoteDataSource;
  
  // Services
  late final DeliveryService deliveryService;
  
  // Cart dependencies (existing)
  late final CartRepository cartRepository;
  // ... other cart dependencies
  
  void init() {
    // Initialize delivery dependencies
    deliveryRemoteDataSource = DeliveryRemoteDataSourceImpl(
      client: http.Client(),
      baseUrl: 'your-api-base-url',
    );
    
    deliveryService = DeliveryServiceImpl(
      remoteDataSource: deliveryRemoteDataSource,
    );
    
    // Initialize cart dependencies (existing)
    // ...
  }
}
```

### 2. Bloc Provider Setup

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Cart Bloc
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(
            getCartUseCase: dependencies.getCartUseCase,
            addToCartUseCase: dependencies.addToCartUseCase,
            // ... other cart dependencies
          ),
        ),
        
        // Delivery Bloc
        BlocProvider<DeliveryBloc>(
          create: (context) => DeliveryBloc(
            deliveryService: dependencies.deliveryService,
          ),
        ),
      ],
      child: MaterialApp(
        // Your app
      ),
    );
  }
}
```

## Usage Examples

### 1. Cart Page with Delivery Integration

```dart
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _pincodeController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Column(
        children: [
          // Delivery Section
          _buildDeliverySection(),
          
          // Cart Items Section
          _buildCartSection(),
          
          // Cart Summary Section
          _buildCartSummary(),
        ],
      ),
    );
  }
  
  Widget _buildDeliverySection() {
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, deliveryState) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Information', 
                     style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 12),
                
                // Pincode Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        decoration: InputDecoration(
                          labelText: 'Enter Pincode',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _checkDelivery(),
                      child: Text('Check'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Delivery Status
                _buildDeliveryStatus(deliveryState),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDeliveryStatus(DeliveryState state) {
    if (state is DeliveryLoading) {
      return Row(
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(width: 12),
          Text('Checking delivery...'),
        ],
      );
    }
    
    if (state is DeliveryLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery Available
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Delivery available'),
            ],
          ),
          SizedBox(height: 8),
          
          // ETA
          Text('Expected delivery: ${state.etaDisplay}'),
          SizedBox(height: 8),
          
          // Express Delivery Toggle
          if (state.deliveryInfo?.zoneInfo.expressDelivery.available == true)
            CheckboxListTile(
              title: Text('Express Delivery (+₹${state.deliveryInfo!.zoneInfo.expressDelivery.charges})'),
              subtitle: Text(state.deliveryInfo!.zoneInfo.expressDelivery.etaDisplay),
              value: state.isExpressDelivery,
              onChanged: (value) {
                context.read<DeliveryBloc>().add(
                  ToggleExpressDelivery(isExpress: value ?? false),
                );
              },
            ),
          
          // COD Available
          if (state.codAvailable)
            Row(
              children: [
                Icon(Icons.money, color: Colors.orange),
                SizedBox(width: 8),
                Text('Cash on Delivery available'),
              ],
            ),
        ],
      );
    }
    
    if (state is DeliveryNotAvailable) {
      return Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Delivery not available'),
        ],
      );
    }
    
    if (state is DeliveryError) {
      return Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Expanded(child: Text(state.message)),
        ],
      );
    }
    
    return SizedBox.shrink();
  }
  
  Widget _buildCartSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        if (cartState is CartLoaded) {
          return Expanded(
            child: ListView.builder(
              itemCount: cartState.cart.items.length,
              itemBuilder: (context, index) {
                final item = cartState.cart.items[index];
                return ListTile(
                  leading: Image.network(item.imageUrl),
                  title: Text(item.name),
                  subtitle: Text('₹${item.price} x ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            UpdateItemQuantity(
                              productId: item.productId,
                              quantity: item.quantity - 1,
                            ),
                          );
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            UpdateItemQuantity(
                              productId: item.productId,
                              quantity: item.quantity + 1,
                            ),
                          );
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
  
  Widget _buildCartSummary() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<DeliveryBloc, DeliveryState>(
          builder: (context, deliveryState) {
            if (cartState is CartLoaded) {
              // Calculate total including delivery
              double deliveryCharges = 0.0;
              if (deliveryState is DeliveryLoaded) {
                deliveryCharges = deliveryState.deliveryCharges;
              }
              
              final finalTotal = cartState.toPayTotal + deliveryCharges;
              
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', 
                           style: Theme.of(context).textTheme.titleMedium),
                      Divider(),
                      
                      _summaryRow('Subtotal', '₹${cartState.itemTotal}'),
                      if (cartState.couponDiscount > 0)
                        _summaryRow('Coupon Discount', '-₹${cartState.couponDiscount}'),
                      if (cartState.loyaltyDiscount > 0)
                        _summaryRow('Loyalty Discount', '-₹${cartState.loyaltyDiscount}'),
                      if (deliveryCharges > 0)
                        _summaryRow('Delivery Charges', '₹$deliveryCharges'),
                      
                      Divider(),
                      _summaryRow('Total', '₹$finalTotal', isTotal: true),
                      
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _proceedToCheckout(),
                          child: Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }
  
  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal 
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  void _checkDelivery() {
    final pincode = _pincodeController.text.trim();
    if (pincode.isNotEmpty) {
      final cartState = context.read<CartBloc>().state;
      double orderValue = 0.0;
      
      if (cartState is CartLoaded) {
        orderValue = cartState.itemTotal;
      }
      
      context.read<DeliveryBloc>().add(
        CheckDeliveryAvailability(
          pincode: pincode,
          orderValue: orderValue,
        ),
      );
    }
  }
  
  void _proceedToCheckout() {
    // Navigate to checkout with both cart and delivery information
    final cartState = context.read<CartBloc>().state;
    final deliveryState = context.read<DeliveryBloc>().state;
    
    if (cartState is CartLoaded && deliveryState is DeliveryLoaded) {
      Navigator.pushNamed(
        context,
        '/checkout',
        arguments: {
          'cart': cartState,
          'delivery': deliveryState,
        },
      );
    }
  }
}
```

### 2. Listening to Both Blocs

```dart
class CartSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryBloc, DeliveryState>(
      listener: (context, deliveryState) {
        // When delivery state changes, refresh cart calculations
        if (deliveryState is DeliveryLoaded) {
          // You might want to update cart totals or show notifications
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(deliveryState.deliveryMessage)),
          );
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BlocBuilder<DeliveryBloc, DeliveryState>(
            builder: (context, deliveryState) {
              // Build UI based on both states
              return _buildSummary(cartState, deliveryState);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildSummary(CartState cartState, DeliveryState deliveryState) {
    // Implementation based on both states
    return Container(); // Your implementation
  }
}
```

## Key Benefits of Separation

1. **Single Responsibility**: Each bloc handles one concern
2. **Reusability**: Delivery bloc can be used in other features
3. **Testability**: Easier to test individual concerns
4. **Maintainability**: Changes to delivery logic don't affect cart logic
5. **Performance**: More granular state updates

## Communication Between Blocs

When you need both blocs to work together:

1. **Use BlocListener**: Listen to one bloc's state changes
2. **Use BlocBuilder**: Build UI based on multiple bloc states
3. **Use MultiBlocProvider**: Provide both blocs to widget tree
4. **Pass data**: Use events to pass data between blocs when needed

## Error Handling

Each bloc handles its own errors:

```dart
BlocListener<DeliveryBloc, DeliveryState>(
  listener: (context, state) {
    if (state is DeliveryError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery Error: ${state.message}')),
      );
    }
  },
  child: YourWidget(),
)
```

This separation provides a cleaner, more maintainable architecture while still allowing the blocs to work together when needed.
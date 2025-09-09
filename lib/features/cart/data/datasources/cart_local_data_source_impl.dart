import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:one_atta/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:one_atta/features/cart/data/models/cart_item_model.dart';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _tableName = 'cart_items';
  static const String _databaseName = 'cart_database.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL UNIQUE,
        product_name TEXT NOT NULL,
        product_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');

    return List.generate(maps.length, (i) {
      return CartItemModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> insertCartItem(CartItemModel item) async {
    final db = await database;

    // Check if item already exists
    final existingItem = await getCartItemByProductId(item.productId);

    if (existingItem != null) {
      // Update quantity if item exists
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
        updatedAt: DateTime.now(),
      );
      await updateCartItem(updatedItem);
    } else {
      // Insert new item
      await db.insert(
        _tableName,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> updateCartItem(CartItemModel item) async {
    final db = await database;
    await db.update(
      _tableName,
      item.toMap(),
      where: 'product_id = ?',
      whereArgs: [item.productId],
    );
  }

  @override
  Future<void> deleteCartItem(String productId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> clearCart() async {
    final db = await database;
    await db.delete(_tableName);
  }

  @override
  Future<int> getCartItemCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM $_tableName',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  @override
  Future<CartItemModel?> getCartItemByProductId(String productId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return CartItemModel.fromMap(maps.first);
    }
    return null;
  }
}

import 'package:app_ecommerce/providers/cart_provider.dart';
import 'package:app_ecommerce/providers/category_provider.dart';
import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/providers/user_provider.dart';
import 'package:app_ecommerce/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';
import '../providers/search_provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _currentQuery = '';
  String? token;
  String? userRole;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // 3 tabs: Category, Product, Cart
    _searchController.addListener(_onSearchChanged);

    Future.delayed(Duration.zero, () async {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await productProvider.fetchProducts();
      await categoryProvider.fetchCategories();
      await cartProvider.fetchCart(userProvider.userId as String);
    });
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text.trim();
    if (newQuery != _currentQuery) {
      _currentQuery = newQuery;
      setState(() {});
      // Gọi cả 3 hàm search khi query thay đổi
      if (_currentQuery.isEmpty) {
        Provider.of<SearchProvider>(context, listen: false).clearAllSearches();
      } else {
        // Gọi search cho Categories, Products
        Provider.of<SearchProvider>(
          context,
          listen: false,
        ).searchCategories(_currentQuery);

        Provider.of<SearchProvider>(
          context,
          listen: false,
        ).searchProducts(_currentQuery);
        // Gọi search cho CartItems (cần context và có thể cần userId nếu là Admin)
        // Nếu bạn muốn admin có thể search giỏ hàng của người khác từ đây,
        // bạn cần một cách để nhập user_id (ví dụ: một trường input khác hoặc nút chọn user).
        // Với mục đích demo, chúng ta chỉ search giỏ hàng của user đang đăng nhập.
        Provider.of<SearchProvider>(
          context,
          listen: false,
        ).searchCartItems(context, _currentQuery);
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (ctx) => BottomNav()));
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm mọi thứ...',
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.black),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<SearchProvider>(
                          context,
                          listen: false,
                        ).clearAllSearches();
                      },
                    )
                    : null,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Danh mục'),
            Tab(text: 'Sản phẩm'),
            Tab(text: 'Giỏ hàng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryResultsTab(),
          _buildProductResultsTab(),
          _buildCartResultsTab(),
        ],
      ),
    );
  }

  //giá tiền
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  Widget _buildCategoryResultsTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final allCategories = categoryProvider.categories;

        // Lọc theo từ khóa _currentQuery
        final filteredCategories =
            _currentQuery.isEmpty
                ? allCategories
                : allCategories
                    .where(
                      (category) => category.name.toLowerCase().contains(
                        _currentQuery.toLowerCase(),
                      ),
                    )
                    .toList();

        if (filteredCategories.isEmpty && _currentQuery.isNotEmpty) {
          return const Center(child: Text('Không tìm thấy danh mục nào.'));
        }

        if (filteredCategories.isEmpty && _currentQuery.isEmpty) {
          return const Center(child: Text('Nhập từ khóa để tìm danh mục.'));
        }

        return ListView.builder(
          itemCount: filteredCategories.length,
          itemBuilder: (context, index) {
            final category = filteredCategories[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(category.name),
                subtitle: Text(category.description ?? 'Không có mô tả'),
                onTap: () {
                  print('Tìm kiếm danh mục: ${category.name}');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductResultsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final allProducts = productProvider.products;

        print(allProducts.runtimeType); // ✅ thêm dòng này để debug
        // Lọc sản phẩm theo từ khóa tìm kiếm _currentQuery (không phân biệt hoa thường)
        final filteredProducts =
            _currentQuery.isEmpty
                ? allProducts
                : allProducts
                    .where(
                      (product) => product.name.toLowerCase().contains(
                        _currentQuery.toLowerCase(),
                      ),
                    )
                    .toList();

        if (filteredProducts.isEmpty && _currentQuery.isNotEmpty) {
          return const Center(child: Text('Không tìm thấy sản phẩm nào.'));
        }
        if (filteredProducts.isEmpty && _currentQuery.isEmpty) {
          return const Center(child: Text('Nhập từ khóa để tìm sản phẩm.'));
        }

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final products = filteredProducts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading:
                    products.image != null
                        ? Image.network(
                          products.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                        )
                        : const Icon(Icons.shopping_bag, size: 50),
                title: Text(products.name),
                subtitle: Text(
                  "Giá: ${formatCurrency(products.price.toStringAsFixed(0))}",
                ),
                onTap: () {
                  print('Tìm kiếm sản phẩm: ${products.name}');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartResultsTab() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.itemCart.isEmpty) {
          return const Center(child: Text('Giỏ hàng trống.'));
        }

        // Lọc giỏ hàng theo từ khóa tìm kiếm _currentQuery (không phân biệt hoa thường)
        final filteredItems =
            _currentQuery.isEmpty
                ? cartProvider.itemCart
                : cartProvider.itemCart
                    .where(
                      (item) => item.productName.toLowerCase().contains(
                        _currentQuery.toLowerCase(),
                      ),
                    )
                    .toList();

        if (filteredItems.isEmpty) {
          return const Center(
            child: Text('Không tìm thấy sản phẩm nào trong giỏ hàng.'),
          );
        }

        return ListView.builder(
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final cartItem = filteredItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading:
                    cartItem.productImage != null
                        ? Image.network(
                          cartItem.productImage!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                        )
                        : const Icon(Icons.shopping_cart, size: 50),
                title: Text(
                  '${cartItem.productName} (SL: ${cartItem.quantity})',
                ),
                subtitle: Text(
                  "Giá: ${formatCurrency(cartItem.price.toStringAsFixed(0))}",
                ),
                onTap: () {
                  print('Tìm kiếm sản phẩm trong giỏ: ${cartItem.productName}');
                  // Có thể xử lý thêm khi nhấn vào sản phẩm trong giỏ hàng
                },
              ),
            );
          },
        );
      },
    );
  }
}

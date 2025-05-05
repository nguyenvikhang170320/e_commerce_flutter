
import 'package:app_ecommerce/screens/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/notification_provider.dart';
import '../services/share_preference.dart';

class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  String? token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    token = await SharedPrefsHelper.getToken();
    print('Token doanh thu: $token');
  }
  String formatCurrency(String amountStr) {
    final amount = double.tryParse(amountStr) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        actions: <Widget>[
          Consumer<NotificationProvider>(
            builder:
                (ctx, provider, _) => Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ],
      ),

      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.favoriteProducts.isEmpty) {
            return const Center(
              child: Text('Không có sản phẩm yêu thích nào.'),
            );
          } else {
            return ListView.builder(
              itemCount: favoriteProvider.favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProvider.favoriteProducts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text('Giá: ${formatCurrency(product.price.toStringAsFixed(0))}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => favoriteProvider.toggleFavorite(product),

                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

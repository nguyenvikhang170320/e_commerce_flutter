import 'package:app_ecommerce/providers/product_provider.dart';
import 'package:app_ecommerce/screens/product_page.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FeaturedProductList extends StatefulWidget {
  @override
  State<FeaturedProductList> createState() => _FeaturedProductListState();
}

class _FeaturedProductListState extends State<FeaturedProductList> {
  List products = [];
  // Thêm hàm format VNĐ
  String formatCurrency(num amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  @override
  void initState() {
    super.initState();
    loadFeatured();
  }

  void loadFeatured() async {
    final data = await ProductService.fetchFeaturedProducts(); // từ API
    print("⭐ Dữ liệu sản phẩm nổi bật: $data");
    setState(() => products = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return GestureDetector(
          onTap: () {
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).fetchProducts();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => ProductScreen()),
            );
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Image.network(prod['image'], width: 50, height: 50),
              title: Text(prod['name']),
              subtitle: Text(formatCurrency(double.parse(prod['price']))),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text("+Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: StadiumBorder(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

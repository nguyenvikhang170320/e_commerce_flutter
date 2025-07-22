import 'package:app_ecommerce/screens/flashsale_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flash_sale_provider.dart';


class FlashSalePage extends StatefulWidget {
  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<FlashSaleProvider>(context, listen: false).fetchFlashSales();
    });
  }
  @override
  Widget build(BuildContext context) {
    final flashSaleProvider = Provider.of<FlashSaleProvider>(context);
    final flashSales = flashSaleProvider.flashSales;
    print("Số lượng flash sales: ${flashSales.length}");
    print("flash sales: ${flashSales}");
    return Scaffold(
      appBar: AppBar(title: Text("⚡ Sản phẩm giảm giá")),
      body: flashSales.isEmpty
          ? Center(child: Text('Không có sản phẩm giảm giá'))
          : GridView.builder(
        padding: EdgeInsets.all(12),
        itemCount: flashSales.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 32,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (ctx, i) {
          final flashSale = flashSales[i];
          return FlashSaleCard(flashSale: flashSale!);
        },

      ),
    );
  }
}

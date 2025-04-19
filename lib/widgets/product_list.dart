import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/mock_data.dart';

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Image.asset(prod['image'] as String, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(prod['name'] as String),
            subtitle: Text("\$${prod['price']}"),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text("+Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: StadiumBorder(),
              ),
            ),
          ),
        );
      },
    );
  }
}

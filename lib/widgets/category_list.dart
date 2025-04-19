import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/mock_data.dart';

class CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.shade100,
                child: Icon(cat['icon'] as IconData?, color: Colors.orange),
              ),
              SizedBox(height: 5),
              Text(cat['name'] as String, style: TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }
}

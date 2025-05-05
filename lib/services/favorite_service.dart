import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/products.dart';

class FavoriteService {


  Future<void> addToFavorites(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/favorites'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'userId': userId,
        'productId': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to favorites');
    }
  }

  Future<List<Product>> getFavorites(int userId) async {
    final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/favorites/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get favorites');
    }
  }

  Future<void> removeFromFavorites(int userId, int productId) async {
    final response = await http.delete(
      Uri.parse('${dotenv.env['BASE_URL']}/favorites'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'userId': userId,
        'productId': productId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from favorites');
    }
  }
}
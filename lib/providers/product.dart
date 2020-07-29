import 'package:flutter/material.dart';

class Product with ChangeNotifier{

  final String productId;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.productId,
      @required this.title,
      @required this.description,
      @required this.imageUrl,
      @required this.price,
      this.isFavorite = false});

      void toggleFavoriteStatus() {
        isFavorite = !isFavorite;
        notifyListeners();
      }
}

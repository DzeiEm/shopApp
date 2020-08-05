import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/modal/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import '../modal/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;

// tai yra kopija _tems'u
  List<Product> get items {
    // if(_showFavoritesOnly){
    // return _items.where((prodItem) => prodItem.isFavorite).toList();
    return [..._items];
  }

  List<Product> get fovoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String productId) {
    return _items.firstWhere((prod) => prod.productId == productId);
  }

  void showFavoritesOnly() {
    // _showFavoritesOnly = true;
    // notifyListeners();
  }

  void showAll() {
    // _showFavoritesOnly = false;
    // notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://shopapp-99722.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      //  perduodam dynamic nes ten eina map'as. jei neidesim dynamic dart'as keiksis
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null){
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
              productId: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              isFavorite: prodData['isFavorite'],
              imageUrl: prodData['imageUrl']),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    // paskutinis zodis products yra dadedas nuo manes..
    // pridedantt ji.. firebase susikurtu collectionas
    //  dauguma API nepraso .json pabaigoje - bet firebase praso
    const url = 'https://shopapp-99722.firebaseio.com/products.json';
    try {
      // kadangi turime palaukti kol bus surista su serveriu.. kai tik serveris pasiruoses,
      //  tode tada -then- irasome nauja product'a
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'imageUrl': product.imageUrl,
        }),
      );

      final newProduct = Product(
        //  kode ID per DateTime.now???
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        // per -name'a- issitraukia tam tikra id kuri sukuria firebase'as.
        productId: json.decode(response.body)['name'],
      );

      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final productIndex =
        _items.indexWhere((prod) => prod.productId == productId);

    if (productIndex >= 0) {
      final url = 'https://shopapp-99722.firebaseio.com/products/$productId.json';
      // visi keys zodeliai turi sutapti su zodeliais firebase'e
      // ca noriu update'inti tik tuos laukus kuriuos irasiau, like turi likti kaip yra
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));

      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = 'https://shopapp-99722.firebaseio.com/products/$productId.json';
    // removeWhere prabegs per visus product'o id ir suras product'o id kuri mes paduodam kaip argumenta
    final existingproductIndex =
        _items.indexWhere((prod) => prod.productId == productId);
    var existingProduct = _items[existingproductIndex];

//  sitas removeAt(existingproductIndex, istrins tik is listo, bet in memory tai vis dar existuoja ir reference irgi yra)
    _items.removeAt(existingproductIndex);
    notifyListeners();

//  sitas reiskia, jei trindama neiskils jokiu problemu - istrink ta product'a
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // jei iskilo kazkokiu problemu - tiesiog idek atgal
      _items.insert(existingproductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // clipRrect -> atskiras widget'as kuris duoda galimybe uzroundint boarder'ius
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    print('product rebuilds');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            // boxFit.cover - islygina kiekvieno image'o size'a
            fit: BoxFit.cover,
          ),
          onTap: () {
            // paspaudus ant image'o turi nu_leadint'i i ProductDettailScreen'a
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.productId,
            );
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              // jei nebuvo paspausta-> tegu uzsiispalvina, jei buvo uzspalvintas tegu atsispalvina
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
            child: Text('Never changes!'),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.productId, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  elevation: 4,
                  content: Text(
                    'Added to the cart',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 5),
                  action: SnackBarAction(label: 'UNDO', onPressed: (){
                    cart.removeSingleIdtem(product.productId);
                  },),
                ),
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';


class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final String title;
  final int quantity;

  CartItem(this.id, this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    // Dismissible naudojam tam kad paswip'inus car'a galima butu istrinti.
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId); 
      },
      key: ValueKey(id),
      background: Container(
        color: Colors.pinkAccent,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 50,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(10),
    
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}

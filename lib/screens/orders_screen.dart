import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import '../providers/order.dart' show Order;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/order';

  
  @override
  Widget build(BuildContext context) {
    print('building prders');
    // final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Order>(context, listen: false).fetchAndSetOrders(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                  child: Text('Error occured!'),
                );
              } else {
                return Consumer<Order>(
                  builder: (context, orderData, child) => ListView.builder(
                      itemBuilder: (context, index) =>
                          OrderItem(orderData.orders[index]),
                      itemCount: orderData.orders.length),
                );
              }
            }
          }),
    );
  }
}

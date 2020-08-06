import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/providers/order.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';

import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //  PROVIDERS LIST
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        //  auth provider'is turetu buti auksciau uz proxyProvider'i, nes
        //  proxy provider'is pasiziuri i anksciau pateiktus provider'ius randa "auth" ir paduoda sau i builder'i
        //  kai tuk "auth" objectas pasikeis.. bus perbildintas ir products
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) =>
              //  cia sukurs nauja producta su token'u.
              Products(auth.token, auth.userId,
                  previousProducts == null ? [] : previousProducts.items),
          // create: (BuildContext context) {},
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          // create: (BuildContext context) {},
          update: (context, auth, previousOrders) => Order(auth.token,
              auth.userId, previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      //  esme sito consumer'io, kai tik pasikeicia widget'as, tada build'as pasileidzia dar karta
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            accentColor: Colors.pinkAccent,
            errorColor: Colors.redAccent,
            fontFamily: 'Lato',
          ),
          //  jei zmogus nera authentikuotas, rodyti registracijos screen'a
          //  jei yra auth, tada rodyti product'u screen'a
          home: auth.isAuth
              ? ProductsOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProductsOverViewScreen.routeName: (ctx) => ProductsOverViewScreen(),
          },
        ),
      ),
    );
  }
}

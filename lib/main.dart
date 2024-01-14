import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final String imageUrl;
  final String name;
  final double price;
  bool isInCart;
  int quantity; // Added quantity property

  Product({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.isInCart = false,
    this.quantity = 1, // Default quantity is set to 1
  });
}

class Cart with ChangeNotifier {
  List<Product> _cartItems = [];

  List<Product> get cartItems => _cartItems;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }

  void addToCart(Product product) {
    Product existingProduct = _cartItems.firstWhere(
      (item) => item == product,
      orElse: () => product,
    );

    if (_cartItems.contains(existingProduct)) {
      existingProduct.quantity += 1;
    } else {
      product.isInCart = true;
      product.quantity = 1;
      _cartItems.add(product);
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    product.quantity -= 1;
    if (product.quantity <= 0) {
      product.isInCart = false;
      _cartItems.remove(product);
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.forEach((product) => product.isInCart = false);
    _cartItems.clear();
    notifyListeners();
  }
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Cart(),
      child: MaterialApp(
        title: 'E-commerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ProductListScreen(),
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Phones'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: ProductList(),
    );
  }
}

class ProductList extends StatelessWidget {
  final List<Product> products = [
    Product(imageUrl: 'assets/iphone.jpg', name: 'iPhone 13', price: 999.99),
    Product(imageUrl: 'assets/samsung.jpg', name: 'Samsung Galaxy S21', price: 899.99),
    Product(imageUrl: 'assets/pixel.jpg', name: 'Google Pixel 6', price: 799.99),
    Product(imageUrl: 'assets/oneplus.jpg', name: 'OnePlus 9', price: 699.99),
    Product(imageUrl: 'assets/xiaomi.jpg', name: 'Xiaomi Mi 11', price: 599.99),
    Product(imageUrl: 'assets/oppo.jpg', name: 'Oppo Find X3', price: 749.99),
    Product(imageUrl: 'assets/huawei.jpg', name: 'Huawei P40', price: 649.99),
    Product(imageUrl: 'assets/sony.jpg', name: 'Sony Xperia 5 III', price: 849.99),
    Product(imageUrl: 'assets/lg.jpg', name: 'LG Velvet', price: 499.99),
    Product(imageUrl: 'assets/nokia.jpg', name: 'Nokia 8.3', price: 479.99),
    Product(imageUrl: 'assets/motorola.jpg', name: 'Motorola Moto G Power', price: 299.99),
    Product(imageUrl: 'assets/blackberry.jpg', name: 'BlackBerry Key2', price: 399.99),
    Product(imageUrl: 'assets/asus.jpg', name: 'Asus ROG Phone 5', price: 1099.99),
    Product(imageUrl: 'assets/lenovo.jpg', name: 'Lenovo Legion Phone Duel 2', price: 1199.99),
    Product(imageUrl: 'assets/zte.jpg', name: 'ZTE Axon 30 Ultra', price: 899.99),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductTile(product: products[index]);
      },
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            product.imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(product.name),
          Text('\$${product.price.toString()}'),
          IconButton(
            icon: product.isInCart ? Icon(Icons.check) : Icon(Icons.add_shopping_cart),
            onPressed: () {
              var cart = Provider.of<Cart>(context, listen: false);

              if (product.isInCart) {
                cart.removeFromCart(product);
              } else {
                cart.addToCart(product);

                // Display a SnackBar when the item is added to the cart
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to the cart'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}


class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                return CartItemTile(product: cart.cartItems[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total Amount: \$${cart.totalAmount.toString()}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Display a SnackBar with order details when the "BUY NOW" button is pressed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your order is placed with the following details:\n'
                            'Total Amount: \$${cart.totalAmount.toString()}'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    // Clear the cart after the order is placed
                    cart.clearCart();
                  },
                  child: Text('BUY NOW'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CartItemTile extends StatelessWidget {
  final Product product;

  CartItemTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        product.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(product.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\$${product.price.toString()}'),
          SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).removeFromCart(product);
                },
              ),
              Text('${product.quantity}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).addToCart(product);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/cart.dart';

class CartIcon extends StatelessWidget {
  final Color color;
  
  const CartIcon({
    super.key,
    this.color = const Color(0xFF171717),
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: color, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          if (cart.itemCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 
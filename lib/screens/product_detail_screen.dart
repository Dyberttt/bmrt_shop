import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/models/product.dart';
import 'package:bmrt_shop/providers/cart.dart';
import 'package:bmrt_shop/providers/wishlist.dart';
import 'package:bmrt_shop/utils/utils.dart';
import 'package:bmrt_shop/widgets/cart_icon.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wishlist = Provider.of<WishlistProvider>(context);
    final Map<String, dynamic> productMap =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = Product.fromJson(productMap);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF171717), size: 28),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          },
          padding: const EdgeInsets.only(left: 16),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_outlined, color: Color(0xFF171717), size: 20),
            ),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const CartIcon(color: Color(0xFF171717)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.asset(
                      Utils.getAssetImageForProduct(product.name),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Lihat Semua Foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171717),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            wishlist.isInWishlist(product.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: wishlist.isInWishlist(product.id)
                                ? Colors.red
                                : Colors.grey[400],
                          ),
                          onPressed: () {
                            wishlist.toggleWishlist(product.id);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Color(0xFF171717),
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (product.discount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Rp ${(product.price * (1 - ((product.discount ?? 0) / 100))).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discount!.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[400], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF171717),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.soldCount} terjual)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              product.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171717),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Icon(
                          _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    firstChild: Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                    secondChild: Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    crossFadeState: _isDescriptionExpanded 
                        ? CrossFadeState.showFirst 
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ongkir mulai Rp11.700',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Est. tiba 20 - 26 Jun',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(
                    product.id,
                    product.name,
                    product.price,
                    Utils.getAssetImageForProduct(product.name),
                  );
                  Navigator.pushNamed(context, '/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171717),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Beli Langsung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  cart.addItem(
                    product.id,
                    product.name,
                    product.price,
                    Utils.getAssetImageForProduct(product.name),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ditambahkan ke keranjang'),
                      backgroundColor: Utils.mainThemeColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF171717)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+ Keranjang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF171717),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bmrt_shop/providers/cart.dart';
import 'package:bmrt_shop/screens/cart_screen.dart';
import 'package:bmrt_shop/screens/notification_screen.dart';
import 'package:bmrt_shop/screens/search_screen.dart';
import 'package:bmrt_shop/screens/category_screen.dart';
import 'package:bmrt_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/services/product_service.dart';
import 'package:bmrt_shop/models/product.dart';
import 'package:bmrt_shop/services/seed_data.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productService = Provider.of<ProductService>(context, listen: false);
    productService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productService = Provider.of<ProductService>(context);
    final size = MediaQuery.of(context).size;

    // Data banner
    final List<Map<String, String>> banners = [
      {
        'image': 'assets/images/banner.jpeg',
        'title': 'Koleksi Jam Tangan Mewah',
        'subtitle': 'Diskon hingga 30% untuk koleksi terbatas'
      },
      {
        'image': 'assets/images/banner2.jpeg',
        'title': 'Jam Tangan Sport Terbaru',
        'subtitle': 'Temukan koleksi G-Shock terbaru'
      },
      {
        'image': 'assets/images/banner3.jpeg',
        'title': 'Jam Tangan Wanita Elegan',
        'subtitle': 'Koleksi eksklusif untuk wanita modern'
      },
    ];

    // Data kategori
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Jam Tangan Pria',
        'icon': Icons.watch,
      },
      {
        'name': 'Jam Tangan Wanita',
        'icon': Icons.watch_outlined,
      },
      {
        'name': 'Jam Tangan Sport',
        'icon': Icons.sports_basketball,
      },
      {
        'name': 'Jam Tangan Mewah',
        'icon': Icons.diamond,
      },
      {
        'name': 'Jam Tangan Digital',
        'icon': Icons.watch,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'BMRT SHOP',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A), size: 24),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final productService = Provider.of<ProductService>(context, listen: false);
              await productService.removeDuplicateProducts();
              await productService.deleteAllProducts();
              await SeedData.addWatchProducts();
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text(
                    'Data produk berhasil diperbarui',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF1A1A1A),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1A1A), size: 24),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1A), size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1A1A), size: 24),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartProvider.items.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            Container(
              height: size.height * 0.25,
              color: Colors.white,
              child: PageView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(banner['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(179),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner['subtitle']!,
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Categories
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(
                              initialCategory: category['name'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(13),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                category['icon'],
                                size: 24,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Best Sellers
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Koleksi Terlaris',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryScreen(
                                showBestSellers: true,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder<List<Product>>(
                    stream: productService.productsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1A1A1A),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        _logger.e('Error in StreamBuilder: ${snapshot.error}');
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        _logger.w('No data in StreamBuilder');
                        return const Center(
                          child: Text(
                            'Tidak ada produk',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final bestSellers = snapshot.data!
                          .where((product) => product.soldCount > 0)
                          .toList()
                        ..sort((a, b) => b.soldCount.compareTo(a.soldCount));

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: bestSellers.length,
                        itemBuilder: (context, index) {
                          final product = bestSellers[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductDetailScreen(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'id': product.id,
                                      'name': product.name,
                                      'price': product.price,
                                      'image': product.image,
                                      'rating': product.rating,
                                      'soldCount': product.soldCount,
                                      'tags': product.tags,
                                      'location': product.location,
                                      'discount': product.discount,
                                      'description': product.description,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(26),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    child: Container(
                                      height: 140,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            product.image,
                                            fit: BoxFit.cover,
                                            package: null,
                                            errorBuilder: (context, error, stackTrace) {
                                              _logger.e('Error loading image: $error');
                                              _logger.i('Attempted to load image: ${product.image}');
                                              return Container(
                                                color: Colors.grey[300],
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.watch, size: 40, color: Color(0xFF1A1A1A)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Error: ${error.toString()}',
                                                      style: const TextStyle(fontSize: 10),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withAlpha(77),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (product.discount != null && product.discount! > 0)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${product.discount}% OFF',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                'Rp ${product.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A1A1A),
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              if (product.discount != null && product.discount! > 0) ...[
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Rp ${product.priceBeforeDiscount.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey[600],
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 12,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                product.rating.toString(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF1A1A1A),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Terjual ${product.soldCount}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  product.location,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

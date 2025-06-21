import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/auth.dart';
import 'package:bmrt_shop/providers/cart.dart';
import 'package:bmrt_shop/providers/wishlist.dart';
import 'package:bmrt_shop/screens/splash_screen.dart';
import 'package:bmrt_shop/firebase_options.dart';
import 'package:logging/logging.dart';
import 'package:bmrt_shop/models/transaction.dart';
import 'package:bmrt_shop/services/product_service.dart';
import 'package:bmrt_shop/services/transaction_service.dart';

// Deferred imports
import 'package:bmrt_shop/screens/login_screen.dart' deferred as login;
import 'package:bmrt_shop/screens/register_screen.dart' deferred as register;
import 'package:bmrt_shop/screens/home_screen.dart' deferred as home;
import 'package:bmrt_shop/screens/video_screen.dart' deferred as video;
import 'package:bmrt_shop/screens/promo_screen.dart' deferred as promo;
import 'package:bmrt_shop/screens/transaction_screen.dart' deferred as transaction;
import 'package:bmrt_shop/screens/account_screen.dart' deferred as account;
import 'package:bmrt_shop/screens/product_detail_screen.dart' deferred as product_detail;
import 'package:bmrt_shop/screens/cart_screen.dart' deferred as cart;
import 'package:bmrt_shop/screens/notification_screen.dart' deferred as notification;
import 'package:bmrt_shop/screens/wishlist_screen.dart' deferred as wishlist;
import 'package:bmrt_shop/screens/checkout_screen.dart' deferred as checkout;
import 'package:bmrt_shop/screens/transaction_detail_screen.dart' deferred as transaction_detail;

// Cache untuk menyimpan instance provider
final Map<Type, dynamic> _providerCache = {};

// Flag untuk menandai apakah aplikasi sedang dalam proses hot restart
bool _isHotRestarting = false;

void main() {
  final logger = Logger('main');
  
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Reset cache saat hot restart
    if (_isHotRestarting) {
      _providerCache.clear();
      _isHotRestarting = false;
    }
    
    // Inisialisasi Firebase dan load library secara paralel
    final futures = <Future>[
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      // Pre-load library yang sering digunakan
      home.loadLibrary(),
      login.loadLibrary(),
      register.loadLibrary(),
    ];
    
    try {
      await Future.wait(futures);
      logger.info('Initial core libraries loaded');
      
      // Load library lain secara lazy
      _loadLazyLibraries();
      
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => _getOrCreateProvider<AuthService>(AuthService())),
            ChangeNotifierProvider(create: (_) => _getOrCreateProvider<CartProvider>(CartProvider())),
            ChangeNotifierProvider(create: (_) => _getOrCreateProvider<WishlistProvider>(WishlistProvider())),
            ChangeNotifierProvider(create: (_) => _getOrCreateProvider<ProductService>(ProductService())),
            ChangeNotifierProvider(create: (_) => _getOrCreateProvider<TransactionService>(TransactionService())),
          ],
          child: const MyApp(),
        ),
      );
    } catch (e) {
      logger.severe('Initialization failed: $e');
    }
  }, (error, stack) {
    logger.severe('Error: $error');
    logger.severe('Stack: $stack');
  });
}

// Helper function untuk mendapatkan atau membuat provider dari cache
T _getOrCreateProvider<T>(T provider) {
  if (!_providerCache.containsKey(T)) {
    _providerCache[T] = provider;
  }
  return _providerCache[T] as T;
}

// Fungsi untuk load library secara lazy
Future<void> _loadLazyLibraries() async {
  final loaders = [
    video.loadLibrary(),
    promo.loadLibrary(),
    transaction.loadLibrary(),
    account.loadLibrary(),
    product_detail.loadLibrary(),
    cart.loadLibrary(),
    notification.loadLibrary(),
    wishlist.loadLibrary(),
    checkout.loadLibrary(),
    transaction_detail.loadLibrary(),
  ];
  
  // Load library di background
  Future.wait(loaders).then((_) {
    Logger('main').info('Lazy loaded libraries completed');
  });
}

// Fungsi untuk menangani hot restart
void handleHotRestart() {
  _isHotRestarting = true;
  _providerCache.clear();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMRT Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A1A1A),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A1A),
          primary: const Color(0xFF1A1A1A),
          secondary: const Color(0xFF1A1A1A),
          surface: const Color(0xFFF8F8F8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF1A1A1A),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => login.LoginScreen(),
        '/register': (context) => register.RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/cart': (context) => cart.CartScreen(),
        '/transactions': (context) => transaction.TransactionScreen(),
        '/notifications': (context) => notification.NotificationScreen(),
        '/account': (context) => account.AccountScreen(),
        '/wishlist': (context) => wishlist.WishlistScreen(),
        '/checkout': (context) => checkout.CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          return MaterialPageRoute(
            builder: (context) => product_detail.ProductDetailScreen(),
            settings: settings,
          );
        }
        if (settings.name == '/transaction_detail') {
          final transaction = settings.arguments as Transaction;
          return MaterialPageRoute(
            builder: (context) => transaction_detail.TransactionDetailScreen(transaction: transaction),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    home.HomeScreen(),
    video.VideoScreen(),
    promo.PromoScreen(),
    transaction.TransactionScreen(),
    account.AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1A1A1A),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 0,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? const Color(0xFF1A1A1A).withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? const Color(0xFF1A1A1A).withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.video_library_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.video_library),
              ),
              label: 'Video',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2 ? const Color(0xFF1A1A1A).withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_offer_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_offer),
              ),
              label: 'Promo',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 3 ? const Color(0xFF1A1A1A).withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long),
              ),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedIndex == 4 ? const Color(0xFF1A1A1A).withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person),
              ),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/auth.dart';
import 'package:bmrt_shop/providers/cart.dart';
import 'package:bmrt_shop/providers/wishlist.dart';
import 'package:bmrt_shop/screens/splash_screen.dart';
import 'package:bmrt_shop/screens/login_screen.dart';
import 'package:bmrt_shop/screens/register_screen.dart';
import 'package:bmrt_shop/screens/home_screen.dart';
import 'package:bmrt_shop/screens/video_screen.dart';
import 'package:bmrt_shop/screens/promo_screen.dart';
import 'package:bmrt_shop/screens/transaction_screen.dart';
import 'package:bmrt_shop/screens/account_screen.dart';
import 'package:bmrt_shop/screens/product_detail_screen.dart';
import 'package:bmrt_shop/screens/cart_screen.dart';
import 'package:bmrt_shop/screens/notification_screen.dart';
import 'package:bmrt_shop/screens/wishlist_screen.dart';
import 'package:bmrt_shop/screens/checkout_screen.dart';
import 'package:bmrt_shop/screens/transaction_detail_screen.dart';
import 'package:bmrt_shop/services/product_service.dart';
import 'package:bmrt_shop/services/transaction_service.dart';
import 'package:bmrt_shop/firebase_options.dart';
import 'package:logging/logging.dart';
import 'package:bmrt_shop/models/transaction.dart';

void main() {
  final logger = Logger('main');
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      logger.info('Firebase initialized successfully');
    } catch (e) {
      logger.severe('Firebase initialization failed: $e');
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => ProductService()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => TransactionService()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    logger.severe('Error: $error');
    logger.severe('Stack: $stack');
  });
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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/cart': (context) => const CartScreen(),
        '/transactions': (context) => const TransactionScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/account': (context) => const AccountScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          return MaterialPageRoute(
            builder: (context) => const ProductDetailScreen(),
            settings: settings,
          );
        }
        if (settings.name == '/transaction_detail') {
          final transaction = settings.arguments as Transaction;
          return MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: transaction),
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

  final List<Widget> _screens = const [
    HomeScreen(),
    VideoScreen(),
    PromoScreen(),
    TransactionScreen(),
    AccountScreen(),
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

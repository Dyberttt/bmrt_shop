import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bmrt_shop/providers/auth.dart';
import 'package:logger/logger.dart';

class WishlistProvider with ChangeNotifier {
  final List<String> _wishlistItems = [];
  final AuthService _authService = AuthService();
  final _logger = Logger();

  List<String> get wishlistItems => _wishlistItems;

  Future<void> loadWishlist() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .get();

      _wishlistItems.clear();
      for (var doc in doc.docs) {
        _wishlistItems.add(doc.id);
      }
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlist(String productId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId);

      if (_wishlistItems.contains(productId)) {
        await wishlistRef.delete();
        _wishlistItems.remove(productId);
      } else {
        await wishlistRef.set({
          'addedAt': FieldValue.serverTimestamp(),
        });
        _wishlistItems.add(productId);
      }
      notifyListeners();
    } catch (e) {
      _logger.e('Error toggling wishlist: $e');
    }
  }

  bool isInWishlist(String productId) {
    return _wishlistItems.contains(productId);
  }
}
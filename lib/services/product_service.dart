import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bmrt_shop/models/product.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class ProductService extends ChangeNotifier {
  final _logger = Logger('ProductService');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedTag;
  final _productsController = StreamController<List<Product>>.broadcast();

  ProductService() {
    fetchProducts();
  }

  String? get selectedTag => _selectedTag;

  Stream<List<Product>> get productsStream {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Tambahkan id ke data
        return Product.fromJson(data);
      }).toList();
    });
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Tambahkan id ke data
        return Product.fromJson(data);
      }).toList();
      _productsController.add(products);
    } catch (e) {
      _logger.severe('Error fetching products: $e');
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toJson());
    } catch (e) {
      _logger.severe('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> deleteAllProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('products').get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _logger.info('Semua produk berhasil dihapus');
    } catch (e) {
      _logger.severe('Error deleting all products: $e');
      rethrow;
    }
  }

  Future<void> removeDuplicateProducts() async {
    try {
      _logger.info('Memulai proses penghapusan produk duplikat...');
      final QuerySnapshot snapshot = await _firestore.collection('products').get();
      
      // Kelompokkan produk berdasarkan nama
      Map<String, List<QueryDocumentSnapshot>> productsByName = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String?;
        if (name != null) {
          if (!productsByName.containsKey(name)) {
            productsByName[name] = [];
          }
          productsByName[name]!.add(doc);
        }
      }

      // Hapus duplikat, sisakan hanya satu produk untuk setiap nama
      final batch = _firestore.batch();
      int duplicateCount = 0;

      for (var entry in productsByName.entries) {
        final products = entry.value;
        if (products.length > 1) {
          _logger.info('Menemukan ${products.length} produk duplikat untuk ${entry.key}');
          // Sisakan produk pertama, hapus yang lainnya
          for (int i = 1; i < products.length; i++) {
            batch.delete(products[i].reference);
            duplicateCount++;
          }
        }
      }

      if (duplicateCount > 0) {
        await batch.commit();
        _logger.info('Berhasil menghapus $duplicateCount produk duplikat');
      } else {
        _logger.info('Tidak ada produk duplikat yang ditemukan');
      }
    } catch (e) {
      _logger.severe('Error menghapus produk duplikat: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(id).update(data);
    } catch (e) {
      _logger.severe('Error updating product: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _productsController.close();
    super.dispose();
  }
}
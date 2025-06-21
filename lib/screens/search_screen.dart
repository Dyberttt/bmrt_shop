import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/services/product_service.dart';
import 'package:bmrt_shop/models/product.dart';
import 'package:bmrt_shop/screens/product_detail_screen.dart';
import 'package:bmrt_shop/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  List<String> _searchHistory = [];
  static const String _searchHistoryKey = 'search_history';
  final int _maxHistoryItems = 10;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _searchHistory.remove(query); // Hapus jika sudah ada
      _searchHistory.insert(0, query); // Tambahkan ke awal
      if (_searchHistory.length > _maxHistoryItems) {
        _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
      }
    });
    
    await _saveSearchHistory();
  }

  List<String> _getSuggestions(List<Product> products, String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    final suggestions = <String>{};
    
    // Tambahkan riwayat pencarian yang cocok
    for (var history in _searchHistory) {
      if (history.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(history);
      }
    }
    
    // Tambahkan nama produk yang cocok
    for (var product in products) {
      if (product.name.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(product.name);
      }
    }
    
    // Tambahkan tag yang cocok
    for (var product in products) {
      for (var tag in product.tags) {
        if (tag.toLowerCase().contains(lowercaseQuery)) {
          suggestions.add(tag);
        }
      }
    }
    
    return suggestions.toList()..sort();
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty || query.length < 2) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
            product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
            product.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    
    return PopScope(
      canPop: !_showSuggestions,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF171717), size: 24),
            onPressed: () {
              if (_showSuggestions) {
                setState(() {
                  _showSuggestions = false;
                });
              } else {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
          ),
          title: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk jam tangan...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF171717)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF171717)),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _showSuggestions = value.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _showSuggestions = _searchQuery.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addToSearchHistory(value);
                  setState(() {
                    _showSuggestions = false;
                  });
                }
              },
            ),
          ),
        ),
        body: StreamBuilder<List<Product>>(
          stream: productService.productsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF171717),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 16,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada produk',
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 16,
                  ),
                ),
              );
            }

            if (_showSuggestions && _searchQuery.isNotEmpty) {
              _suggestions = _getSuggestions(snapshot.data!, _searchQuery);
              if (_suggestions.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final isHistory = _searchHistory.contains(suggestion);
                    return ListTile(
                      leading: Icon(
                        isHistory ? Icons.history : Icons.search,
                        color: Colors.grey,
                      ),
                      title: Text(
                        suggestion,
                        style: const TextStyle(
                          color: Color(0xFF171717),
                        ),
                      ),
                      onTap: () {
                        _addToSearchHistory(suggestion);
                        setState(() {
                          _searchController.text = suggestion;
                          _searchQuery = suggestion;
                          _showSuggestions = false;
                        });
                      },
                    );
                  },
                );
              }
            }

            if (_searchQuery.isEmpty) {
              return _buildSearchHistory();
            }

            final filteredProducts = _filterProducts(snapshot.data!, _searchQuery);

            if (filteredProducts.isEmpty) {
              return Center(
                child: Text(
                  _searchQuery.length < 2 
                      ? 'Ketik minimal 2 karakter untuk mencari'
                      : 'Tidak ada produk yang ditemukan',
                  style: const TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        Utils.getAssetImageForProduct(product.name),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171717),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          Utils.formatRupiah(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171717),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF171717),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Terjual ${product.soldCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF171717),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      _addToSearchHistory(product.name);
                      Navigator.push(
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Riwayat Pencarian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171717),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(
                  _searchHistory[index],
                  style: const TextStyle(
                    color: Color(0xFF171717),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () async {
                    setState(() {
                      _searchHistory.removeAt(index);
                    });
                    await _saveSearchHistory();
                  },
                ),
                onTap: () {
                  setState(() {
                    _searchController.text = _searchHistory[index];
                    _searchQuery = _searchHistory[index];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 
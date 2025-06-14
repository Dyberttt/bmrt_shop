import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dummy data untuk riwayat pencarian
  final List<String> searchHistory = [
    'iPhone 13',
    'MacBook Pro',
    'Samsung Galaxy',
    'AirPods Pro',
  ];

  // Dummy data untuk hasil pencarian
  final List<Map<String, dynamic>> searchResults = [
    {
      'name': 'iPhone 13 Pro',
      'price': 15999000,
      'image': 'assets/images/iphone.jpg',
      'rating': 4.8,
      'sold': 1200
    },
    {
      'name': 'iPhone 13',
      'price': 13999000,
      'image': 'assets/images/iphone.jpg',
      'rating': 4.7,
      'sold': 1500
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              hintText: 'Cari produk...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF171717)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF171717)),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
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
              });
            },
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF171717)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildSearchHistory()
          : _buildSearchResults(),
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
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(
                  searchHistory[index],
                  style: const TextStyle(
                    color: Color(0xFF171717),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      searchHistory.removeAt(index);
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _searchController.text = searchHistory[index];
                    _searchQuery = searchHistory[index];
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final product = searchResults[index];
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
                product['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              product['name'],
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
                  'Rp ${product['price'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terjual ${product['sold']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Navigate to product detail
            },
          ),
        );
      },
    );
  }
} 
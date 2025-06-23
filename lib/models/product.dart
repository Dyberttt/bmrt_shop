class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final double rating;
  final int soldCount;
  final String location;
  final double? discount;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
    required this.soldCount,
    required this.location,
    required this.tags,
    this.discount,
  });

  double get priceBeforeDiscount => price * (1 - ((discount ?? 0) / 100));

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      soldCount: json['soldCount'] as int,
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] as List),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'rating': rating,
      'soldCount': soldCount,
      'location': location,
      'tags': tags,
      'discount': discount,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final double shippingFee;
  final double insuranceFee;
  final double protectionFee;
  final double codFee;
  final double discountItems;
  final double discountShipping;
  String status;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.shippingFee,
    required this.insuranceFee,
    required this.protectionFee,
    required this.codFee,
    required this.discountItems,
    required this.discountShipping,
    required this.status,
    required this.timestamp,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0.0).toDouble(),
      insuranceFee: (map['insuranceFee'] ?? 0.0).toDouble(),
      protectionFee: (map['protectionFee'] ?? 0.0).toDouble(),
      codFee: (map['codFee'] ?? 0.0).toDouble(),
      discountItems: (map['discountItems'] ?? 0.0).toDouble(),
      discountShipping: (map['discountShipping'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'totalPrice': totalPrice,
      'shippingFee': shippingFee,
      'insuranceFee': insuranceFee,
      'protectionFee': protectionFee,
      'codFee': codFee,
      'discountItems': discountItems,
      'discountShipping': discountShipping,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bmrt_shop/models/transaction.dart' as transaction_model;
import 'package:logger/logger.dart';

class TransactionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger();
  List<transaction_model.Transaction> _transactions = [];
  bool _isLoading = false;

  List<transaction_model.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Stream<List<transaction_model.Transaction>> getTransactions(String userId) {
    _logger.i('Getting transactions for user: $userId');
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          _logger.i('Received ${snapshot.docs.length} transactions');
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return transaction_model.Transaction.fromMap(data);
          }).toList();
        });
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return transaction_model.Transaction.fromMap(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createTransaction(transaction_model.Transaction transaction) async {
    try {
      final transactionData = transaction.toMap();
      transactionData['timestamp'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection('transactions').add(transactionData);
      
      final newTransaction = transaction_model.Transaction(
        id: docRef.id,
        userId: transaction.userId,
        items: transaction.items,
        totalPrice: transaction.totalPrice,
        shippingFee: transaction.shippingFee,
        insuranceFee: transaction.insuranceFee,
        protectionFee: transaction.protectionFee,
        codFee: transaction.codFee,
        discountItems: transaction.discountItems,
        discountShipping: transaction.discountShipping,
        status: transaction.status,
        timestamp: DateTime.now(),
      );
      
      _transactions.insert(0, newTransaction);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        final updatedTransaction = transaction_model.Transaction(
          id: _transactions[index].id,
          userId: _transactions[index].userId,
          items: _transactions[index].items,
          totalPrice: _transactions[index].totalPrice,
          shippingFee: _transactions[index].shippingFee,
          insuranceFee: _transactions[index].insuranceFee,
          protectionFee: _transactions[index].protectionFee,
          codFee: _transactions[index].codFee,
          discountItems: _transactions[index].discountItems,
          discountShipping: _transactions[index].discountShipping,
          status: status,
          timestamp: DateTime.now(),
        );
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
} 
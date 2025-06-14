import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/auth.dart';
import 'package:bmrt_shop/services/transaction_service.dart';
import 'package:bmrt_shop/models/transaction.dart';
import 'package:logger/logger.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _logger = Logger();
    final authService = Provider.of<AuthService>(context);
    final transactionService = Provider.of<TransactionService>(context);
    final currentUser = authService.currentUser;

    _logger.i('Building TransactionScreen for user: ${currentUser?.uid}');

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Silakan login terlebih dahulu',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF171717),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Color(0xFF171717),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: Color(0xFF171717), size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Transaction>>(
            stream: transactionService.getTransactions(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                _logger.e('Error in TransactionScreen: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi kesalahan: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF171717),
                  ),
                );
              }

              final transactions = snapshot.data ?? [];
              _logger.i('Received ${transactions.length} transactions');

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF171717),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/transaction_detail',
                            arguments: transaction,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1A1A).withAlpha(26),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_outlined,
                                          color: Color(0xFF171717),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Transaksi #${transaction.id.substring(0, 8)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF171717),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(transaction.status).withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      transaction.status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(transaction.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(transaction.timestamp),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp ${transaction.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
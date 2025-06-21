import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data untuk notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Promo Spesial',
        'message': 'Dapatkan diskon hingga 50% untuk semua produk elektronik',
        'time': '2 jam yang lalu',
        'isRead': false,
      },
      {
        'title': 'Pesanan Dikirim',
        'message': 'Pesanan #12345 telah dikirim dan sedang dalam perjalanan',
        'time': '1 hari yang lalu',
        'isRead': true,
      },
      {
        'title': 'Pembayaran Berhasil',
        'message': 'Pembayaran untuk pesanan #12345 telah berhasil',
        'time': '2 hari yang lalu',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF171717), size: 24),
          onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
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
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
                        color: const Color(0xFF171717),
                      ),
                    ),
                  ),
                  if (!notification['isRead'])
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Handle notification tap
              },
            ),
          );
        },
      ),
    );
  }
} 
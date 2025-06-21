import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/cart.dart';
import 'package:bmrt_shop/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:bmrt_shop/providers/auth.dart'; // Pastikan AuthService tersedia
import 'package:bmrt_shop/models/transaction.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedShipping = 'Standard (Rp0)';
  String _selectedPayment = 'COD (Bayar di Tempat)';
  bool _useInsurance = false;
  bool _useProtection = true;

  void _showTransferDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildTransferDialog(dialogContext, total),
    );
  }

  Widget _buildTransferDialog(BuildContext dialogContext, double total) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transfer Pembayaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Utils.formatRupiah(total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Transfer ke rekening:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bank BCA'),
                      Text(
                        '1234567890',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('a.n.'),
                      Text(
                        'BMRT Shop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Instruksi:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Transfer sesuai nominal yang tertera\n'
              '2. Simpan bukti transfer\n'
              '3. Pesanan akan diproses setelah pembayaran dikonfirmasi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF171717)),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Color(0xFF171717),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _processPayment(context, total);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171717),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sudah Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, double total) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = cart.items.values.toList();
    final navigator = Navigator.of(context);

    // Hitung biaya-biaya
    double shippingFee = _selectedShipping.contains('Rp')
        ? double.parse(_selectedShipping.split('Rp')[1].split(')')[0].trim())
        : 0;
    double insuranceFee = _useInsurance ? 400 : 0;
    double protectionFee = _useProtection ? items.length * 1250 : 0;
    double codFee = _selectedPayment.contains('COD') ? (total * 0.01).roundToDouble() : 0;
    double discountItems = cart.discountItems;
    double discountShipping = cart.discountShipping;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Buat transaksi baru
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        items: items.map((item) => {
          'productId': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'image': item.image,
        }).toList(),
        totalPrice: total,
        shippingFee: shippingFee,
        insuranceFee: insuranceFee,
        protectionFee: protectionFee,
        codFee: codFee,
        discountItems: discountItems,
        discountShipping: discountShipping,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      // Simpan transaksi ke Firestore
      await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());

      // Kosongkan keranjang
      cart.clear();

      if (!mounted) return;
      _showSuccessDialog(navigator);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog(NavigatorState navigator) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pesanan Berhasil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF171717),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan kamu sedang diproses.\nSilakan lakukan pembayaran sesuai instruksi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  navigator.pushReplacementNamed('/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF171717),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terjadi kesalahan: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    double totalPrice = items.fold(0, (total, item) => total + (item.price * item.quantity));
    double insuranceFee = _useInsurance ? 400 : 0;
    double protectionFee = _useProtection ? items.length * 1250 : 0;
    double shippingFee = _selectedShipping.contains('Rp')
        ? double.parse(_selectedShipping.split('Rp')[1].split(')')[0].trim())
        : 0;
    double codFee = _selectedPayment.contains('COD') ? (totalPrice * 0.01).roundToDouble() : 0;
    double discountItems = cart.discountItems;
    double discountShipping = cart.discountShipping;
    double total = totalPrice + shippingFee + insuranceFee + protectionFee + codFee - discountItems - discountShipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
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
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.location_on, color: Color(0xFF1A1A1A), size: 28),
              ),
              title: const Text(
                'Rumah · Firman Chandra',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
              subtitle: const Text(
                'Jl. Kp Tanjung, Lubug Begalung, Sumatera Barat',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 0.3,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF1A1A1A), size: 28),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Pesanan Kamu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) => _buildItemTile(item)),
          const SizedBox(height: 32),
          const Text(
            'Pilih Pengiriman',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
            child: _buildShippingOption('Standard (Rp0) - Est. tiba 6-12 Jun'),
          ),
          const SizedBox(height: 32),
          Container(
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
            child: Column(
              children: [
                CheckboxListTile(
                  value: _useInsurance,
                  onChanged: (v) => setState(() => _useInsurance = v!),
                  title: const Text(
                    'Pakai Asuransi Pengiriman (Rp400)',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  value: _useProtection,
                  onChanged: (v) => setState(() => _useProtection = v!),
                  title: const Text(
                    'Proteksi Rusak Uang Kembali 100% (Rp1250/item)',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
            child: Column(
              children: [
                RadioListTile(
                  value: 'COD (Bayar di Tempat)',
                  groupValue: _selectedPayment,
                  onChanged: (value) => setState(() => _selectedPayment = value!),
                  title: const Text(
                    'COD (Bayar di Tempat)',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  subtitle: Text(
                    'Biaya tambahan ${(totalPrice * 0.01).roundToDouble().toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  activeColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                const Divider(height: 1),
                RadioListTile(
                  value: 'Transfer Bank',
                  groupValue: _selectedPayment,
                  onChanged: (value) => setState(() => _selectedPayment = value!),
                  title: const Text(
                    'Transfer Bank',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  subtitle: const Text(
                    'Transfer ke rekening BCA',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  activeColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Belanja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryRow('Total Harga (${items.length} Barang)', totalPrice),
                _buildSummaryRow('Total Ongkos Kirim', shippingFee),
                _buildSummaryRow('Total Asuransi Pengiriman', insuranceFee),
                _buildSummaryRow('Total Biaya Proteksi', protectionFee),
                _buildSummaryRow('Biaya Bayar di Tempat', codFee),
                const Divider(height: 32),
                _buildSummaryRow('Diskon Barang', -discountItems),
                _buildSummaryRow('Diskon Ongkir', -discountShipping),
                const Divider(height: 32, thickness: 2),
                _buildSummaryRow('Total Tagihan', total, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_selectedPayment == 'Transfer Bank') {
                  _showTransferDialog(context, total);
                } else {
                  _processPayment(context, total);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF171717),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  Utils.getAssetImageForProduct(item.name),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.watch, size: 40, color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Utils.formatRupiah(item.price * item.quantity),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOption(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: _selectedShipping,
      onChanged: (v) => setState(() => _selectedShipping = v!),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
      activeColor: const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: isBold ? const Color(0xFF1A1A1A) : Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
          Text(
            Utils.formatRupiah(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
              color: isBold ? const Color(0xFF1A1A1A) : Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
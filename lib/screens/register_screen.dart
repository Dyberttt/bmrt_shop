import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bmrt_shop/providers/auth.dart';
import 'package:bmrt_shop/utils/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateState);
    passwordController.addListener(_updateState);
    confirmPasswordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    bool isFormValid = Utils.validateEmail(emailController.text.trim()) &&
        passwordController.text.trim().length >= 6 &&
        confirmPasswordController.text.trim().length >= 6 &&
        passwordController.text.trim() == confirmPasswordController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171717), Color(0xFF2C2C2C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 60,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Daftar untuk mulai berbelanja',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'E-mail',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF171717)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  hintText: 'Kata Sandi',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF171717)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: const Color(0xFF171717),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField(
                                controller: confirmPasswordController,
                                decoration: InputDecoration(
                                  hintText: 'Konfirmasi Kata Sandi',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF171717)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      color: const Color(0xFF171717),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureConfirmPassword,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: isFormValid
                                  ? () async {
                                      try {
                                        await authService.signUp(
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Registrasi berhasil!')),
                                        );
                                        await Future.delayed(const Duration(seconds: 1));
                                        if (!context.mounted) return;
                                        Navigator.pushReplacementNamed(context, '/main');
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(authService.errorMessage)),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF171717),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 56),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Sudah punya akun? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/login'),
                                  child: const Text(
                                    "Masuk sekarang",
                                    style: TextStyle(
                                      color: Color(0xFF171717),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (authService.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authService.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
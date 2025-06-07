import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/shared_prefs_service.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await ApiService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        setState(() => _isLoading = false);

        // Samakan dengan register: cek jika result == true atau result['success'] == true
        if ((result is bool && result == true) ||
            (result['success'] == true && result['user'] != null)) {
          // Jika result['user'] ada, gunakan, jika tidak, ambil dari SharedPrefsService
          User? user;
          if (result['user'] != null) {
            user = result['user'];
          } else {
            user = await SharedPrefsService.getUser();
          }
          if (user != null) {
            if (user.role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          } else {
            showSnackBar('User tidak ditemukan', isError: true);
          }
        } else {
          showSnackBar('Username atau password salah', isError: true);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        showSnackBar('Login gagal: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo-rmj.png',
                height: 100,
                errorBuilder: (c, e, s) => const SizedBox(height: 100),
              ),
              const SizedBox(height: 24),
              Text(
                'Rumah Mobil Jogja',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Rental Mobil',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE0E6ED),
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Color(0xFFE0E6ED)),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Username tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(0xFFE0E6ED)),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF00E09E), // warna teks tombol
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?'),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text('Daftar di sini'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

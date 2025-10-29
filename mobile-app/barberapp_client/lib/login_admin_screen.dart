import 'package:flutter/material.dart';
import 'agenda_screen.dart';

const String _ADMIN_USER = 'admin';
const String _ADMIN_PASS = '1234';

// Fecha fija demo
const String _FECHA_DEMO = '2025-11-02';

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({super.key});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _showError = false;
  bool _verPassword = false;
  bool _loading = false;

  void _intentarLogin() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    setState(() {
      _showError = false;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (user == _ADMIN_USER && pass == _ADMIN_PASS) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AgendaScreen(
            fecha: _FECHA_DEMO,
          ),
        ),
      );
    } else {
      setState(() {
        _showError = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        centerTitle: true,
        title: const Text(
          'Acceso administrador',
          style: TextStyle(
            color: dorado,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inicia sesión',
              style: TextStyle(
                color: dorado,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _userCtrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: dorado,
              decoration: InputDecoration(
                labelText: 'Usuario',
                labelStyle: const TextStyle(color: dorado),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: dorado),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: dorado, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passCtrl,
              obscureText: !_verPassword,
              style: const TextStyle(color: Colors.white),
              cursorColor: dorado,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: dorado),
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: dorado,
                  ),
                  onPressed: () {
                    setState(() {
                      _verPassword = !_verPassword;
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: dorado),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: dorado, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_showError)
              const Text(
                'Usuario o contraseña incorrectos',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dorado,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading ? null : _intentarLogin,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

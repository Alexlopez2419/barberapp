import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'servicios_screen.dart';
import 'register_screen.dart';

const String apiBase = "http://172.20.10.5:3000";


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final url = Uri.parse('$apiBase/usuarios/login');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telefono': _telCtrl.text.trim(),
          'password': _passCtrl.text.trim(),
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['ok'] == true) {
          final u = data['usuario'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', u['id']);
          await prefs.setString('user_nombre', u['nombre'] ?? '');
          await prefs.setString('user_telefono', u['telefono'] ?? '');
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ServiciosScreen()),
              (_) => false,
            );
          }
          return;
        } else {
          _error = data['error']?.toString() ?? 'Credenciales inválidas';
        }
      } else {
        _error = 'Error HTTP ${resp.statusCode}';
      }
    } catch (e) {
      _error = 'No se pudo conectar al servidor';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Inicio de sesión', style: TextStyle(color: dorado)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset('assets/scissors.png', width: 120, height: 120),
              const SizedBox(height: 16),
              const Text('Ingresa para continuar',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 4) ? 'Mínimo 4 caracteres' : null,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: dorado),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Entrar', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text('¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: dorado)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'servicios_screen.dart';
import 'login_screen.dart';

// Ajusta tu IP local si cambió
const String apiBase = "http://172.20.10.5:3000";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _registrar() async {
    final nombre = _nombreCtrl.text.trim();
    final telefono = _telCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (nombre.isEmpty || telefono.isEmpty || password.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = Uri.parse('$apiBase/usuarios/register'); // ← AQUÍ iba el ';'
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'telefono': telefono,
          'password': password,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['ok'] == true) {
          // Opcional: guardamos el teléfono para autocompletar login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ultimo_tel', telefono);

          if (!mounted) return;
          // Vuelve al login para iniciar sesión
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        } else {
          setState(() => _error = data['error']?.toString() ?? 'Error al registrar');
        }
      } else {
        setState(() => _error = 'Error HTTP ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        title: const Text('Crear cuenta', style: TextStyle(color: dorado)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _campo('Nombre', _nombreCtrl, false),
          const SizedBox(height: 12),
          _campo('Teléfono', _telCtrl, false, teclado: TextInputType.phone),
          const SizedBox(height: 12),
          _campo('Contraseña', _passCtrl, true),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _registrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: dorado,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Crear cuenta', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
            child: const Text('¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(color: dorado)),
          ),
        ],
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, bool esPassword,
      {TextInputType teclado = TextInputType.text}) {
    const dorado = Color(0xFFD4AF37);
    return TextField(
      controller: ctrl,
      obscureText: esPassword,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: dorado),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: dorado, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
      ),
    );
  }
}

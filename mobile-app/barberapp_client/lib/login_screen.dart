import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_screen.dart';
import 'servicios_screen.dart';

// IP DE TU LAPTOP (donde corre node server.js)
const String apiBase = "http://192.168.0.30:3000";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  String? _error;
  bool _cargando = false;

  Future<void> _doLogin() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final url = Uri.parse("$apiBase/usuarios/login");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "telefono": _telefonoCtrl.text.trim(),
        "password": _passwordCtrl.text.trim(),
      }),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data["ok"] == true && data["usuario"] != null) {
        final usuario = data["usuario"];
        final int usuarioId = usuario["id"];
        final String nombreUsuario = usuario["nombre"] ?? "Usuario";

        // Navegar a servicios con el ID del usuario logueado
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ServiciosScreen(
              usuarioId: usuarioId,
              nombreUsuario: nombreUsuario,
            ),
          ),
        );
      } else {
        setState(() {
          _error = "Credenciales inválidas";
        });
      }
    } else {
      setState(() {
        _error = "Error de servidor (${resp.statusCode})";
      });
    }

    setState(() {
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(color: dorado),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // LOGO / ICONO
            const Icon(
              Icons.content_cut,
              color: dorado,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              "Bienvenido a BarberApp",
              style: TextStyle(
                color: dorado,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Campo teléfono
            TextField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo password
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dorado,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _cargando
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        "Entrar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                "¿No tenés cuenta? Crear cuenta",
                style: TextStyle(color: dorado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

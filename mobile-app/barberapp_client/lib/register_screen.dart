import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'servicios_screen.dart';

// misma IP que en login
const String apiBase = "http://192.168.0.30:3000";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();

  bool _cargando = false;
  String? _error;

  Future<void> _crearCuenta() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final url = Uri.parse("$apiBase/usuarios/register");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": _nombreCtrl.text.trim(),
        "telefono": _telCtrl.text.trim(),
        "password": _passCtrl.text.trim(),
        "correo": _correoCtrl.text.trim(),
      }),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data["ok"] == true && data["usuario"] != null) {
        final usuario = data["usuario"];
        final int usuarioId = usuario["id"];
        final String nombreUsuario = usuario["nombre"] ?? "Usuario";

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
          _error = "No se pudo crear la cuenta";
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
          'Crear cuenta',
          style: TextStyle(color: dorado),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.face_retouching_natural,
              color: dorado,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              "Registrate para reservar",
              style: TextStyle(
                color: dorado,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            _campo("Nombre completo", _nombreCtrl, false),
            const SizedBox(height: 16),

            _campo("Teléfono", _telCtrl, false,
                tipo: TextInputType.phone),
            const SizedBox(height: 16),

            _campo("Correo (opcional)", _correoCtrl, false,
                tipo: TextInputType.emailAddress),
            const SizedBox(height: 16),

            _campo("Contraseña", _passCtrl, true),
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
                onPressed: _cargando ? null : _crearCuenta,
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
                        "Crear cuenta",
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

  Widget _campo(String label, TextEditingController ctrl, bool esPassword,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: esPassword,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

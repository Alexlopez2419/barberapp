import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiBase = 'http://localhost:3000';

// IMPORTANTE: por ahora vamos a usar usuario_id = 1 fijo,
// porque todavía no hicimos login/registro.
// Más adelante lo hacemos bien.
const int kUsuarioIdFijo = 1;

class ConfirmacionScreen extends StatefulWidget {
  final int servicioId;
  final int barberoId;
  final String servicioNombre;
  final String barberoNombre;
  final String fechaCita;   // "YYYY-MM-DD"
  final String horaInicio;  // "HH:MM"

  const ConfirmacionScreen({
    super.key,
    required this.servicioId,
    required this.barberoId,
    required this.servicioNombre,
    required this.barberoNombre,
    required this.fechaCita,
    required this.horaInicio,
  });

  @override
  State<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends State<ConfirmacionScreen> {
  bool _enviando = false;
  String? _mensajeOk;
  String? _mensajeError;

  Future<void> _confirmarCita() async {
    setState(() {
      _enviando = true;
      _mensajeOk = null;
      _mensajeError = null;
    });

    final url = Uri.parse('$apiBase/citas');
    final body = {
      "usuario_id": kUsuarioIdFijo,
      "barbero_id": widget.barberoId,
      "servicio_id": widget.servicioId,
      "fecha_cita": widget.fechaCita,
      "hora_inicio": widget.horaInicio
    };

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data["ok"] == true) {
          setState(() {
            _mensajeOk = "Tu cita está confirmada.\nID: ${data["cita_id"]}";
          });
        } else {
          setState(() {
            _mensajeError = data["error"]?.toString() ?? "Error desconocido";
          });
        }
      } else {
        setState(() {
          _mensajeError = "Error HTTP ${resp.statusCode}";
        });
      }
    } catch (err) {
      setState(() {
        _mensajeError = "Error de red: $err";
      });
    } finally {
      setState(() {
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumen = """
Servicio: ${widget.servicioNombre}
Barbero: ${widget.barberoNombre}
Fecha:   ${widget.fechaCita}
Hora:    ${widget.horaInicio}
""";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
        centerTitle: true,
        title: const Text(
          'Confirmar cita',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resumen,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              if (_mensajeOk != null)
                Text(
                  _mensajeOk!,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

              if (_mensajeError != null)
                Text(
                  _mensajeError!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _enviando ? null : _confirmarCita,
                  child: _enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Confirmar cita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

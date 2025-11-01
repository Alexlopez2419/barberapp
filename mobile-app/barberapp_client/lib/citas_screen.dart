import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// MISMA IP DE LA LAPTOP
const String apiBase = "http://192.168.0.30:3000";

class CitasScreen extends StatefulWidget {
  final int usuarioId;

  const CitasScreen({super.key, required this.usuarioId});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _fetchCitas();
  }

  Future<List<Map<String, dynamic>>> _fetchCitas() async {
    final url = Uri.parse("$apiBase/citas/mis-citas/${widget.usuarioId}");
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data["ok"] == true) {
        final List<dynamic> citasList = data["citas"] ?? [];
        return citasList
            .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        setState(() {
          _error = data["error"]?.toString() ?? "Respuesta inválida";
        });
        return [];
      }
    } else {
      setState(() {
        _error = "HTTP ${resp.statusCode}";
      });
      return [];
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_bottom;
      case 'confirmada':
        return Icons.check_circle;
      case 'completada':
        return Icons.done_all;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.amber;
      case 'confirmada':
        return Colors.lightGreenAccent;
      case 'completada':
        return Colors.blueAccent;
      case 'cancelada':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Mis citas",
          style: TextStyle(color: dorado),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: dorado,
              ),
            );
          }

          if (_error != null) {
            return Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          final citas = snap.data ?? [];
          if (citas.isEmpty) {
            return const Center(
              child: Text(
                "No tenés citas aún",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, i) {
              final c = citas[i];
              final fecha = c["fecha"] ?? "";
              final hora = c["hora"] ?? "";
              final estado = c["estado"] ?? "";
              final barbero = c["barbero_nombre"] ?? "Barbero";
              final servicio = c["servicio_nombre"] ?? "Servicio";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: dorado,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _estadoIcon(estado),
                    color: _estadoColor(estado),
                  ),
                  title: Text(
                    servicio,
                    style: const TextStyle(
                      color: dorado,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "$fecha · $hora\n$barbero\nEstado: $estado",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

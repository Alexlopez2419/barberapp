import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiBase = "http://172.20.10.5:3000";


class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  late Future<List<dynamic>> _future;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = _fetchCitas();
  }

  Future<List<dynamic>> _fetchCitas() async {
    setState(() => _error = null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null || userId <= 0) {
        throw Exception('No hay sesión activa. Inicia sesión nuevamente.');
      }

      final url = Uri.parse('$apiBase/citas?usuario_id=$userId');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['ok'] == true && data['citas'] is List) {
          return List<Map<String, dynamic>>.from(data['citas']);
        } else {
          throw Exception(data['error']?.toString() ?? 'Respuesta inválida del servidor');
        }
      } else {
        throw Exception('Error HTTP ${resp.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchCitas();
    });
    await _future.catchError((_) {}); // error ya se guarda en _error
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'confirmada':
        return Icons.verified;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default: // pendiente
        return Icons.schedule;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'confirmada':
        return const Color(0xFF4CAF50);
      case 'completada':
        return const Color(0xFF90CAF9);
      case 'cancelada':
        return const Color(0xFFE57373);
      default: // pendiente
        return const Color(0xFFD4AF37);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        centerTitle: true,
        title: const Text(
          'Mis citas',
          style: TextStyle(color: dorado, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: dorado,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: dorado),
              );
            }

            if (snap.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Text(
                      _error ?? 'Ocurrió un error cargando tus citas.',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh, color: dorado),
                    label: const Text('Reintentar', style: TextStyle(color: dorado)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: dorado),
                    ),
                  ),
                ],
              );
            }

            final citas = snap.data ?? [];
            if (citas.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Aún no tienes citas.\nReserva tu primer servicio desde la pantalla principal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: citas.length,
              itemBuilder: (context, i) {
                final c = citas[i] as Map<String, dynamic>;
                final servicio = c['servicio']?.toString() ?? 'Servicio';
                final barbero = c['barbero']?.toString() ?? 'Barbero';
                final fecha = c['fecha']?.toString() ?? '';
                final hora = c['hora']?.toString() ?? '';
                final estado = c['estado']?.toString() ?? 'pendiente';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dorado, width: 1),
                  ),
                  child: ListTile(
                    leading: Icon(_estadoIcon(estado), color: _estadoColor(estado)),
                    title: Text(
                      servicio,
                      style: const TextStyle(
                        color: dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Con: $barbero\n$fecha · $hora',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _estadoColor(estado).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _estadoColor(estado)),
                      ),
                      child: Text(
                        estado[0].toUpperCase() + estado.substring(1),
                        style: TextStyle(color: _estadoColor(estado), fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // Aquí podrías abrir detalle de cita o permitir cancelar si lo deseas.
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

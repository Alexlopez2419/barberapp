import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session.dart';

// Ajusta si tu API corre en otra IP/puerto
const String apiBase = "http://192.168.0.30:3000";



class MisCitasScreen extends StatefulWidget {
  const MisCitasScreen({super.key});

  @override
  State<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends State<MisCitasScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    final user = await Session.currentUser();
    final userId = user['id'];
    if (userId == null) {
      throw Exception('No hay sesión activa.');
    }

    // Soporta dos variantes: /citas/mias?usuario_id=...  o  /citas?usuario_id=...
    Uri url = Uri.parse('$apiBase/citas/mias?usuario_id=$userId');
    var resp = await http.get(url);

    if (resp.statusCode == 404) {
      url = Uri.parse('$apiBase/citas?usuario_id=$userId');
      resp = await http.get(url);
    }

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final dynamic decoded = jsonDecode(resp.body);

    List<dynamic> listLike;
    if (decoded is List) {
      listLike = decoded;
    } else if (decoded is Map) {
      if (decoded['citas'] is List) {
        listLike = decoded['citas'];
      } else if (decoded['data'] is List) {
        listLike = decoded['data'];
      } else {
        listLike = [decoded];
      }
    } else {
      throw Exception('Formato JSON inesperado');
    }

    return listLike
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas')),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: dorado));
          }
          if (s.hasError) {
            return Center(
              child: Text(
                'Error:\n${s.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          final citas = s.data ?? [];
          if (citas.isEmpty) {
            return const Center(
              child: Text('Aún no tienes citas', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = citas[i];
              final servicio = (c['servicio'] ?? c['servicio_nombre'] ?? 'Servicio').toString();
              final barbero = (c['barbero'] ?? c['barbero_nombre'] ?? 'Barbero').toString();
              final fecha = (c['fecha'] ?? '').toString();
              final hora  = (c['hora'] ?? '').toString();
              final estado = (c['estado'] ?? '').toString();

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dorado),
                ),
                child: ListTile(
                  title: Text(servicio, style: const TextStyle(color: dorado, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Barbero: $barbero\n$fecha  $hora\nEstado: ${estado.isEmpty ? 'pendiente' : estado}',
                    style: const TextStyle(color: Colors.white70),
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

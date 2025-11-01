import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'horarios_screen.dart';

// Cambia esta IP si tu API corre en otra
const String apiBase = "http://192.168.0.30:3000";



class BarberosScreen extends StatefulWidget {
  final int servicioId;
  final String servicioNombre;
  final int servicioDuracionMin;

  const BarberosScreen({
    super.key,
    required this.servicioId,
    required this.servicioNombre,
    required this.servicioDuracionMin,
  });

  @override
  State<BarberosScreen> createState() => _BarberosScreenState();
}

class _BarberosScreenState extends State<BarberosScreen> {
  late Future<List<Map<String, dynamic>>> _futureBarberos;

  @override
  void initState() {
    super.initState();
    _futureBarberos = fetchBarberos();
  }

  Future<List<Map<String, dynamic>>> fetchBarberos() async {
    final url = Uri.parse('$apiBase/barberos');
    final resp = await http.get(url);

    // Debug opcional en consola
    // print('STATUS: ${resp.statusCode}');
    // print('BODY: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final dynamic decoded = jsonDecode(resp.body);

    // Normalizamos a List<Map<String,dynamic>>
    List<dynamic> listLike;

    if (decoded is List) {
      listLike = decoded; // La API devolvió un array puro
    } else if (decoded is Map) {
      // Buscamos una clave que tenga la lista
      if (decoded['barberos'] is List) {
        listLike = decoded['barberos'];
      } else if (decoded['data'] is List) {
        listLike = decoded['data'];
      } else if (decoded['rows'] is List) {
        listLike = decoded['rows'];
      } else {
        // Si es un único objeto, lo envolvemos como lista de 1
        listLike = [decoded];
      }
    } else {
      throw Exception('Formato JSON no reconocido');
    }

    // Aseguramos Map<String,dynamic> y solo activos si existe el flag
    final result = listLike
        .whereType<Map>() // descarta elementos no-map
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .where((e) => e['activo'] == null || e['activo'] == 1 || e['activo'] == true)
        .toList();

    if (result.isEmpty) {
      // Puede ser que el backend devolvió otra cosa
      // Lanza para que el UI muestre el mensaje en rojo
      throw Exception('No se encontraron barberos en la respuesta.');
    }

    return result;
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
          '¿Quién te atiende?',
          style: TextStyle(color: dorado, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBarberos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: dorado),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final barberos = snapshot.data ?? [];

          if (barberos.isEmpty) {
            return const Center(
              child: Text(
                'No hay barberos activos',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: barberos.length,
            itemBuilder: (context, index) {
              final barb = barberos[index];

              final nombre = (barb['nombre'] ?? 'Barbero').toString();
              final silla = (barb['silla'] ?? '').toString();
              // id puede venir como String o int, lo normalizamos a int
              final dynamic idRaw = barb['id'];
              final int? barberoId = idRaw is int
                  ? idRaw
                  : (idRaw is String ? int.tryParse(idRaw) : null);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dorado, width: 1),
                ),
                child: ListTile(
                  title: Text(
                    nombre,
                    style: const TextStyle(
                      color: dorado,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    silla.isNotEmpty ? 'Silla: $silla' : '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: dorado),
                  onTap: barberoId == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HorariosScreen(
                                servicioId: widget.servicioId,
                                barberoId: barberoId,
                                servicioNombre: widget.servicioNombre,
                                barberoNombre: nombre,
                                duracionMin: widget.servicioDuracionMin,
                                // Puedes luego cambiar a fecha seleccionada
                                fechaCita: "2025-11-02",
                              ),
                            ),
                          );
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'new_cita_screen.dart';

// Cambia apiBase si la vas a abrir desde otro dispositivo
cconst String apiBase = "http://172.20.10.5:3000";



class AgendaScreen extends StatefulWidget {
  final String fecha; // "YYYY-MM-DD"

  const AgendaScreen({
    super.key,
    required this.fecha,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  Future<List<dynamic>>? _futureCitas;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  void _loadCitas() {
    _futureCitas = fetchCitasDelDia(widget.fecha);
    setState(() {});
  }

  Future<List<dynamic>> fetchCitasDelDia(String fecha) async {
    final url = Uri.parse('$apiBase/citas/del-dia?fecha=$fecha');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['ok'] == true && data['citas'] is List) {
        return data['citas'];
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } else {
      throw Exception('HTTP ${resp.statusCode}');
    }
  }

  Future<void> _irANuevaCita() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCitaScreen(
          fechaInicial: widget.fecha,
        ),
      ),
    );
    _loadCitas(); // recargar agenda al volver
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dorado),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Agenda ${widget.fecha}',
          style: const TextStyle(
            color: dorado,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: dorado,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: _irANuevaCita,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCitas,
        builder: (context, snapshot) {
          // cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: dorado,
              ),
            );
          }

          // error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            );
          }

          final citas = snapshot.data ?? [];

          if (citas.isEmpty) {
            return const Center(
              child: Text(
                'No hay citas para este día',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];

              final horaInicio = (cita['hora_inicio'] ?? '').toString();
              final horaFin    = (cita['hora_fin']    ?? '').toString();
              final servicio   = (cita['servicio']    ?? '').toString();
              final barbero    = (cita['barbero']     ?? '').toString();
              final estado     = (cita['estado']      ?? '').toString();

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
                  title: Text(
                    '$horaInicio - $horaFin',
                    style: const TextStyle(
                      color: dorado,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$servicio\n$barbero · $estado',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
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

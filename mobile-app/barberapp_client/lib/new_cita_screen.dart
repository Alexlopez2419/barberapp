import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Usa la misma base que agenda_screen.dart
const String apiBase = "http://192.168.0.30:3000";




class NewCitaScreen extends StatefulWidget {
  final String fechaInicial; // ej. "2025-11-02"

  const NewCitaScreen({
    super.key,
    required this.fechaInicial,
  });

  @override
  State<NewCitaScreen> createState() => _NewCitaScreenState();
}

class _NewCitaScreenState extends State<NewCitaScreen> {
  dynamic _servicioSel;
  dynamic _barberoSel;
  String? _fechaSel;
  String? _horaSel;

  List<dynamic> _servicios = [];
  List<dynamic> _barberos = [];
  List<String> _horasDisponibles = [];

  bool _loadingServicios = true;
  bool _loadingBarberos = true;
  bool _loadingHoras = false;
  bool _saving = false;

  String? _mensajeError;
  String? _mensajeOk;

  @override
  void initState() {
    super.initState();
    _fechaSel = widget.fechaInicial;
    _loadServicios();
    _loadBarberos();
  }

  Future<void> _loadServicios() async {
    setState(() {
      _loadingServicios = true;
    });
    final url = Uri.parse('$apiBase/servicios');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['ok'] == true && data['servicios'] is List) {
        _servicios = data['servicios'];
      }
    }
    setState(() {
      _loadingServicios = false;
    });
  }

  Future<void> _loadBarberos() async {
    setState(() {
      _loadingBarberos = true;
    });
    final url = Uri.parse('$apiBase/barberos');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['ok'] == true && data['barberos'] is List) {
        _barberos = data['barberos'];
      }
    }
    setState(() {
      _loadingBarberos = false;
    });
  }

  Future<void> _loadHorasDisponibles() async {
    if (_fechaSel == null || _servicioSel == null || _barberoSel == null) {
      return;
    }

    setState(() {
      _loadingHoras = true;
      _horasDisponibles = [];
      _horaSel = null;
      _mensajeError = null;
    });

    final url = Uri.parse(
      '$apiBase/disponibilidad?fecha=$_fechaSel'
      '&barbero_id=${_barberoSel['id']}'
      '&servicio_id=${_servicioSel['id']}',
    );

    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['ok'] == true && data['slots'] is List) {
        _horasDisponibles = (data['slots'] as List)
            .map((slot) => slot['hora'].toString())
            .toList();
      } else {
        _mensajeError = 'Respuesta inválida de disponibilidad';
      }
    } else {
      _mensajeError = 'Error HTTP ${resp.statusCode}';
    }

    setState(() {
      _loadingHoras = false;
    });
  }

  Future<void> _guardarCita() async {
    if (_servicioSel == null ||
        _barberoSel == null ||
        _fechaSel == null ||
        _horaSel == null) {
      setState(() {
        _mensajeError = 'Faltan datos';
        _mensajeOk = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _mensajeError = null;
      _mensajeOk = null;
    });

    // usuario_id fijo por ahora
    final body = {
      'usuario_id': 1,
      'barbero_id': _barberoSel['id'],
      'servicio_id': _servicioSel['id'],
      'fecha_cita': _fechaSel,
      'hora_inicio': _horaSel,
    };

    final url = Uri.parse('$apiBase/citas');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);

      if (data['ok'] == true) {
        setState(() {
          _mensajeOk = 'Cita creada (ID ${data['cita_id']})';
          _mensajeError = null;
        });
      } else {
        setState(() {
          _mensajeError = data['error']?.toString() ?? 'No se pudo crear la cita';
          _mensajeOk = null;
        });
      }
    } else {
      setState(() {
        _mensajeError =
            'Error HTTP ${resp.statusCode}: ${resp.body.toString()}';
        _mensajeOk = null;
      });
    }

    setState(() {
      _saving = false;
    });
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSel != null
          ? DateTime.parse(_fechaSel!)
          : now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _fechaSel = '$y-$m-$d';
      });
      _loadHorasDisponibles();
    }
  }

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        title: const Text(
          'Nueva cita',
          style: TextStyle(
            color: dorado,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servicio',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _loadingServicios
                ? const Text('Cargando servicios...',
                    style: TextStyle(color: Colors.white70))
                : DropdownButtonFormField<dynamic>(
                    dropdownColor: const Color(0xFF1A1A1A),
                    value: _servicioSel,
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: dorado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _servicios.map((item) {
                      final nombre = item['nombre'] ?? 'Servicio';
                      final dur = item['duracion_minutos']?.toString() ?? '?';
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          '$nombre ($dur min)',
                          style: const TextStyle(color: dorado),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _servicioSel = val;
                      });
                      _loadHorasDisponibles();
                    },
                  ),

            const SizedBox(height: 20),

            const Text(
              'Barbero',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _loadingBarberos
                ? const Text('Cargando barberos...',
                    style: TextStyle(color: Colors.white70))
                : DropdownButtonFormField<dynamic>(
                    dropdownColor: const Color(0xFF1A1A1A),
                    value: _barberoSel,
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: dorado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _barberos.map((item) {
                      final nombre = item['nombre'] ?? 'Barbero';
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          nombre,
                          style: const TextStyle(color: dorado),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _barberoSel = val;
                      });
                      _loadHorasDisponibles();
                    },
                  ),

            const SizedBox(height: 20),

            const Text(
              'Fecha',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dorado),
                    ),
                    child: Text(
                      _fechaSel ?? 'Selecciona fecha',
                      style: const TextStyle(color: dorado),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _pickFecha,
                  icon: const Icon(Icons.calendar_today, color: dorado),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Hora disponible',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _loadingHoras
                ? const Text('Cargando horas...',
                    style: TextStyle(color: Colors.white70))
                : DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1A1A1A),
                    value: _horaSel,
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: dorado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: dorado, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _horasDisponibles.map((h) {
                      return DropdownMenuItem(
                        value: h,
                        child: Text(
                          h,
                          style: const TextStyle(color: dorado),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _horaSel = val;
                      });
                    },
                  ),

            const SizedBox(height: 24),

            if (_mensajeError != null)
              Text(
                _mensajeError!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),

            if (_mensajeOk != null)
              Text(
                _mensajeOk!,
                style: const TextStyle(
                  color: dorado,
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dorado,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saving ? null : _guardarCita,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Guardar cita',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

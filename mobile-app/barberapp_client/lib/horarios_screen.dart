import 'package:flutter/material.dart';

class HorariosScreen extends StatelessWidget {
  final int servicioId;
  final int barberoId;
  final String servicioNombre;
  final String barberoNombre;
  final int duracionMin;
  final String fechaCita;

  const HorariosScreen({
    super.key,
    required this.servicioId,
    required this.barberoId,
    required this.servicioNombre,
    required this.barberoNombre,
    required this.duracionMin,
    required this.fechaCita,
  });

  @override
  Widget build(BuildContext context) {
    const colorDorado = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: colorDorado,
        centerTitle: true,
        title: const Text(
          'Selecciona un horario',
          style: TextStyle(
            color: colorDorado,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHorarioCard(context, '10:00 AM'),
          _buildHorarioCard(context, '10:30 AM'),
          _buildHorarioCard(context, '11:00 AM'),
          _buildHorarioCard(context, '11:30 AM'),
          _buildHorarioCard(context, '12:00 PM'),
        ],
      ),
    );
  }

  Widget _buildHorarioCard(BuildContext context, String horario) {
    const colorDorado = Color(0xFFD4AF37);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorDorado,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          horario,
          style: const TextStyle(
            color: colorDorado,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: colorDorado,
        ),
        onTap: () {
          // Aquí es donde confirmamos la cita
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar cita'),
              content: Text(
                'Servicio: $servicioNombre\nBarbero: $barberoNombre\nHorario: $horario\nDuración: $duracionMin minutos',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // Aquí agregamos lógica para guardar la cita
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita agendada')),
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

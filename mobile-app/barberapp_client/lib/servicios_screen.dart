import 'package:flutter/material.dart';
import 'barberos_screen.dart';
import 'citas_screen.dart';

class ServiciosScreen extends StatelessWidget {
  final int usuarioId;
  final String nombreUsuario;

  const ServiciosScreen({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Servicios disponibles',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              'Hola, $nombreUsuario',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note, color: dorado),
            tooltip: 'Mis citas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CitasScreen(usuarioId: usuarioId),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardServicio(
            context,
            nombreServicio: 'Corte de Caballero',
            duracion: 'Duración: 30 min',
            precio: '\$10.00',
            servicioId: 1,
            minutos: 30,
          ),
          _cardServicio(
            context,
            nombreServicio: 'Arreglo de Barba',
            duracion: 'Duración: 20 min',
            precio: '\$5.00',
            servicioId: 2,
            minutos: 20,
          ),
        ],
      ),
    );
  }

  Widget _cardServicio(
    BuildContext context, {
    required String nombreServicio,
    required String duracion,
    required String precio,
    required int servicioId,
    required int minutos,
  }) {
    const dorado = Color(0xFFD4AF37);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dorado, width: 1),
      ),
      child: ListTile(
        title: Text(
          nombreServicio,
          style: const TextStyle(
            color: dorado,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$duracion · $precio',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: dorado),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BarberosScreen(
                servicioId: servicioId,
                servicioNombre: nombreServicio,
                servicioDuracionMin: minutos,
              ),
            ),
          );
        },
      ),
    );
  }
}

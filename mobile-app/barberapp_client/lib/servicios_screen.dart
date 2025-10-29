import 'package:flutter/material.dart';
import 'barberos_screen.dart';
import 'citas_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dorado = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: dorado,
        centerTitle: true,
        title: const Text(
          'Servicios disponibles',
          style: TextStyle(color: dorado, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botón Mis Citas
          IconButton(
            icon: const Icon(Icons.event_note, color: dorado),
            tooltip: 'Mis citas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CitasScreen()),
              );
            },
          ),
          // Menú de usuario (cerrar sesión)
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: dorado),
            onSelected: (v) async {
              if (v == 'logout') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cardServicio(
            context,
            'Corte de Caballero',
            'Duración: 30 min',
            '\$10.00',
            1,
            30,
          ),
          _cardServicio(
            context,
            'Arreglo de Barba',
            'Duración: 20 min',
            '\$5.00',
            2,
            20,
          ),
          _cardServicio(
            context,
            'Corte + Barba',
            'Duración: 45 min',
            '\$12.00',
            3,
            45,
          ),
        ],
      ),
    );
  }

  Widget _cardServicio(
    BuildContext context,
    String nombre,
    String duracion,
    String precio,
    int id,
    int minutos,
  ) {
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
          nombre,
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
                servicioId: id,
                servicioNombre: nombre,
                servicioDuracionMin: minutos,
              ),
            ),
          );
        },
      ),
    );
  }
}

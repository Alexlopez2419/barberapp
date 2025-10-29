import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'servicios_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _Gate(),
    );
  }
}

/// Verifica si hay sesión guardada y decide a dónde ir.
class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  Future<bool>? _f;

  @override
  void initState() {
    super.initState();
    _f = _checkSession();
  }

  Future<bool> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return userId != null && userId > 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _f,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
          );
        }
        final logged = snap.data!;
        return logged ? const ServiciosScreen() : const LoginScreen();
      },
    );
  }
}

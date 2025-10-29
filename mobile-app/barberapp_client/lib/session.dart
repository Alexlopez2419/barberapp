import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _kLogged = 'logged';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserPhone = 'user_phone';

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLogged) ?? false;
    }

  static Future<void> saveUser({
    required int id,
    required String nombre,
    required String telefono,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLogged, true);
    await p.setInt(_kUserId, id);
    await p.setString(_kUserName, nombre);
    await p.setString(_kUserPhone, telefono);
  }

  static Future<Map<String, dynamic>> currentUser() async {
    final p = await SharedPreferences.getInstance();
    return {
      'id': p.getInt(_kUserId),
      'nombre': p.getString(_kUserName),
      'telefono': p.getString(_kUserPhone),
    };
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kLogged);
    await p.remove(_kUserId);
    await p.remove(_kUserName);
    await p.remove(_kUserPhone);
  }
}

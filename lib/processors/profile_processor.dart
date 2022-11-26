import 'package:shared_preferences/shared_preferences.dart';

class ProfileProcessor {
  bool savedUsername = false;

  Future<SharedPreferences> _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<String> getUsername() async {
    var prefs = await _getPrefs();
    String username = prefs.getString('username') ?? '';

    return username;
  }

  Future<void> setUsername(String username) async {
    var prefs = await _getPrefs();
    await prefs.setString('username', username);
  }
}

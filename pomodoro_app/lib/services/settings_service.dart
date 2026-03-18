import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {

  /// vibration
  Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("vibration") ?? true;
  }

  Future setVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("vibration", value);
  }

  /// sound
  Future<bool> getSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("sound") ?? true;
  }

  Future setSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("sound", value);
  }

  /// notification
  Future<bool> getNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("notification") ?? true;
  }

  Future setNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("notification", value);
  }

}
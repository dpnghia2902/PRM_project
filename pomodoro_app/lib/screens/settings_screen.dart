import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static bool vibration = true;
  static bool sound = true;
  static bool notification = true;

  static int pomodoro = 25;
  static int shortBreak = 5;
  static int longBreak = 15;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController pomoController;
  late TextEditingController shortController;
  late TextEditingController longController;

  bool vibration = true;
  bool sound = true;
  bool notification = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    vibration = prefs.getBool("vibration") ?? true;
    sound = prefs.getBool("sound") ?? true;
    notification = prefs.getBool("notification") ?? true;

    int pomo = prefs.getInt("pomodoro") ?? 25;
    int shortB = prefs.getInt("shortBreak") ?? 5;
    int longB = prefs.getInt("longBreak") ?? 15;

    SettingsScreen.pomodoro = pomo;
    SettingsScreen.shortBreak = shortB;
    SettingsScreen.longBreak = longB;

    pomoController = TextEditingController(text: pomo.toString());
    shortController = TextEditingController(text: shortB.toString());
    longController = TextEditingController(text: longB.toString());

    setState(() {});
  }

  Future saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    int pomo = int.tryParse(pomoController.text) ?? 25;
    int shortB = int.tryParse(shortController.text) ?? 5;
    int longB = int.tryParse(longController.text) ?? 15;

    await prefs.setInt("pomodoro", pomo);
    await prefs.setInt("shortBreak", shortB);
    await prefs.setInt("longBreak", longB);

    await prefs.setBool("vibration", vibration);
    await prefs.setBool("sound", sound);
    await prefs.setBool("notification", notification);

    SettingsScreen.pomodoro = pomo;
    SettingsScreen.shortBreak = shortB;
    SettingsScreen.longBreak = longB;

    SettingsScreen.vibration = vibration;
    SettingsScreen.sound = sound;
    SettingsScreen.notification = notification;

    Navigator.pop(context);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Widget toggleItem(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              onChanged(v);
            },
          )
        ],
      ),
    );
  }

  Widget timeField(String label, IconData icon, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget themePicker(ThemeProvider provider) {
    final themeList = AppTheme.values;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Theme Color",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: themeList.map((t) {
              Color color;
              switch (t) {
                case AppTheme.red:
                  color = Colors.red;
                  break;
                case AppTheme.blue:
                  color = Colors.blue;
                  break;
                case AppTheme.green:
                  color = Colors.green;
                  break;
                case AppTheme.purple:
                  color = Colors.purple;
                  break;
                case AppTheme.orange:
                  color = Colors.orange;
                  break;
              }
              return GestureDetector(
                onTap: () {
                  provider.setTheme(t);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: provider.theme == t
                        ? Border.all(width: 3, color: Colors.black)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || pomoController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Bao toàn bộ trong Consumer để rebuild khi theme đổi
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// TIME SETTINGS
                timeField("Pomodoro Minutes", Icons.timer, pomoController),
                timeField("Short Break Minutes", Icons.free_breakfast, shortController),
                timeField("Long Break Minutes", Icons.hotel, longController),

                const SizedBox(height: 20),

                /// SOUND
                toggleItem("Sound", sound, (v) {
                  setState(() {
                    sound = v;
                  });
                }),

                /// VIBRATION
                toggleItem("Vibration", vibration, (v) {
                  setState(() {
                    vibration = v;
                  });
                }),

                /// NOTIFICATION
                toggleItem("Notification", notification, (v) {
                  setState(() {
                    notification = v;
                  });
                }),

                const SizedBox(height: 20),

                /// THEME PICKER
                themePicker(themeProvider),

                const SizedBox(height: 20),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveSettings,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text(
                      "Save Settings",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: logout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 16, color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
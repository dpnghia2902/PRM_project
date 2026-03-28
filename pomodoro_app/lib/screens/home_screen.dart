import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'notes_screen.dart';
import 'admin/admin_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  String? avatar;
  String role = "user";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      var data = await api.getProfile();
      setState(() {
        avatar = data["avatar"];
        role = data["role"] ?? "user";
      });
    } catch (e) {
      print(e);
    }
  }

  ImageProvider getAvatar() {
    if (avatar != null) {
      return NetworkImage("http://138.252.133.79:5000$avatar");
    }
    return const NetworkImage("https://i.pravatar.cc/150");
  }

  /// Build một nút tròn trong GridView (Home)
  Widget buildButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors.primary.withOpacity(0.15),
              child: Icon(
                icon,
                size: 26,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.getThemeData();
        final colors = theme.colorScheme;

        // Màu AppBar chỉ đậm hơn nền một chút (clean, không quá nổi)
        final appBarColor = colors.background.withOpacity(0.96);
        final appBarTextColor = colors.onBackground.withOpacity(0.88);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: Text(
              "Pomodoro",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appBarTextColor,
                fontSize: 17,
              ),
            ),
            centerTitle: true,
            backgroundColor: appBarColor,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                    loadProfile(); // reload avatar
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: colors.primary.withOpacity(0.18),
                    backgroundImage: getAvatar(),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                buildButton(
                  icon: Icons.timer,
                  title: "Start",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TaskScreen()),
                    );
                  },
                ),
                buildButton(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                  },
                ),
                buildButton(
                  icon: Icons.note,
                  title: "Notes",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotesScreen()),
                    );
                  },
                ),
                buildButton(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsScreen()),
                    );
                  },
                ),
                if (role == "admin")
                  buildButton(
                    icon: Icons.admin_panel_settings,
                    title: "Admin",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

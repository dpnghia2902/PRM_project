import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';  
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService.init();
  final themeProvider = ThemeProvider()..loadTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "Pomodoro App",
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getThemeData(),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),        // ✅ SplashScreen OK
            '/onboarding': (context) => OnboardingScreen(), // ✅ Bỏ const
            '/login': (context) => LoginScreen(),          // ✅ Bỏ const
          },
        );
      },
    );
  }
}

// 🔥 SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (mounted) {
      if (isCompleted) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.getThemeData().scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.getThemeData().primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.timer_outlined,
                size: 80,
                color: themeProvider.getThemeData().primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Pomodoro App',
              style: themeProvider.getThemeData().textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeProvider.getThemeData().primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                themeProvider.getThemeData().primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

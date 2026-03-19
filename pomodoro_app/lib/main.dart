import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Khởi tạo NotificationService trước
  await NotificationService.init();

  // ✅ Tạo 1 instance DUY NHẤT và loadTheme() CHỈ 1 LẦN
  final themeProvider = ThemeProvider()..loadTheme();

  // ✅ KHÔNG gọi loadTheme() lần 2!

  // ✅ Chạy app với Provider duy nhất
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,  // Dùng instance đã load theme
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
          theme: themeProvider.getThemeData(),  // ✅ Theme động
          home: LoginScreen(), 
        );
      },
    );
  }
}

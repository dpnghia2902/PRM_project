import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pomodoro App",
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }

}
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();

  String? errorMessage;

  login() async {

    var res = await api.login(
      emailController.text,
      passwordController.text,
    );

    if(res["token"] != null){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );

    }else{

      setState(() {
        errorMessage = res["message"] ?? "Wrong email or password";
      });

    }
  }

@override
Widget build(BuildContext context) {
  return Consumer<ThemeProvider>(  // ✅ THÊM Consumer
    builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: themeProvider.getThemeData().primaryColor,  // ✅ OK
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  /// TITLE
                  Text(
                    "Pomodoro",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,  // ✅ Thêm màu trắng cho đẹp
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Focus better, work smarter",
                    style: TextStyle(
                      color: Colors.white70,  // ✅ Trắng nhạt theo theme
                    ),
                  ),
                  SizedBox(height: 40),

                  /// LOGIN CARD
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5)
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        /// EMAIL
                        TextField(
                          controller: emailController,
                          onChanged: (_) {
                            if (errorMessage != null) {
                              setState(() {
                                errorMessage = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)
                            )
                          ),
                        ),
                        SizedBox(height: 15),

                        /// PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          onChanged: (_) {
                            if (errorMessage != null) {
                              setState(() {
                                errorMessage = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)
                            )
                          ),
                        ),

                        /// ERROR MESSAGE
                        if (errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),

                        SizedBox(height: 20),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              )
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        /// REGISTER LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen()
                                  )
                                );
                              },
                              child: Text("Register")
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

}
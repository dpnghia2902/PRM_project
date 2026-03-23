import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();

  String? errorMessage;
  bool isLoading = false;
  String? emailError; // ✅ Email validation

  // ✅ EMAIL VALIDATION
  String? validateEmail(String email) {
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Future<void> login() async {
    if (isLoading) return;

    // ✅ Validate email trước khi gọi API
    final emailError = validateEmail(emailController.text.trim());
    if (emailError != null) {
      setState(() {
        this.emailError = emailError;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      this.emailError = null;
    });

    try {
      var res = await api.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (res["token"] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        setState(() {
          errorMessage = res["message"] ?? "Sai email hoặc mật khẩu";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Đăng nhập thất bại. Vui lòng thử lại.";
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.getThemeData();
        final primaryColor = theme.primaryColor;
        final scaffoldBg = theme.scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Stack(
              children: [
                // Background gradient nhẹ
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scaffoldBg,
                          primaryColor.withOpacity(0.02),
                          primaryColor.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Floating decoration tinh tế
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60), // ✅ Top spacing hài hòa
                      
                      // Header
                      Text(
                        "Chào mừng trở lại",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Đăng nhập để tiếp tục hành trình tăng năng suất của bạn",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 48), // ✅ Spacing chuẩn
                      
                      // Main form card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.cardColor ?? Colors.white,
                              (theme.cardColor ?? Colors.white).withOpacity(0.97),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.12),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // EMAIL FIELD + VALIDATION
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: emailError != null 
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                onChanged: (value) {
                                  if (errorMessage != null || emailError != null) {
                                    setState(() {
                                      errorMessage = null;
                                      emailError = validateEmail(value.trim());
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: emailError != null 
                                      ? Colors.red[400]
                                      : primaryColor.withOpacity(0.7),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  suffixIcon: emailController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                                          onPressed: () {
                                            emailController.clear();
                                            setState(() {
                                              emailError = null;
                                              errorMessage = null;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            // Email error
                            if (emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    emailError!,
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            
                            // PASSWORD FIELD
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                              ),
                              child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                onChanged: (_) => errorMessage != null ? setState(() => errorMessage = null) : null,
                                decoration: InputDecoration(
                                  labelText: "Mật khẩu",
                                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  suffixIcon: passwordController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                                          onPressed: () => passwordController.clear(),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            
                            // API ERROR
                            if (errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 36),
                            
                            // LOGIN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                                  elevation: 0,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login, size: 22),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Đăng nhập",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // REGISTER LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Chưa có tài khoản? ",
                                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                                  ),
                                  child: Text(
                                    "Đăng ký ngay",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // ✅ Bottom spacing hài hòa
                    ],
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

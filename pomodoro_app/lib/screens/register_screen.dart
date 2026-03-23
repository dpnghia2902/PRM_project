 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final ApiService api = ApiService();

  String gender = "male";
  String? errorMessage;
  bool isLoading = false;

  // ✅ Validation
  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmError;
  String passwordStrength = 'weak'; // weak, medium, strong

  // ✅ VALIDATION FUNCTIONS
  String? validateName(String name) {
    if (name.isEmpty) return 'Vui lòng nhập họ tên';
    if (name.length < 2) return 'Họ tên phải từ 2 ký tự';
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String _checkPasswordStrength(String password) {
    if (password.length < 6) return 'weak';
    if (password.length >= 8 && RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'strong';
    }
    return 'medium';
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (password.length < 6) return 'Mật khẩu phải từ 6 ký tự';
    return null;
  }

  Future<void> register() async {
    if (isLoading) return;

    // ✅ Full validation
    final nameError = validateName(nameController.text.trim());
    final emailError = validateEmail(emailController.text.trim());
    final passwordError = validatePassword(passwordController.text);
    final confirmError = passwordController.text != confirmController.text 
        ? 'Mật khẩu không khớp' 
        : null;

    if (nameError != null || emailError != null || passwordError != null || confirmError != null) {
      setState(() {
        this.nameError = nameError;
        this.emailError = emailError;
        this.passwordError = passwordError;
        this.confirmError = confirmError;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var res = await api.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        gender,
      );

      if (res["message"] == "User created") {
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = res["message"] ?? "Đăng ký thất bại";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Đăng ký thất bại. Vui lòng thử lại.";
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
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
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Tạo tài khoản",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: primaryColor,
            centerTitle: true,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // Background gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scaffoldBg,
                          primaryColor.withOpacity(0.02),
                          primaryColor.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header
                      Text(
                        "Tạo tài khoản mới",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Điền thông tin để bắt đầu hành trình Pomodoro của bạn",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Main form
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                            // FULL NAME
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: nameError != null 
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: nameController,
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) {
                                  if (nameError != null || errorMessage != null) {
                                    setState(() {
                                      nameError = validateName(value.trim());
                                      errorMessage = null;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Họ và tên",
                                  prefixIcon: Icon(Icons.person_outline, 
                                    color: nameError != null 
                                      ? Colors.red[400] 
                                      : primaryColor.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  suffixIcon: nameController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                                          onPressed: () {
                                            nameController.clear();
                                            setState(() => nameError = null);
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (nameError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    nameError!,
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // EMAIL
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
                                onChanged: (value) {
                                  if (emailError != null || errorMessage != null) {
                                    setState(() {
                                      emailError = validateEmail(value.trim());
                                      errorMessage = null;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(Icons.email_outlined, 
                                    color: emailError != null 
                                      ? Colors.red[400] 
                                      : primaryColor.withOpacity(0.7)),
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
                                            setState(() => emailError = null);
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
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

                            // PASSWORD + STRENGTH
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: passwordError != null 
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    passwordStrength = _checkPasswordStrength(value);
                                    passwordError = validatePassword(value);
                                    if (confirmError != null) {
                                      confirmError = passwordController.text == confirmController.text ? null : 'Mật khẩu không khớp';
                                    }
                                    errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Mật khẩu",
                                  prefixIcon: Icon(Icons.lock_outline, 
                                    color: passwordError != null 
                                      ? Colors.red[400] 
                                      : primaryColor.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  suffixIcon: passwordController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                                          onPressed: () {
                                            passwordController.clear();
                                            setState(() {
                                              passwordStrength = 'weak';
                                              passwordError = null;
                                              confirmError = null;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            // Password strength indicator
                            const SizedBox(height: 8),
                            // Strength bar
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: passwordStrength == 'strong' ? 1.0 :
                                                  passwordStrength == 'medium' ? 0.6 : 0.3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: passwordStrength == 'strong' 
                                              ? [Colors.green[400]!, Colors.green[600]!]
                                              : passwordStrength == 'medium'
                                                ? [Colors.orange[400]!, Colors.orange[600]!]
                                                : [Colors.red[400]!, Colors.red[600]!],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  passwordStrength.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: passwordStrength == 'strong'
                                        ? Colors.green[600]
                                        : passwordStrength == 'medium'
                                            ? Colors.orange[600]
                                            : Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                            if (passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    passwordError!,
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // CONFIRM PASSWORD
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: confirmError != null 
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: confirmController,
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    confirmError = passwordController.text == value 
                                        ? null 
                                        : 'Mật khẩu không khớp';
                                    errorMessage = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Xác nhận mật khẩu",
                                  prefixIcon: Icon(Icons.lock_outline, 
                                    color: confirmError != null 
                                      ? Colors.red[400] 
                                      : primaryColor.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  suffixIcon: confirmController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                                          onPressed: () {
                                            confirmController.clear();
                                            setState(() => confirmError = null);
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (confirmError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    confirmError!,
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // GENDER ✅ Modern segmented button
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Giới tính: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSegmentedButton("Nam", "male", gender == "male"),
                                  const SizedBox(width: 12),
                                  _buildSegmentedButton("Nữ", "female", gender == "female"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // API ERROR
                            if (errorMessage != null) ...[
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
                              const SizedBox(height: 20),
                            ],

                            // REGISTER BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                                  elevation: 0,
                                  shadowColor: primaryColor.withOpacity(0.3),
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
                                          const Icon(Icons.person_add, size: 22),
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Tạo tài khoản",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
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

  Widget _buildSegmentedButton(String label, String value, bool isSelected) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? primaryColor : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

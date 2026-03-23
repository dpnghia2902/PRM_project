import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': ' Pomodoro Timer',
      'description': 'Làm việc 25 phút, nghỉ 5 phút\nTăng năng suất 80%',
    },
    {
      'title': ' Quản lý Task',
      'description': 'Chia nhỏ công việc\nTheo dõi tiến độ từng pomodoro',
    },
    {
      'title': ' Tùy chỉnh linh hoạt',
      'description': 'Thay đổi thời gian\nThông báo, rung, tuỳ chọn layout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getThemeData().scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: _pages.map((page) => _buildPage(page, themeProvider)).toList(),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 40),
                if (_currentPage == _pages.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.getThemeData().primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                      ),
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'BẮT ĐẦU NGAY!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, String> page, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeProvider.getThemeData().primaryColor.withOpacity(0.1), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: themeProvider.getThemeData().primaryColor.withOpacity(0.2)),
            ),
            child: Icon(
              _getPageIcon(_currentPage),
              size: 120,
              color: themeProvider.getThemeData().primaryColor,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            page['title']!,
            style: themeProvider.getThemeData().textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: themeProvider.getThemeData().primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page['description']!,
            style: themeProvider.getThemeData().textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getPageIcon(int index) {
    switch (index) {
      case 0: return Icons.timer;
      case 1: return Icons.task_alt;
      case 2: return Icons.settings;
      default: return Icons.timer;
    }
  }

  Widget _buildDot(int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? themeProvider.getThemeData().primaryColor 
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import 'package:vibration/vibration.dart';

// Enum cho kiểu hiển thị đồng hồ
enum ClockDisplayType { digital, analog }

class PomodoroScreen extends StatefulWidget {
  final List<Task> tasks;

  const PomodoroScreen({super.key, required this.tasks});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final ApiService api = ApiService();

  int currentTaskIndex = 0;
  int pomoCount = 0;

  bool isBreak = false;
  bool isLongBreak = false;
  bool freeMode = false;

  bool isRunning = false;
  bool isPaused = false;

  late int timeLeft;
  Timer? timer;
  
  // Thêm biến cho kiểu hiển thị đồng hồ
  ClockDisplayType clockDisplayType = ClockDisplayType.digital;

  @override
  void initState() {
    super.initState();
    timeLeft = SettingsScreen.pomodoro * 60;
    
    if (kDebugMode) {
      print('PomodoroScreen: ${widget.tasks.length} tasks');
    }
  }

  // Chuyển đổi kiểu đồng hồ
  void toggleClockDisplayType() {
    if (isRunning || isPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop timer trước khi đổi kiểu đồng hồ')),
      );
      return;
    }
    
    setState(() {
      clockDisplayType = clockDisplayType == ClockDisplayType.digital 
          ? ClockDisplayType.analog 
          : ClockDisplayType.digital;
    });
  }

  void startTimer() {
    timer?.cancel();
    
    if (!mounted) return;

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      if (timeLeft > 0) {
        if (mounted) {
          setState(() => timeLeft--);
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => isRunning = false);
          handleFinish();
        }
      }
    });
  }

  void stopTimer() {
    timer?.cancel();

    if (mounted) {
      setState(() {
        isRunning = false;
        isPaused = true;
      });
    }
  }

  void resumeTimer() {
    timer?.cancel();
    
    if (!mounted) return;

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      if (timeLeft > 0) {
        if (mounted) {
          setState(() => timeLeft--);
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => isRunning = false);
          handleFinish();
        }
      }
    });
  }

  Future<void> notifyFinish() async {
    try {
      if (!kIsWeb && SettingsScreen.notification) {
        await NotificationService().showNotification();
      }
    } catch (e) {
      debugPrint('Notification failed: $e');
    }

    try {
      if (!kIsWeb && !Platform.isIOS && SettingsScreen.vibration) {
        bool? hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 500);
        }
      }
    } catch (e) {
      debugPrint('Vibration failed: $e');
    }
  }

  Future<void> handleFinish() async {
    await notifyFinish();

    if (isBreak) {
      isBreak = false;
      isLongBreak = false;

      if (mounted) {
        setState(() {
          timeLeft = SettingsScreen.pomodoro * 60;
        });
        startTimer();
      }
      return;
    }

    if (widget.tasks.isNotEmpty && !freeMode) {
      Task task = widget.tasks[currentTaskIndex];

      if (mounted) {
        setState(() {
          task.completedPomodoro++;
        });
      }

      await api.createPomodoro(SettingsScreen.pomodoro, task.id);

      if (task.completedPomodoro >= task.totalPomodoro) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.task_alt, color: Colors.green),
                SizedBox(width: 12),
                Text("Task finished?"),
              ],
            ),
            content: Text("Have you completed '${task.title}'?"),
            actions: [
              TextButton(
                child: const Text("Not yet"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Done"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (confirm == true && mounted) {
          setState(() {
            task.completed = true;
          });
          await api.completeTask(task.id);

          if (currentTaskIndex < widget.tasks.length - 1) {
            if (mounted) {
              setState(() => currentTaskIndex++);
            }
          } else {
            bool? cont = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    SizedBox(width: 12),
                    Text("All tasks finished!"),
                  ],
                ),
                content: const Text("Continue Pomodoro?"),
                actions: [
                  TextButton(
                    child: const Text("Stop"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Continue"),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (cont == true && mounted) {
              setState(() => freeMode = true);
            }
          }
        } else if (mounted) {
          setState(() => task.totalPomodoro++);
        }
      }
    } else {
      await api.createPomodoro(SettingsScreen.pomodoro, null);
    }

    pomoCount++;

    if (pomoCount % 4 == 0) {
      isBreak = true;
      isLongBreak = true;
      if (mounted) {
        setState(() => timeLeft = SettingsScreen.longBreak * 60);
      }
    } else {
      isBreak = true;
      if (mounted) {
        setState(() => timeLeft = SettingsScreen.shortBreak * 60);
      }
    }

    startTimer();
  }

  String formatTime() {
    int m = timeLeft ~/ 60;
    int s = timeLeft % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  String getPhase() {
    if (isBreak && isLongBreak) return "Long Break";
    if (isBreak) return "Short Break";
    return "Pomodoro";
  }

  Color getColor() {
    final theme = Theme.of(context);
    
    if (kIsWeb) {
      if (isBreak && isLongBreak) return theme.colorScheme.error;
      if (isBreak) return theme.colorScheme.secondary;
      return theme.primaryColor;
    } else {
      if (isBreak && isLongBreak) return Colors.red[400]!;
      if (isBreak) return Colors.orange[400]!;
      return theme.primaryColor;
    }
  }

  // Dialog chọn kiểu đồng hồ
  void _showClockStyleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Chọn kiểu đồng hồ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildClockStyleOption(ClockDisplayType.digital, Icons.numbers, 'Digital', 'Số lớn rõ ràng'),
            _buildClockStyleOption(ClockDisplayType.analog, Icons.watch, 'Analog', 'Đồng hồ kim'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClockStyleOption(ClockDisplayType type, IconData icon, String title, String subtitle) {
    bool isSelected = clockDisplayType == type;
    Color color = getColor();
    
    return GestureDetector(
      onTap: () {
        setState(() {
          clockDisplayType = type;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                    color: isSelected ? color : null,
                  )),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color phaseColor = getColor();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Pomodoro", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Phase indicator
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [phaseColor, phaseColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_filled, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      getPhase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 TIMER CIRCLE - DIGITAL/ANALOG CHUYỂN ĐỔI ✅
              GestureDetector(
                onTap: () => _showClockStyleSelector(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 260,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vòng ngoài tương tác
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: phaseColor.withOpacity(0.4), width: 8),
                          boxShadow: [
                            BoxShadow(
                              color: phaseColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // Đồng hồ chính
                      _buildClockDisplay(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Control button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: phaseColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isRunning && !isPaused) {
                      startTimer();
                    } else if (isRunning) {
                      stopTimer();
                    } else if (isPaused) {
                      resumeTimer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: phaseColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(160, 70),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunning ? Icons.pause_circle_filled : Icons.play_arrow,
                        size: 28,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        !isRunning && !isPaused ? "Start" : isRunning ? "Stop" : "Resume",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Task list
              Container(
                constraints: BoxConstraints(
                  minHeight: 220,
                  maxHeight: 300,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.task_alt, 
                              color: Theme.of(context).iconTheme.color ?? Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            "Tasks",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: phaseColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Pomo $pomoCount",
                              style: TextStyle(
                                color: phaseColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: widget.tasks.isEmpty
                          ? Container(
                              height: 100,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.assignment_turned_in, 
                                      color: Colors.grey[400], size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No tasks yet\nStart with Pomodoro!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: widget.tasks.length,
                              itemBuilder: (context, index) {
                                Task task = widget.tasks[index];
                                bool isCurrent = index == currentTaskIndex;
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Colors.blue.withOpacity(0.1)
                                        : task.completed
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isCurrent
                                        ? Border.all(color: phaseColor.withOpacity(0.5), width: 2)
                                        : null,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    dense: true,
                                    leading: Container(
                                      width: 6,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: task.completed ? Colors.green : phaseColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            decoration: task.completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ) ?? const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 4,
                                            child: LinearProgressIndicator(
                                              value: task.totalPomodoro > 0
                                                  ? task.completedPomodoro / task.totalPomodoro
                                                  : 0,
                                              backgroundColor: Colors.grey[300],
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                task.completed ? Colors.green : phaseColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${task.completedPomodoro}/${task.totalPomodoro}",
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 WIDGET HIỂN THỊ ĐỒNG HỒ CHÍNH
  Widget _buildClockDisplay() {
    switch (clockDisplayType) {
      case ClockDisplayType.digital:
        return _buildDigitalClock();
      case ClockDisplayType.analog:
        return _buildAnalogClock();
    }
  }

  // 📱 DIGITAL CLOCK
  Widget _buildDigitalClock() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatTime(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: getColor(),
                height: 0.9,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: getColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.layers,
                size: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🕐 ANALOG CLOCK - ✅ KIM ĐÚNG TÂM
  Widget _buildAnalogClock() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).cardColor.withOpacity(0.95),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vẽ toàn bộ đồng hồ + kim bằng CustomPainter ✅
          CustomPaint(
            size: const Size(200, 200),
            painter: AnalogClockPainter(
              color: getColor(),
              timeLeft: timeLeft,
            ),
          ),
          // Thời gian số nhỏ (backup)
          Positioned(
            bottom: 25,
            child: Text(
              formatTime(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: getColor().withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 CustomPainter HOÀN CHỈNH - VẼ KIM + VẠCH CHIA ✅ KIM ĐÚNG TÂM
class AnalogClockPainter extends CustomPainter {
  final Color color;
  final int timeLeft;

  AnalogClockPainter({
    required this.color,
    required this.timeLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;

    // 1. VẠCH CHIA GIỜ (12 vạch lớn)
    final hourPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * math.pi / 180; // 30° mỗi giờ
      final inner = radius - 15;
      final outer = radius - 5;

      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        hourPaint,
      );
    }

    // 2. VẠCH CHIA PHÚT (48 vạch nhỏ)
    final minutePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      if (i % 5 != 0) { // Bỏ qua vạch giờ
        final angle = (i * 6.0) * math.pi / 180; // 6° mỗi phút
        final inner = radius - 10;
        final outer = radius - 5;

        canvas.drawLine(
          center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
          center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
          minutePaint,
        );
      }
    }

    // 3. KIM GIÂY - TÍNH TOÁN CHÍNH XÁC ✅ TỪ TÂM
    final totalSeconds = timeLeft;
    final seconds = totalSeconds % 60;
    final secondAngle = (seconds / 60) * 2 * math.pi;

    final secondPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Vẽ kim giây từ tâm
    canvas.drawLine(
      center,
      center + Offset(math.cos(secondAngle) * (radius - 25), 
                     math.sin(secondAngle) * (radius - 25)),
      secondPaint,
    );

    // 4. KIM PHÚT - TÍNH TOÁN CHÍNH XÁC ✅ TỪ TÂM
    final minutes = (totalSeconds / 60) % 60;
    final minuteAngle = (minutes / 60) * 2 * math.pi;

    final minutePaintHand = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Vẽ kim phút từ tâm
    canvas.drawLine(
      center,
      center + Offset(math.cos(minuteAngle) * (radius - 20), 
                     math.sin(minuteAngle) * (radius - 20)),
      minutePaintHand,
    );

    // 5. TÂM ĐỒNG HỒ
    final centerDotPaint = Paint()
      ..color = color;

    canvas.drawCircle(center, 7, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.timeLeft != timeLeft || 
           oldDelegate.color != color;
  }
}

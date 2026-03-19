import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import 'package:vibration/vibration.dart';

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

  @override
  void initState() {
    super.initState();
    timeLeft = SettingsScreen.pomodoro * 60;
    
    if (kDebugMode) {
      print('PomodoroScreen: ${widget.tasks.length} tasks');
    }
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
            // Phase indicator - NHỎ HƠN
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
                      fontSize: 16,  // ← NHỎ HƠN (20→16)
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Timer circle - NHỎ HƠN
            Container(
              height: 240,  // ← 280→240
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,  // ← 260→220
                    height: 220, // ← 260→220
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: phaseColor.withOpacity(0.3), width: 5),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: phaseColor.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,  // ← 240→200
                    height: 200, // ← 240→200
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
                      child: Text(
                        formatTime(),
                        style: TextStyle(
                          fontSize: 40,  // ← 48→40
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                          height: 0.9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Control button - BO TRÒN thay vì tròn hoàn toàn
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),  // ← Bo tròn nhẹ
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
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),  // ← Nhỏ hơn
                  shape: RoundedRectangleBorder(  // ← Bo tròn thay vì CircleBorder
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  minimumSize: const Size(160, 70),  // ← 140x140 → 160x70
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRunning ? Icons.pause_circle_filled : Icons.play_arrow,
                      size: 28,  // ← 40→28
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !isRunning && !isPaused ? "Start" : isRunning ? "Stop" : "Resume",
                      style: const TextStyle(
                        fontSize: 16,  // ← 18→16
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
                  // Header
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
                  
                  // Tasks content
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

            const SizedBox(height: 30), // ← Extra space cho scroll
          ],
        ),
      ),
    ),
  );
}
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import 'package:vibration/vibration.dart';

class PomodoroScreen extends StatefulWidget {
  final List<Task> tasks;

  PomodoroScreen({required this.tasks});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
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

  // TEST Thông báo
  // Future.delayed(Duration(seconds: 3), () {
  //   NotificationService().showNotification();
  // });
}

  /// START TIMER
  void startTimer() {

    timer?.cancel();

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (timeLeft > 0) {

        setState(() {
          timeLeft--;
        });

      } else {

        timer.cancel();

        setState(() {
          isRunning = false;
        });

        handleFinish();

      }

    });

  }

  /// STOP TIMER
  void stopTimer() {

    timer?.cancel();

    setState(() {
      isRunning = false;
      isPaused = true;
    });

  }

  /// RESUME TIMER
  void resumeTimer() {

    timer?.cancel();

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (timeLeft > 0) {

        setState(() {
          timeLeft--;
        });

      } else {

        timer.cancel();

        setState(() {
          isRunning = false;
        });

        handleFinish();

      }

    });

  }

  Future notifyFinish() async {

  if (SettingsScreen.notification) {
    await NotificationService().showNotification();
  }

  if (SettingsScreen.vibration) {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

}

  /// HANDLE FINISH
  Future handleFinish() async {

    await notifyFinish();

    /// BREAK FINISHED
    if (isBreak) {

      isBreak = false;
      isLongBreak = false;

      setState(() {
        timeLeft = SettingsScreen.pomodoro * 60;
      });

      startTimer();

      return;

    }

    /// TASK MODE
    if (widget.tasks.isNotEmpty && !freeMode) {

      Task task = widget.tasks[currentTaskIndex];

      setState(() {
        task.completedPomodoro++;
      });

      /// SAVE POMODORO
      await api.createPomodoro(SettingsScreen.pomodoro, task.id);

      /// TASK FINISHED
      if (task.completedPomodoro >= task.totalPomodoro) {

        bool? confirm = await showDialog(
          context: context,
          builder: (context) {

            return AlertDialog(
              title: const Text("Task finished?"),
              content: Text("Have you completed '${task.title}' ?"),

              actions: [

                TextButton(
                  child: const Text("Not yet"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),

                TextButton(
                  child: const Text("Done"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),

              ],

            );

          },
        );

        if (confirm == true) {

          setState(() {
            task.completed = true;
          });

          await api.completeTask(task.id);

          /// NEXT TASK
          if (currentTaskIndex < widget.tasks.length - 1) {

            setState(() {
              currentTaskIndex++;
            });

          } else {

            bool? cont = await showDialog(
              context: context,
              builder: (context) {

                return AlertDialog(

                  title: const Text("All tasks finished"),

                  content: const Text("Continue Pomodoro?"),

                  actions: [

                    TextButton(
                      child: const Text("Stop"),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),

                    TextButton(
                      child: const Text("Continue"),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),

                  ],

                );

              },
            );

            if (cont == true) {

              setState(() {
                freeMode = true;
              });

            }

          }

        } else {

          setState(() {
            task.totalPomodoro++;
          });

        }

      }

    } else {

      /// FREE MODE
      await api.createPomodoro(SettingsScreen.pomodoro, null);

    }

    pomoCount++;

    /// BREAK LOGIC
    if (pomoCount % 4 == 0) {

      isBreak = true;
      isLongBreak = true;

      setState(() {
        timeLeft = SettingsScreen.longBreak * 60;
      });

    } else {

      isBreak = true;

      setState(() {
        timeLeft = SettingsScreen.shortBreak * 60;
      });

    }

    startTimer();

  }

  /// FORMAT TIME
  String formatTime() {

    int m = timeLeft ~/ 60;
    int s = timeLeft % 60;

    return "$m:${s.toString().padLeft(2, '0')}";

  }

  /// PHASE NAME
  String getPhase() {

    if (isBreak && isLongBreak) {
      return "Long Break";
    }

    if (isBreak) {
      return "Short Break";
    }

    return "Pomodoro";

  }

  /// PHASE COLOR
  Color getColor() {

    if (isBreak && isLongBreak) {
      return Colors.red;
    }

    if (isBreak) {
      return Colors.orange;
    }

    return Colors.blue;

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

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Pomodoro"),
        centerTitle: true,
      ),

      body: Column(

        children: [

          const SizedBox(height: 30),

          /// PHASE TEXT
          Text(
            getPhase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: phaseColor,
            ),
          ),

          const SizedBox(height: 20),

          /// TIMER
          Container(

            width: 220,
            height: 220,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: phaseColor, width: 8),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),

            child: Center(

              child: Text(
                formatTime(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),

          ),

          const SizedBox(height: 20),

          /// BUTTON
          ElevatedButton(

            onPressed: () {

              if (!isRunning && !isPaused) {
                startTimer();
              }

              else if (isRunning) {
                stopTimer();
              }

              else if (isPaused) {
                resumeTimer();
              }

            },

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            child: Text(

              !isRunning && !isPaused
                  ? "Start"
                  : isRunning
                  ? "Stop"
                  : "Resume",

              style: const TextStyle(fontSize: 18),

            ),

          ),

          const SizedBox(height: 20),

          /// TASK LIST
          if (widget.tasks.isNotEmpty)

            Expanded(

              child: Container(

                margin: const EdgeInsets.all(12),

                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),

                child: ListView.builder(

                  itemCount: widget.tasks.length,

                  itemBuilder: (context, index) {

                    Task task = widget.tasks[index];

                    bool current = index == currentTaskIndex;

                    Color bg = Colors.white;

                    if (task.completed) {
                      bg = Colors.green[200]!;
                    }

                    else if (current) {
                      bg = Colors.grey[300]!;
                    }

                    return Container(

                      margin: const EdgeInsets.only(bottom: 8),

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${task.completedPomodoro}/${task.totalPomodoro} Pomodoro",
                          ),

                        ],

                      ),

                    );

                  },

                ),

              ),

            ),

        ],

      ),

    );

  }
}
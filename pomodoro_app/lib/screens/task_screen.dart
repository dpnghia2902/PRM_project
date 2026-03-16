import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/task.dart';
import 'pomodoro_screen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiService api = ApiService();

  List<Task> tasks = [];

  bool showCompleted = false;

  final titleController = TextEditingController();
  final pomoController = TextEditingController();

  /// LOAD TASKS
  loadTasks() async {
    var data = await api.getTasks();

    setState(() {
      tasks = data.map<Task>((e) => Task.fromJson(e)).toList();
    });
  }

  /// FILTER TASK
  List<Task> get filteredTasks {
    if (showCompleted) {
      return tasks.where((t) => t.completed == true).toList();
    } else {
      return tasks.where((t) => t.completed == false).toList();
    }
  }

  /// SHOW ERROR POPUP
  showError(String message) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Missing information"),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// ADD TASK
  addTask() async {
    if (titleController.text.isEmpty) {
      showError("Please enter task name");

      return;
    }

    if (pomoController.text.isEmpty) {
      showError("Please enter number of Pomodoro");

      return;
    }

    await api.createTask(titleController.text, int.parse(pomoController.text));

    titleController.clear();
    pomoController.clear();

    loadTasks();
  }

  /// DELETE TASK
  deleteTask(String id) async {
    await api.deleteTask(id);

    loadTasks();
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(title: const Text("Tasks"), centerTitle: true),

      body: Column(
        children: [
          /// ADD TASK
          Padding(
            padding: const EdgeInsets.all(16),

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  /// TASK NAME
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Task name",
                      prefixIcon: const Icon(Icons.task),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// NUMBER OF POMODORO
                  TextField(
                    controller: pomoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Number of Pomodoro",
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTask,
                      child: const Text("Add Task"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// FILTER BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showCompleted = false;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: !showCompleted ? Colors.blue : Colors.grey,
                ),

                child: const Text("Incomplete"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showCompleted = true;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: showCompleted ? Colors.blue : Colors.grey,
                ),

                child: const Text("Complete"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TASK LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              itemCount: filteredTasks.length,

              itemBuilder: (context, index) {
                Task task = filteredTasks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),

                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: Text(
                      "🍅 ${task.completedPomodoro}/${task.totalPomodoro} Pomodoro",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.completed)
                          const Icon(Icons.check_circle, color: Colors.green),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("Delete Task"),
                                  content: const Text(
                                    "Are you sure you want to delete this task?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteTask(task.id);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// START BUTTON
          Padding(
            padding: const EdgeInsets.all(20),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: const Text(
                  "Start Pomodoro",
                  style: TextStyle(fontSize: 18),
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PomodoroScreen(
                        tasks: tasks.where((t) => !t.completed).toList(),
                      ),
                    ),
                  ).then((value) {
                    loadTasks(); // reload khi quay lại
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

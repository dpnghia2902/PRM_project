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

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    var data = await api.getTasks();
    setState(() {
      tasks = data.map<Task>((e) => Task.fromJson(e)).toList();
    });
  }

  List<Task> get filteredTasks {
    if (showCompleted) {
      return tasks.where((t) => t.completed).toList();
    } else {
      return tasks.where((t) => !t.completed).toList();
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: const Text("Missing information"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> addTask() async {
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

  Future<void> deleteTask(String id) async {
    await api.deleteTask(id);
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Đảm bảo màu chữ trên button rõ ràng
    final buttonText = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Tasks",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Add Task (nhỏ gọn hơn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ConstrainedBox(  // ← giới hạn chiều rộng
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "New Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: "Task name",
                            prefixIcon: Icon(Icons.task, color: theme.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: pomoController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Pomodoro count",
                            prefixIcon:
                                Icon(Icons.timer, color: theme.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: buttonText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                            ),
                            onPressed: addTask,
                            icon: const Icon(Icons.add),
                            label: const Text("Create Task"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text("Incomplete"),
                    selected: !showCompleted,
                    selectedColor: theme.primaryColor.withOpacity(0.9),
                    backgroundColor: theme.colorScheme.surface,
                    onSelected: (value) =>
                        setState(() => showCompleted = !value),
                  ),
                  FilterChip(
                    label: const Text("Complete"),
                    selected: showCompleted,
                    selectedColor: theme.primaryColor.withOpacity(0.9),
                    backgroundColor: theme.colorScheme.surface,
                    onSelected: (value) =>
                        setState(() => showCompleted = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Task list
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.isEmpty ? 1 : filteredTasks.length,
                    itemBuilder: (context, index) {
                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.checklist, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                "No ${showCompleted ? "completed" : "active"} tasks",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      final task = filteredTasks[index];
                      final progress = task.totalPomodoro == 0
                          ? 0.0
                          : task.completedPomodoro / task.totalPomodoro;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (task.completed)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor:
                                        theme.dividerColor.withOpacity(0.2),
                                    color: theme.primaryColor,
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "🍅 ${task.completedPomodoro}/${task.totalPomodoro} Pomodoro",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete Task"),
                                          content: const Text(
                                            "Are you sure you want to delete this task?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                deleteTask(task.id);
                                              },
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Start Pomodoro button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(  // cũng giới hạn chiều rộng
                constraints: const BoxConstraints(maxWidth: 500),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PomodoroScreen(
                            tasks:
                                tasks.where((t) => !t.completed).toList(),
                          ),
                        ),
                      ).then((value) => loadTasks());
                    },
                    icon: const Icon(Icons.timer_outlined),
                    label: const Text("Start Pomodoro Session"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

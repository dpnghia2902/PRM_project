import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://192.168.1.101:5000/api";

  /// GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// AUTH HEADER
  Future<Map<String,String>> authHeader() async {
    String? token = await getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
  }

  /// REGISTER
  Future register(
      String fullName,
      String email,
      String password,
      String gender
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullName": fullName,
        "email": email,
        "password": password,
        "gender": gender
      }),
    );

    return jsonDecode(response.body);
  }

  /// LOGIN
  Future login(String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {

      final prefs = await SharedPreferences.getInstance();

      if (data["token"] != null) {
        prefs.setString("token", data["token"]);
      }
    }

    return data;
  }

  /// GET TASKS
  Future getTasks() async {

    final response = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: await authHeader(),
    );

    return jsonDecode(response.body);
  }

  /// CREATE TASK
  Future createTask(String title, int totalPomodoro) async {

    final response = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: await authHeader(),
      body: jsonEncode({
        "title": title,
        "totalPomodoro": totalPomodoro
      }),
    );

    return jsonDecode(response.body);
  }

  /// DELETE TASK
  Future deleteTask(String id) async {

    await http.delete(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: await authHeader(),
    );
  }

  /// UPDATE TASK
  Future updateTask(String id, String title, int totalPomodoro) async {

    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: await authHeader(),
      body: jsonEncode({
        "title": title,
        "totalPomodoro": totalPomodoro
      }),
    );
  }

  /// COMPLETE TASK
  Future completeTask(String id) async {

    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: await authHeader(),
      body: jsonEncode({
        "completed": true
      }),
    );
  }

  /// UPDATE TASK POMODORO PROGRESS
  Future updateTaskPomodoro(String id) async {

    final response = await http.patch(
      Uri.parse("$baseUrl/tasks/$id/pomodoro"),
      headers: await authHeader(),
    );

    return jsonDecode(response.body);
  }

  /// CREATE POMODORO
  Future createPomodoro(int duration, String? taskId) async {

    final response = await http.post(
      Uri.parse("$baseUrl/pomodoro"),
      headers: await authHeader(),
      body: jsonEncode({
        "duration": duration,
        "taskId": taskId
      }),
    );

    return jsonDecode(response.body);
  }

  /// GET ALL POMODORO
  Future getPomodoros() async {

    final response = await http.get(
      Uri.parse("$baseUrl/pomodoro"),
      headers: await authHeader(),
    );

    return jsonDecode(response.body);
  }

  /// TODAY STATS
  Future getTodayStats() async {

    final response = await http.get(
      Uri.parse("$baseUrl/pomodoro/today"),
      headers: await authHeader(),
    );

    return jsonDecode(response.body);
  }

  /// WEEK STATS
  Future getWeekStats() async {

    final response = await http.get(
      Uri.parse("$baseUrl/pomodoro/week"),
      headers: await authHeader(),
    );

    return jsonDecode(response.body);
  }

  Future getProfile() async {

  final response = await http.get(
    Uri.parse("$baseUrl/user/profile"),
    headers: await authHeader(),
  );

  return jsonDecode(response.body);

}

Future updateProfile(String fullName, String gender) async {

  final response = await http.put(
    Uri.parse("$baseUrl/user/profile"),
    headers: await authHeader(),
    body: jsonEncode({
      "fullName": fullName,
      "gender": gender
    }),
  );

  return jsonDecode(response.body);

}

}
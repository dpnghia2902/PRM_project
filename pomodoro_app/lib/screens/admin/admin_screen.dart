import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService api = ApiService();
  bool isLoading = true;
  String error = "";
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final userData = await api.getAdminUsersReport();
      final lbData = await api.getAdminLeaderboard();

      setState(() {
        users = List<Map<String, dynamic>>.from(userData);
        leaderboard = List<Map<String, dynamic>>.from(lbData);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (user['fullName'] ?? 'Unknown').toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this user?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await api.deleteAdminUser(user['_id']);
                          _loadAdminData(); // Reload data
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    } else if (value == 'change_role') {
                      final currentRole = user['role'] ?? 'user';
                      final newRole = currentRole == 'admin' ? 'user' : 'admin';
                      try {
                        await api.updateAdminUserRole(user['_id'], newRole);
                        _loadAdminData(); // Reload data
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'change_role', child: Text('Change to ${((user['role'] ?? 'user') == 'admin') ? 'User' : 'Admin'}')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete User')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              children: [
                Text('Today: ${(user['todayPomos'] ?? 0).toString()}'),
                Text('Week: ${(user['weekPomos'] ?? 0).toString()}'),
                Text('Total: ${(user['totalPomodoro'] ?? 0).toString()} pomos'),
                Text('Duration: ${(user['totalDuration'] ?? 0).toString()} min'),
                Text('Role: ${(user['role'] ?? 'user').toString()}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> item, int idx) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        child: Text('${idx + 1}'),
      ),
      title: Text((item['fullName'] ?? 'Unknown').toString()),
      subtitle: Text('Total duration: ${(item['totalDuration'] ?? 0).toString()} min'),
      trailing: Text('Pomo: ${(item['calcPomodoro'] ?? 0).toString()}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text('Error: $error'))
              : RefreshIndicator(
                  onRefresh: _loadAdminData,
                  child: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      const Text('Leaderboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...leaderboard.asMap().entries.map((e) => _buildLeaderboardItem(e.value, e.key)).toList(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('User Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...users.map(_buildUserRow).toList(),
                    ],
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService api = ApiService();
  String? userId;
  final nameController = TextEditingController();

  String gender = "male";
  File? avatar;
  String? avatarUrl;

  bool isEditing = false;

  int todayPomo = 0;
  int focusMinutes = 0;
  int weekRank = 0;
  int weekTotalDuration = 0;
  int weekTotalPomodoro = 0;
  List<Map<String, dynamic>> leaderboard = [];
  List<int> weekStats = [0, 0, 0, 0, 0, 0, 0];
  int streak = 0;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadStats();
  }

  /// LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      var data = await api.getProfile();
      setState(() {
        userId = data["_id"];
        nameController.text = data["fullName"] ?? "";
        gender = data["gender"] ?? "male";
        avatarUrl = data["avatar"];
      });
    } catch (e) {
      print("Load profile error: $e");
    }
  }

  /// LOAD STATISTICS
  Future<void> loadStats() async {
    try {
      var today = await api.getTodayStats();
      var week = await api.getWeekStats();
      var rank = await api.getWeekRank();
      var streakData = await api.getStreak();

      setState(() {
        todayPomo = today["totalPomodoro"] ?? 0;
        focusMinutes = today["focusMinutes"] ?? 0;
        weekRank = rank["weekRank"] ?? 0;
        weekTotalDuration = rank["weekTotalDuration"] ?? 0;
        weekTotalPomodoro = rank["weekTotalPomodoro"] ?? 0;
        leaderboard = List<Map<String, dynamic>>.from(rank["leaderboard"] ?? []);
        streak = streakData["streak"] ?? 0;

        List data = week["week"] ?? [0, 0, 0, 0, 0, 0, 0];
        weekStats = [
          data[1],
          data[2],
          data[3],
          data[4],
          data[5],
          data[6],
          data[0],
        ];
      });
    } catch (e) {
      print("Load stats error: $e");
    }
  }

  /// PICK AVATAR
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File file = File(picked.path);

      setState(() {
        avatar = file;
      });

      try {
        var res = await api.uploadAvatar(file, userId!);
        setState(() {
          avatarUrl = res["avatar"];
        });
      } catch (e) {
        print("Upload avatar error: $e");
      }
    }
  }

  /// FORMAT FOCUS TIME
  String focusTime() {
    int h = focusMinutes ~/ 60;
    int m = focusMinutes % 60;
    return "${h}h ${m}m";
  }

  /// PROFILE INFO (UI đẹp hơn)
  Widget buildProfileInfo() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Profile Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () async {
                  if (isEditing) {
                    await api.updateProfile(nameController.text, gender);
                  }
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                child: Text(isEditing ? "Save" : "Edit"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Full Name
        TextField(
          controller: nameController,
          enabled: isEditing,
          decoration: InputDecoration(
            labelText: "Full Name",
            hintText: "Enter your name",
            labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
            prefixIcon: Icon(Icons.person, color: colors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 16),

        // Gender
        Text(
          "Gender",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            GestureDetector(
              onTap: isEditing
                  ? () {
                      setState(() {
                        gender = "male";
                      });
                    }
                  : null,
              child: Row(
                children: [
                  Icon(
                    Icons.male,
                    color: gender == "male" ? colors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Male",
                    style: TextStyle(
                      color: gender == "male"
                          ? colors.onSurface
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: isEditing
                  ? () {
                      setState(() {
                        gender = "female";
                      });
                    }
                  : null,
              child: Row(
                children: [
                  Icon(
                    Icons.female,
                    color: gender == "female" ? Colors.pink : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Female",
                    style: TextStyle(
                      color: gender == "female"
                          ? colors.onSurface
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// TUẦN: mỗi ngày là 1 hàng ngang, hiển thị POMODORO
  Widget buildWeekList() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: List.generate(7, (index) {
        final day = days[index];
        final pomo = weekStats[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              Row(
                children: List.generate(
                  pomo > 10 ? 10 : pomo, // giới hạn 10 quả táo nếu quá nhiều
                  (appleIndex) => const Text("🍅"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface.withOpacity(0.85),
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.background.withOpacity(0.98),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          children: [
            // PROFILE CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool smallScreen = constraints.maxWidth < 360;

                    if (smallScreen) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: isEditing ? pickImage : null,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: avatar != null
                                    ? Image.file(
                                        avatar!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      )
                                    : (avatarUrl != null &&
                                              avatarUrl!.isNotEmpty
                                          ? Image.network(
                                              "http://138.252.133.79:5000$avatarUrl",
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    print(
                                                      "Image load error: $error",
                                                    );
                                                    return Icon(
                                                      Icons.error,
                                                      size: 50,
                                                    );
                                                  },
                                            )
                                          : Image.network(
                                              "https://i.pravatar.cc/150",
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            )),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Change Avatar",
                            style: TextStyle(
                              color: colors.primary.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          buildProfileInfo(),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: buildProfileInfo()),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: isEditing ? pickImage : null,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: avatar != null
                                    ? FileImage(avatar!)
                                    : const NetworkImage(
                                        "https://i.pravatar.cc/150",
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Change Avatar",
                              style: TextStyle(
                                color: colors.primary.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // STAT CARD
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Statistics",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hôm nay
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today Pomodoro",
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "🍅 $todayPomo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Weekly rank",
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          weekRank > 0
                              ? "#${weekRank} (${weekTotalPomodoro} pomodoro / ${weekTotalDuration} min)"
                              : "No rank yet",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Current Streak",
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "$streak days",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Focus Time",
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          focusTime(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    if (leaderboard.isNotEmpty) ...[
                      Text(
                        "Weekly Leaderboard",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(
                          leaderboard.length,
                          (index) {
                            final item = leaderboard[index];
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: colors.primary.withOpacity(0.2),
                                child: Text("${item['rank']}"),
                              ),
                              title: Text(item['fullName'] ?? "Unknown"),
                              trailing: Text("🍅 ${item['totalPomodoro'] ?? 0}"),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 24),
                    ],

                    // Bảng tuần theo hàng dọc (mỗi ngày 1 hàng)
                    buildWeekList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

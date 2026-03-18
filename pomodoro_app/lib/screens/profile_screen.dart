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

  /// Mon -> Sun
  List weekStats = [0, 0, 0, 0, 0, 0, 0];

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadStats();
  }

  /// LOAD PROFILE
  loadProfile() async {
    try {
      var data = await api.getProfile();

    setState(() {

      userId = data["_id"];   // thêm dòng này
      nameController.text = data["fullName"] ?? "";
      gender = data["gender"] ?? "male";
      avatarUrl = data["avatar"];

    });

      print(data);
      print(data["avatar"]);
    } catch (e) {
      print("Load profile error: $e");
    }
  }

  /// LOAD STATISTICS
  loadStats() async {
    try {
      var today = await api.getTodayStats();
      var week = await api.getWeekStats();

      setState(() {
        todayPomo = today["totalPomodoro"] ?? 0;
        focusMinutes = today["focusMinutes"] ?? 0;

        /// backend: Sun -> Sat
        List data = week["week"] ?? [0, 0, 0, 0, 0, 0, 0];

        /// convert to Mon -> Sun
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
  Future pickImage() async {
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

  /// PROFILE INFO
  Widget buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Profile Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            ElevatedButton(
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
          ],
        ),

        const SizedBox(height: 20),

        TextField(
          controller: nameController,
          enabled: isEditing,

          decoration: InputDecoration(
            labelText: "Full Name",

            prefixIcon: const Icon(Icons.person),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 20),

        const Text("Gender", style: TextStyle(fontWeight: FontWeight.w600)),

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
                    color: gender == "male" ? Colors.blue : Colors.grey,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    "Male",
                    style: TextStyle(
                      color: gender == "male" ? Colors.black : Colors.grey,
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

                  const SizedBox(width: 5),

                  Text(
                    "Female",
                    style: TextStyle(
                      color: gender == "female" ? Colors.black : Colors.grey,
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

  /// WEEK TABLE
  Widget buildWeekTable() {
    List days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        /// DAY ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 10),

        /// POMODORO ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekStats.map((p) {
            return Row(
              children: [
                Text(
                  "$p",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(width: 3),

                const Text("🍅"),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(title: const Text("Profile"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            /// PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),

              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool smallScreen = constraints.maxWidth < 360;

                  /// SMALL SCREEN
                  if (smallScreen) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: isEditing ? pickImage : null,

                          child: CircleAvatar(
                            radius: 50,

                            backgroundImage: avatar != null
                                ? FileImage(avatar!)
                                : (avatarUrl != null && avatarUrl!.isNotEmpty)
                                ? NetworkImage(
                                    "http://192.168.1.101:5000$avatarUrl",
                                  )
                                : const NetworkImage(
                                    "https://i.pravatar.cc/150",
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Change Avatar",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        buildProfileInfo(),
                      ],
                    );
                  }

                  /// NORMAL SCREEN
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
                                        )
                                        as ImageProvider,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Change Avatar",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            /// STAT CARD
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Statistics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Today Pomodoro",
                        style: TextStyle(fontSize: 16),
                      ),

                      Text(
                        "🍅 $todayPomo",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text("Focus Time"),

                      Text(
                        focusTime(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  const SizedBox(height: 10),

                  buildWeekTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

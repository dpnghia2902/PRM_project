import 'package:flutter/material.dart';
import 'task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {

  Widget buildButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0,4),
            )
          ]
        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 40,
              color: Colors.redAccent,
            ),

            const SizedBox(height:12),

            Text(
              title,
              style: const TextStyle(
                fontSize:16,
                fontWeight: FontWeight.w600
              ),
            )

          ],

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(

        title: const Text("Pomodoro"),
        centerTitle: true,

        /// AVATAR GÓC PHẢI
        actions: [

          Padding(

            padding: const EdgeInsets.only(right: 12),

            child: GestureDetector(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },

              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=3"
                ),
              ),

            ),

          ),

        ],

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: GridView.count(

          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [

            /// START
            buildButton(
              icon: Icons.timer,
              title: "Start",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskScreen(),
                  ),
                );
              },
            ),

            /// PROFILE
            buildButton(
              icon: Icons.person,
              title: "Profile",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },
            ),

            /// SETTINGS
            buildButton(
              icon: Icons.settings,
              title: "Settings",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(),
                  ),
                );
              },
            ),

          ],

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'task_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'notes_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ApiService api = ApiService();

  String? avatar;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  loadProfile() async {

    try {

      var data = await api.getProfile();

      setState(() {
        avatar = data["avatar"];
      });

    } catch(e){
      print(e);
    }

  }

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
        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(icon,size:40,color:Colors.redAccent),

            const SizedBox(height:12),

            Text(title)

          ],

        ),

      ),

    );

  }

  ImageProvider getAvatar(){

    if(avatar != null){
      return NetworkImage("http://192.168.1.101:5000$avatar");
    }

    return const NetworkImage("https://i.pravatar.cc/150");

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(

        title: const Text("Pomodoro"),
        centerTitle: true,

        actions: [

          Padding(

            padding: const EdgeInsets.only(right:12),

            child: GestureDetector(

              onTap: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );

                loadProfile(); // reload avatar

              },

              child: CircleAvatar(
                radius:18,
                backgroundImage: getAvatar(),
              ),

            ),

          )

        ],

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: GridView.count(

          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          children: [

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

            buildButton(
              icon: Icons.note,
              title: "Notes",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesScreen(),
                  ),
                );
              },
            ),

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
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {

  static int pomodoro = 25;
  static int shortBreak = 5;
  static int longBreak = 15;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final pomoController =
      TextEditingController(text: SettingsScreen.pomodoro.toString());

  final shortController =
      TextEditingController(text: SettingsScreen.shortBreak.toString());

  final longController =
      TextEditingController(text: SettingsScreen.longBreak.toString());

  save() {

    SettingsScreen.pomodoro = int.parse(pomoController.text);
    SettingsScreen.shortBreak = int.parse(shortController.text);
    SettingsScreen.longBreak = int.parse(longController.text);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    pomoController.dispose();
    shortController.dispose();
    longController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            /// SETTINGS CARD
            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0,5)
                  )
                ]
              ),

              child: Column(

                children: [

                  /// POMODORO
                  TextField(
                    controller: pomoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Pomodoro Minutes",
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:20),

                  /// SHORT BREAK
                  TextField(
                    controller: shortController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Short Break Minutes",
                      prefixIcon: const Icon(Icons.free_breakfast),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:20),

                  /// LONG BREAK
                  TextField(
                    controller: longController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Long Break Minutes",
                      prefixIcon: const Icon(Icons.hotel),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                ],

              ),

            ),

            const SizedBox(height:30),

            /// SAVE BUTTON
            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: save,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical:16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),

                child: const Text(
                  "Save Settings",
                  style: TextStyle(fontSize:16),
                ),

              ),

            ),

            const SizedBox(height:30),

            /// POMODORO NOTE
            Container(

              padding: const EdgeInsets.all(16),

              child: const Text(

                "Pomodoro Technique:\n\n"
                "• 1 Pomodoro = 25 minutes of focused work.\n"
                "• After each Pomodoro, take a short break (5 minutes).\n"
                "• After completing 4 Pomodoros, take a long break (15 minutes).\n\n"
                "This technique helps maintain focus while preventing burnout.",

                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}
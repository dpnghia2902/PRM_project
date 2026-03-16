import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final ApiService api = ApiService();

  String gender = "male";
  String? errorMessage;

  register() async {

    if(passwordController.text != confirmController.text){
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    var res = await api.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      gender
    );

    if(res["message"] == "User created"){

      Navigator.pop(context);

    }else{

      setState(() {
        errorMessage = res["message"] ?? "Register failed";
      });

    }

  }

  @override
  void dispose() {

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),

      body: Center(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(24),

            child: Container(

              padding: const EdgeInsets.all(24),

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

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize:22,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  const SizedBox(height:20),

                  /// FULL NAME
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:15),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:15),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:15),

                  /// CONFIRM PASSWORD
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),

                  const SizedBox(height:15),

                  /// GENDER
                  Row(
                    children: [

                      const Text("Gender:"),

                      const SizedBox(width:10),

                      Radio(
                        value: "male",
                        groupValue: gender,
                        onChanged: (value){
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),

                      const Text("Male"),

                      Radio(
                        value: "female",
                        groupValue: gender,
                        onChanged: (value){
                          setState(() {
                            gender = value.toString();
                          });
                        },
                      ),

                      const Text("Female"),

                    ],
                  ),

                  if(errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top:8),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),

                  const SizedBox(height:20),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(

                      onPressed: register,

                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical:14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),

                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize:16),
                      ),

                    ),
                  ),

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }

}
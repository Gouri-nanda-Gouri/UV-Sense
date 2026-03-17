import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  Future<void> changePassword() async {

    if(passwordController.text != confirmController.text){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );

      return;
    }

    await supabase.auth.updateUser(
      UserAttributes(
        password: passwordController.text,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password Updated")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(title: const Text("Change Password")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),

            const SizedBox(height:20),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: changePassword,
              child: const Text("Change Password"),
            )
          ],
        ),
      ),
    );
  }
}
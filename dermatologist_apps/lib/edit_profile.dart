import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final nameController = TextEditingController();
  final contactController = TextEditingController();

  bool loading = true;

  @override
  void initState(){
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('tbl_dermatologist')
        .select()
        .eq('dermatologist_id', user!.id)
        .single();

    nameController.text = response['dermatologist_name'];
    contactController.text = response['dermatologist_contact'];

    setState(() {
      loading = false;
    });
  }

  Future<void> updateProfile() async {

    final user = supabase.auth.currentUser;

    await supabase.from('tbl_dermatologist').update({

      'dermatologist_name': nameController.text,
      'dermatologist_contact': contactController.text,

    }).eq('dermatologist_id', user!.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){

    if(loading){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(title: const Text("Edit Profile")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height:20),

            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: "Contact"),
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Update"),
            )

          ],
        ),
      ),
    );
  }
}
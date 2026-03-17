import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'edit_profile.dart';
import 'change_password.dart';

class DermatologistMyProfile extends StatefulWidget {
  const DermatologistMyProfile({super.key});

  @override
  State<DermatologistMyProfile> createState() => _DermatologistMyProfileState();
}

class _DermatologistMyProfileState extends State<DermatologistMyProfile> {

  Map<String,dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {

    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('tbl_dermatologist')
        .select()
        .eq('dermatologist_id', user!.id)
        .single();

    setState(() {
      profile = response;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(loading){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      backgroundColor: const Color(0xFF0B0B0B),

      appBar: AppBar(
        title: const Text("My Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            CircleAvatar(
              radius: 50,
              backgroundImage:
                  NetworkImage(profile!['dermatologist_photo']),
            ),

            const SizedBox(height:20),

            Text(
              profile!['dermatologist_name'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize:22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height:5),

            Text(
              profile!['dermatologist_email'],
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height:5),

            Text(
              profile!['dermatologist_contact'],
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height:40),

            ListTile(
              leading: const Icon(Icons.edit,color: Colors.white),
              title: const Text("Edit Profile",
                  style: TextStyle(color: Colors.white)),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=> const EditProfile(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock,color: Colors.white),
              title: const Text("Change Password",
                  style: TextStyle(color: Colors.white)),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=> const ChangePassword(),
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
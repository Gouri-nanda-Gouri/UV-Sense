import 'package:dermatologist_apps/dermatologist_login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'dart:typed_data';
import 'main.dart';

class DermatologistRegistration extends StatefulWidget {
  const DermatologistRegistration({super.key});

  @override
  State<DermatologistRegistration> createState() =>
      _DermatologistRegistrationState();
}

class _DermatologistRegistrationState
    extends State<DermatologistRegistration> {

  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  final Color copper = const Color(0xFF7A4E2D);
  final Color glass = const Color(0xFF262626);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();
  final certificateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  Uint8List? imageBytes;
  file_picker.PlatformFile? pickedImage;

  Uint8List? certificateBytes;
file_picker.PlatformFile? pickedCertificate;

Future<void> handleCertificatePick() async {
  file_picker.FilePickerResult? result =
      await file_picker.FilePicker.platform.pickFiles(
    type: file_picker.FileType.image,
    withData: true,
  );

  if (result == null) return;

  pickedCertificate = result.files.first;
  certificateBytes = pickedCertificate!.bytes;

  setState(() {});
}

Future<String?> certificateUpload(String uid) async {
  try {
    if (certificateBytes == null) return null;

    const bucketName = 'Certificates';

    final filePath = "certificate/$uid.${pickedCertificate!.extension}";

    await supabase.storage.from(bucketName).uploadBinary(
          filePath,
          certificateBytes!,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return supabase.storage.from(bucketName).getPublicUrl(filePath);
  } catch (e) {
    debugPrint("Certificate upload error: $e");
    return null;
  }
}

  /// IMAGE PICKER
 Future<void> handleImagePick() async {
    file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.image,
      withData: true, // IMPORTANT
    );

    if (result == null) return;

    pickedImage = result.files.first;
    imageBytes = pickedImage!.bytes;

    debugPrint("✅ Image picked: ${imageBytes!.length} bytes");
    setState(() {});
  }

  /// PHOTO UPLOAD
  Future<String?> photoUpload(String uid) async {
    try {
      if (imageBytes == null) return null;

      const bucketName = 'dermatologist';
      final filePath = "profile/$uid.${pickedImage!.extension}";

      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            imageBytes!,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      return null;
    }
  }  Future<void> registerDermatologist() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your profile image"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (certificateBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your medical certificate"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC59A6D)),
        ),
      );

      final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String? uid = authResponse.user?.id;

      if (uid == null) {
        throw Exception("User registration failed.");
      }

      String? profileImageUrl = await photoUpload(uid);
      String? certificateUrl = await certificateUpload(uid);

      await supabase.from('tbl_dermatologist').insert({
        'dermatologist_id': uid,
        'dermatologist_name': nameController.text.trim(),
        'dermatologist_email': emailController.text.trim(),
        'dermatologist_contact': contactController.text.trim(),
        'dermatologist_certificate': certificateUrl,
        'dermatologist_photo': profileImageUrl,
        'dermatologist_password': passwordController.text.trim(),
        'dermatologist_status': 'pending',
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: gold.withOpacity(.5)),
            ),
            title: Icon(Icons.check_circle_outline, color: gold, size: 60),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Registration Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Your specialist profile is under review. You will be notified once the admin approves your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(.7)),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DermatologistLogin()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Login",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        print("Registration error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgBlack,
              const Color(0xFF141414),
              copper.withOpacity(.4),
              const Color(0xFF141414),
              bgBlack,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),

            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(35),

              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: gold.withOpacity(.5)),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(.25),
                    blurRadius: 40,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(.7),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),

              child: Form(
                key: _formKey,
                child: Column(
                  children: [
  
                    /// IMAGE PICKER
                    GestureDetector(
                      onTap: handleImagePick,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
  
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 2),
                              gradient: imageBytes == null
                                  ? LinearGradient(colors: [gold, copper])
                                  : null,
                              image: imageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(imageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageBytes == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 40,
                                  )
                                : null,
                          ),
  
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: gold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
  
                    const SizedBox(height: 25),
  
                    const Text(
                      "Dermatologist Registration",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
  
                    const SizedBox(height: 30),
  
                    /// NAME
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                          return "Enter a valid name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person, color: gold),
                        filled: true,
                        fillColor: glass,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
  
                    const SizedBox(height: 20),
  
                    /// EMAIL
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email, color: gold),
                        filled: true,
                        fillColor: glass,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
  
                    const SizedBox(height: 20),
  
                    /// CONTACT
                    TextFormField(
                      controller: contactController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter contact number";
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return "Enter 10-digit number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Contact",
                        prefixIcon: Icon(Icons.phone, color: gold),
                        filled: true,
                        fillColor: glass,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
  
                    const SizedBox(height: 20),
  
                    /// PASSWORD
                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.lock, color: gold),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword ? Icons.visibility_off : Icons.visibility,
                            color: gold,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: glass,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
  
                    const SizedBox(height: 20),
  
                    /// CERTIFICATE
                    const SizedBox(height: 20),
  
                    GestureDetector(
                      onTap: handleCertificatePick,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: glass,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: gold.withOpacity(.5)),
                        ),
                        child: certificateBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, color: gold, size: 35),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Upload Medical Certificate",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.memory(
                                  certificateBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),
  
                    /// SUBMIT
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: registerDermatologist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Already joined? Login to Portal",
                        style: TextStyle(color: gold.withOpacity(.8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
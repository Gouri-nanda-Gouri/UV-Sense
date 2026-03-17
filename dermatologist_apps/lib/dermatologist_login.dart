import 'package:dermatologist_apps/dermatologist_homepage.dart';
import 'package:dermatologist_apps/main.dart';
import 'package:dermatologist_apps/dermatologist_registration.dart';
import 'package:flutter/material.dart';

class DermatologistLogin extends StatefulWidget {
  const DermatologistLogin({super.key});

  @override
  State<DermatologistLogin> createState() => _DermatologistLoginState();
}

class _DermatologistLoginState extends State<DermatologistLogin> {

  /// COLORS (same as registration)
  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  final Color copper = const Color(0xFF7A4E2D);
  final Color glass = const Color(0xFF262626);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool hidePassword = true;
  bool _loading = false;

  void _handleLogin() async {

    if (_formKey.currentState!.validate()) {

      setState(() => _loading = true);

      try {

        final authResponse = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = authResponse.user;

        if (user == null) {
          throw Exception("Login failed");
        }

        final response = await supabase
            .from('tbl_dermatologist')
            .select('dermatologist_status')
            .eq('dermatologist_id', user.id)
            .single();

        String status = response['dermatologist_status'];

        if (status == "accepted") {

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DermatologistHome(),
              ),
            );
          }

        } else if (status == "pending") {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your account is pending admin approval"),
            ),
          );

          await supabase.auth.signOut();

        } else {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your registration was rejected"),
            ),
          );

          await supabase.auth.signOut();
        }

      } catch (e) {
        print("Login error: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );

      }

      if (mounted) {
        setState(() => _loading = false);
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

                    const Text(
                      "Dermatologist Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// EMAIL
                    TextFormField(

                      controller: _emailController,

                      style: const TextStyle(color: Colors.white),

                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    TextFormField(

                      controller: _passwordController,
                      obscureText: hidePassword,

                      style: const TextStyle(color: Colors.white),

                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Password";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.lock, color: gold),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// LOGIN BUTTON
                    SizedBox(

                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(

                        onPressed: _loading ? null : _handleLogin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "Login",
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DermatologistRegistration(),
                          ),
                        );
                      },
                      child: Text(
                        "New Specialist? Join Our Network",
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

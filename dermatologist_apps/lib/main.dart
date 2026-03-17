import 'package:dermatologist_apps/dermatologist_homepage.dart';
import 'package:dermatologist_apps/dermatologist_login.dart';
import 'package:dermatologist_apps/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dermatologist_registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://frgrgtrrvzwjpsvtdkhf.supabase.co',
    anonKey: 'sb_publishable_RVZV7px-FDTUOVYdMrOdNg_omp3Gi5_',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
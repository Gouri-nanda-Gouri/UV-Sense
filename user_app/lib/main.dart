import 'package:flutter/material.dart';
import 'package:user_app/splash_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://frgrgtrrvzwjpsvtdkhf.supabase.co',
    anonKey: 'sb_publishable_RVZV7px-FDTUOVYdMrOdNg_omp3Gi5_',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

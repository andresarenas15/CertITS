// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'iluminancia/iluminancia_app.dart';
import 'inspeccion/inspeccion_app.dart';
import 'rendicion_gastos/rendicion_gastos_app.dart'; // NUEVO MÓDULO

const Color kColorOrange = Color(0xFFE37E24); // Actualizado a tu paleta
const Color kColorGreen = Color(0xFF5D6A35);  // Actualizado a tu paleta
const Color kColorBlue = Color(0xFF293EBE);   // Actualizado a tu paleta

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {}

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HYSR App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kColorBlue),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BOTÓN 1: ILUMINANCIA
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LauncherPage())),
                icon: const Icon(Icons.lightbulb_outline, size: 32),
                label: const Text("ILUMINANCIA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            // BOTÓN 2: INSPECCIÓN SANITARIA
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InspeccionLauncherPage())),
                icon: const Icon(Icons.fact_check_outlined, size: 32),
                label: const Text("INSPECCIÓN SANITARIA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            // BOTÓN 3: VIÁTICOS Y RENDICIÓN
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RendicionGastosMainPage())),
                icon: const Icon(Icons.receipt_long, size: 32),
                label: const Text("VIÁTICOS Y RENDICIÓN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
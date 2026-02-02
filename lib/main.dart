import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble/ble_controller.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BleController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MKR1010-HCHO Configurator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          centerTitle: true,
        ),
      ),
      home: const ScanScreen(),
    );
  }
}

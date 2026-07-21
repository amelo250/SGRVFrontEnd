import 'package:flutter/material.dart';

void main() {
  runApp(const SgrvApp());
}

class SgrvApp extends StatelessWidget {
  const SgrvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Rent Car',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Sistema de Gestión Rent Car',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

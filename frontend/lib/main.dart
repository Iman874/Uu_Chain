import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const UuChainApp());
}

class UuChainApp extends StatelessWidget {
  const UuChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UuChain',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

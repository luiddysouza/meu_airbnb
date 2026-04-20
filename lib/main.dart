import 'package:flutter/material.dart';

void main() {
  runApp(const MeuAirbnbApp());
}

class MeuAirbnbApp extends StatelessWidget {
  const MeuAirbnbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'meu_airbnb',
      home: Scaffold(
        body: Center(
          child: Text('meu_airbnb — em construção'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safini Parent')),
      body: const Center(
        child: Text('Parent dashboard coming soon'),
      ),
    );
  }
}

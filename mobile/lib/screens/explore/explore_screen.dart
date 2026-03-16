import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Little Atlas')),
      body: const Center(
        child: Text('Explore - Map coming soon'),
      ),
    );
  }
}

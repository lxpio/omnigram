import 'package:flutter/material.dart';

class ImportButton extends StatelessWidget {
  final VoidCallback onTap;

  const ImportButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: onTap, child: const Icon(Icons.add));
  }
}

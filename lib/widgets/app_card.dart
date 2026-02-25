import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AppCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }
}
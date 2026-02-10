import 'package:flutter/material.dart';

class StudentMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool locked;

  const StudentMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: locked ? const Icon(Icons.lock) : null,
        onTap: locked ? null : onTap,
      ),
    );
  }
}

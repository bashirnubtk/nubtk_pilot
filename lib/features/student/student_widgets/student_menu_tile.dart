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
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: locked ? Colors.grey : Colors.indigo),
        title: Text(
          title,
          style: TextStyle(color: locked ? Colors.grey : Colors.black87, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          locked ? Icons.lock_outline : Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: locked ? null : onTap,
      ),
    );
  }
}
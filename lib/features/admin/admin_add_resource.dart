import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// আপনার প্রজেক্টের নাম অনুযায়ী সঠিক ইমপোর্ট
import '../../models/resource_model.dart';

class AdminAddResource extends StatefulWidget {
  const AdminAddResource({super.key});

  @override
  State<AdminAddResource> createState() => _AdminAddResourceState();
}

class _AdminAddResourceState extends State<AdminAddResource> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  String _selectedCategory = 'Video';

  void _saveResource() async {
    if (_titleController.text.isEmpty || _linkController.text.isEmpty) return;

    // মডেল অবজেক্ট তৈরি
    final resourceData = {
      'title': _titleController.text,
      'link': _linkController.text,
      'category': _selectedCategory,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('resources')
          .add(resourceData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource added successfully!")),
        );
        _titleController.clear();
        _linkController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Resource"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title (e.g. VS Code Download)",
              ),
            ),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(labelText: "Link (URL)"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ['Video', 'Desktop App', 'Mobile App'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveResource,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
              ),
              child: const Text("Save Resource"),
            ),
          ],
        ),
      ),
    );
  }
}

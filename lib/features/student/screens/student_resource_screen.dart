import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubtk_pilot/features/models/resource_model.dart';
import 'package:url_launcher/url_launcher.dart'; // এই প্যাকেজটি আপনার pubspec.yaml এ থাকা দরকার

class StudentResourceScreen extends StatelessWidget {
  const StudentResourceScreen({super.key});

  // লিঙ্ক ওপেন করার ফাংশন
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Necessary Resources"),
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.video_library), text: "Videos"),
              Tab(icon: Icon(Icons.desktop_windows), text: "Desktop"),
              Tab(icon: Icon(Icons.phone_android), text: "Mobile"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResourceList('Video'),
            _buildResourceList('Desktop App'),
            _buildResourceList('Mobile App'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resources')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No resources available."));
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            var resource = ResourceModel.fromMap(data, docs[index].id);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  resource.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  resource.link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.open_in_new, color: Colors.indigo),
                onTap: () => _launchURL(resource.link),
              ),
            );
          },
        );
      },
    );
  }
}

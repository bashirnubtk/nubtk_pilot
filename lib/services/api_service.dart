import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'https://your-python-api.up.railway.app';
  
  final SharedPreferences prefs;
  ApiService(this.prefs);

  Future<String> getUserRole(String uid) async {
    return prefs.getString('user_role_$uid') ?? 'student';
  }

  Future<Map<String, dynamic>> analyzeImage(XFile imageFile, String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      try {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'));
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        request.fields['user_id'] = userId;
        
        var response = await request.send();
        var respStr = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          final result = jsonDecode(respStr);
          await _clearPendingUpload(imageFile.path);
          return {'success': true, 'data': result['data'], 'source': 'server'};
        } else {
          throw Exception('Server Error: ${response.statusCode}');
        }
      } catch (e) {
        await _savePendingUpload(imageFile.path, userId);
        return {'success': false, 'error': e.toString(), 'source': 'local_queue'};
      }
    } else {
      await _savePendingUpload(imageFile.path, userId);
      return {
        'success': true, 
        'data': {'status': 'pending_sync', 'message': 'নেট আসলে অটো আপলোড হবে'},
        'source': 'offline'
      };
    }
  }

  Future<void> _savePendingUpload(String imagePath, String userId) async {
    List<String> pendingList = prefs.getStringList('pending_uploads') ?? [];
    pendingList.add(jsonEncode({
      'path': imagePath,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String()
    }));
    await prefs.setStringList('pending_uploads', pendingList);
  }

  Future<void> _clearPendingUpload(String imagePath) async {
    List<String> pendingList = prefs.getStringList('pending_uploads') ?? [];
    pendingList.removeWhere((item) {
      final data = jsonDecode(item);
      return data['path'] == imagePath;
    });
    await prefs.setStringList('pending_uploads', pendingList);
  }

  Future<void> syncPendingUploads() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) return;

    List<String> pendingList = prefs.getStringList('pending_uploads') ?? [];
    for (String item in List.from(pendingList)) {
      final data = jsonDecode(item);
      final file = File(data['path']); // XFile না, File ইউজ করো exists চেকের জন্য
      if (await file.exists()) {
        await analyzeImage(XFile(data['path']), data['user_id']);
      }
    }
  }
}
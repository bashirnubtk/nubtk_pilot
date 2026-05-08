// D:\projects\nubtk_pilot\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  // Railway বা আপনার সার্ভারের আসল URL এখানে দিন
  // এমুলেটরের জন্য 10.0.2.2, রিয়েল ফোনের জন্য আপনার পিসির IP লাগবে
  static const String _baseUrl = 'http://10.0.2.2:8000'; 
  
  final SharedPreferences _prefs;
  static const String _queueKey = 'offline_upload_queue';

  ApiService(this._prefs);

  // নেট চেক করার ফাংশন (সংশোধিত)
  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    // connectivity_plus এর নতুন ভার্সনে এটি List রিটার্ন করে
    if (connectivityResult.contains(ConnectivityResult.mobile) || 
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  // ছবি অ্যানালাইসিস - মেইন ফাংশন
  Future<Map<String, dynamic>> analyzeImage(XFile imageFile, String userId) async {
    bool online = await _isOnline();

    if (online) {
      try {
        return await _sendToServer(imageFile, userId);
      } catch (e) {
        // সার্ভারে পাঠাতে ব্যর্থ হলে অফলাইনে সেভ হবে
        await _addToOfflineQueue(imageFile.path, userId);
        return {
          'success': false,
          'source': 'offline',
          'message': 'Server unreachable, saved for later.'
        };
      }
    } else {
      await _addToOfflineQueue(imageFile.path, userId);
      return {
        'success': true,
        'source': 'offline',
        'data': {'message': 'Saved offline. Will sync when online.'}
      };
    }
  }

  // সার্ভারে পাঠানোর ফাংশন (সংশোধিত)
  Future<Map<String, dynamic>> _sendToServer(XFile imageFile, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze'), 
      );
      
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'source': 'server',
          'data': jsonResponse // এআই-এর সম্পূর্ণ রেসপন্স
        };
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}'
        };
      }
    } catch (e) {
      rethrow; // analyzeImage ফাংশন এটি হ্যান্ডেল করবে
    }
  }

  // অফলাইন কিউতে অ্যাড করা
  Future<void> _addToOfflineQueue(String imagePath, String userId) async {
    List<String> queue = _prefs.getStringList(_queueKey) ?? [];
    Map<String, String> item = {
      'imagePath': imagePath,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    queue.add(jsonEncode(item));
    await _prefs.setStringList(_queueKey, queue);
  }

  // নেট আসলে অটো সিঙ্ক (সংশোধিত)
  Future<void> syncPendingUploads() async {
    bool online = await _isOnline();
    if (!online) return;

    List<String> queue = _prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;

    List<String> remainingQueue = [];

    for (String itemStr in queue) {
      try {
        Map<String, dynamic> item = jsonDecode(itemStr);
        XFile imageFile = XFile(item['imagePath']);
        var result = await _sendToServer(imageFile, item['userId']);
        
        if (result['success'] != true) {
          remainingQueue.add(itemStr);
        }
      } catch (e) {
        remainingQueue.add(itemStr);
      }
    }

    await _prefs.setStringList(_queueKey, remainingQueue);
  }
}
//D:\projects\nubtk_pilot\lib\features\home\languages\language_provider.dart
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en'; // default language

  String get languageCode => _languageCode;

  void setLanguage(String code) {
    _languageCode = code;
    notifyListeners();
  }
}

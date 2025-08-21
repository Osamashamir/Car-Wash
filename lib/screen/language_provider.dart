import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> languages = [
    {'name': 'English', 'locale': 'en'},
    {'name': 'Arabic', 'locale': 'ar'},
    {'name': 'Spanish', 'locale': 'es'},
    {'name': 'Urdu', 'locale': 'ur'},
    {'name': 'French', 'locale': 'fr'},
  ];

  Locale selectedLocaLe = const Locale('en');

  void changeLanguage(String languageCode) {
    selectedLocaLe = Locale(languageCode);
    notifyListeners();
  }
}

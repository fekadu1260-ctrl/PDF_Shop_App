import 'package:flutter/foundation.dart';

enum AppLanguage {
  english,
  amharic,
  tigrinya,
  oromo,
}

class LanguageService {
  static final ValueNotifier<AppLanguage> current =
      ValueNotifier(AppLanguage.english);

  static void setLanguage(AppLanguage language) {
    current.value = language;
  }

  static String get languageName {
    return name(current.value);
  }

  static String name(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.amharic:
        return 'አማርኛ';
      case AppLanguage.tigrinya:
        return 'ትግርኛ';
      case AppLanguage.oromo:
        return 'Afaan Oromoo';
    }
  }
}

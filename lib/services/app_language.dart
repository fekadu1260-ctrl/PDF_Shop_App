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

  static String text(String key) {
    final language = current.value;

    final translations = <String, Map<AppLanguage, String>>{
      'appTitle': {
        AppLanguage.english: 'PDF Shop',
        AppLanguage.amharic: 'የPDF መደብር',
        AppLanguage.tigrinya: 'መደብር PDF',
        AppLanguage.oromo: 'Mana PDF',
      },
      'offlineCustomers': {
        AppLanguage.english: 'Offline Customers',
        AppLanguage.amharic: 'ኦፍላይን ደንበኞች',
        AppLanguage.tigrinya: 'ኦፍላይን ዓማዊል',
        AppLanguage.oromo: 'Maamiltoota Offline',
      },
      'waitingOrders': {
        AppLanguage.english: 'Waiting Orders',
        AppLanguage.amharic: 'የሚጠባበቁ ትዕዛዞች',
        AppLanguage.tigrinya: 'ዝጽበዩ ትእዛዛት',
        AppLanguage.oromo: 'Ajajoota Eegamaa Jiran',
      },
      'searchPdfs': {
        AppLanguage.english: 'Search PDFs...',
        AppLanguage.amharic: 'PDF ይፈልጉ...',
        AppLanguage.tigrinya: 'PDF ድለዩ...',
        AppLanguage.oromo: 'PDF barbaadi...',
      },
      'noPdfs': {
        AppLanguage.english: 'No PDFs found',
        AppLanguage.amharic: 'ምንም PDF አልተገኘም',
        AppLanguage.tigrinya: 'ምንም PDF ኣይተረኽበን',
        AppLanguage.oromo: 'PDF hin argamne',
      },
      'noMatchingPdfs': {
        AppLanguage.english: 'No matching PDFs',
        AppLanguage.amharic: 'የሚመሳሰል PDF አልተገኘም',
        AppLanguage.tigrinya: 'ዝመሳሰል PDF ኣይተረኽበን',
        AppLanguage.oromo: 'PDF walsimu hin argamne',
      },
    };

    return translations[key]?[language] ??
        translations[key]?[AppLanguage.english] ??
        key;
  }
}

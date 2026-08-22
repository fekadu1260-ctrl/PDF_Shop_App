class ApiConfig {
  // Development server running through Termux.
  static const String localBaseUrl = "http://192.168.8.8:3000";

  // Production API will go here when deployed.
  static const String productionBaseUrl = "https://pdf-shop-app-api.onrender.com";

  // Current development mode.
  static const bool production = true;

  static String get baseUrl =>
      production ? productionBaseUrl : localBaseUrl;
}

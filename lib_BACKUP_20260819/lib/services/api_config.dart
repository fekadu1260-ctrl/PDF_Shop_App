class ApiConfig {
  // Development server running through Termux.
  static const String localBaseUrl = "http://127.0.0.1:3000";

  // Production API will go here when deployed.
  static const String productionBaseUrl = "https://YOUR-PRODUCTION-API";

  // Current development mode.
  static const bool production = false;

  static String get baseUrl =>
      production ? productionBaseUrl : localBaseUrl;
}

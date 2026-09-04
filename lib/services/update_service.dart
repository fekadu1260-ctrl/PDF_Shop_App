import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'api_config.dart';

class UpdateInfo {
  final String version;
  final int buildNumber;
  final String apkUrl;
  final String message;
  final bool forceUpdate;

  const UpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.apkUrl,
    required this.message,
    required this.forceUpdate,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version']?.toString() ?? '',
      buildNumber:
          int.tryParse(json['buildNumber']?.toString() ?? '') ?? 0,
      apkUrl: json['apkUrl']?.toString() ?? '',
      message: json['message']?.toString() ??
          'A new version is available.',
      forceUpdate: json['forceUpdate'] == true,
    );
  }
}

class UpdateService {
  UpdateService._();

  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/app-version'),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        return null;
      }

      final info = UpdateInfo.fromJson(data);

      if (info.apkUrl.isEmpty) {
        return null;
      }

      final newerBuild =
          info.buildNumber > currentBuildNumber;

      final newerVersion =
          _compareVersions(info.version, currentVersion) > 0;

      if (newerBuild || newerVersion) {
        return info;
      }

      return null;
    } catch (_) {
      // Update checking must never prevent the app from starting.
      return null;
    }
  }

  static Future<bool> openUpdate(UpdateInfo info) async {
    try {
      final uri = Uri.parse(info.apkUrl);

      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(
      (e) => int.tryParse(e) ?? 0,
    ).toList();

    final bParts = b.split('.').map(
      (e) => int.tryParse(e) ?? 0,
    ).toList();

    final length =
        aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < length; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;

      if (av > bv) return 1;
      if (av < bv) return -1;
    }

    return 0;
  }
}

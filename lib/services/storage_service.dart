import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class StorageService {
  Future<String> uploadPdf(File file) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Admin is not signed in');
    }

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase ID token');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/upload-pdf'),
    );

    request.headers['Authorization'] = 'Bearer $idToken';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.body;

      final match = RegExp(r'"fileUrl"\s*:\s*"([^"]+)"').firstMatch(body);

      if (match != null) {
        return match.group(1)!;
      }

      throw Exception('Upload succeeded but server did not return fileUrl');
    }

    throw Exception(
      'PDF upload failed (${response.statusCode}): ${response.body}',
    );
  }
}

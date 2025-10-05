import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class ImageUploadAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';
  static const String _cloudinaryPrefix = 'https://res.cloudinary.com/dx2vkbh4r/image/upload/';

  static Future<String> uploadImage({
    required String token,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.imageUpload}');
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add the image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String filePath = responseData['file_path']?.toString() ?? '';
        
        if (filePath.isEmpty) {
          throw Exception('No file path returned from server');
        }
        
        return filePath;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final String errorMessage = errorData['errorMessage']?.toString() ?? 
                                   errorData['message']?.toString() ?? 
                                   'Failed to upload image';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Failed to upload image. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  static String getImageUrl(String filePath) {
    if (filePath.isEmpty) return '';
    return '$_cloudinaryPrefix$filePath';
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinarySignedUploader {
  final String cloudName =  dotenv.env['CLOUD_NAME']!;
  final String apiKey = dotenv.env['API_KEY']!;
  final String apiSecret = dotenv.env['API_SECRET']!;
  final String uploadPreset = dotenv.env['UPLOAD_PRESET']!;

  Future<String?> uploadImage(File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final paramsToSign = 'timestamp=$timestamp&upload_preset=$uploadPreset$apiSecret';
    final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['upload_preset'] = uploadPreset
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      print('Upload thất bại: ${response.statusCode}');
      final error = await response.stream.bytesToString();
      print('Lỗi chi tiết: $error');
      return null;
    }
  }
}

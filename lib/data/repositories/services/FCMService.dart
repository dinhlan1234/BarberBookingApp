import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';  // Import package JWT
import 'package:flutter/services.dart' show rootBundle;  // Để đọc assets
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final String projectId = dotenv.env['FCM_PROJECT_ID'] ?? '';
  static final String serviceAccountPath = dotenv.env['FCM_SERVICE_ACCOUNT'] ?? '';

  static Future<bool> sendFCMNotification({
    required String title,
    required String body,
    required String fcmToken,
  }) async {
    try {
      final String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('Lỗi: Không lấy được access token');
        return false;
      }

      final Map<String, dynamic> messagePayload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'custom_key': 'custom_value',
          },
          'android': {
            'notification': {
              'icon': 'ic_notification',
              'color': '#FF0000',
              'sound': 'notification',  // Âm thanh mặc định cho Android
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'badge': 1,
                'sound': 'notification',  // Âm thanh mặc định cho iOS
              },
            },
          },
        },
      };

      final Uri url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
      final Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(messagePayload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Gửi thông báo thành công: ${responseData['name']}');
        return true;
      } else {
        print('Lỗi gửi thông báo: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi exception: $e');
      return false;
    }
  }

  /// Lấy access token từ Google OAuth sử dụng JWT signed với RS256
  static Future<String?> _getAccessToken() async {
    try {
      // Đọc service account từ assets
      final String serviceAccountJsonString = await rootBundle.loadString(serviceAccountPath);
      final Map<String, dynamic> serviceAccount = jsonDecode(serviceAccountJsonString);

      final String privateKeyPem = serviceAccount['private_key'];
      final String clientEmail = serviceAccount['client_email'];
      final int now = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final int exp = now + 3600;  // Expire sau 1 giờ

      // Tạo payload cho JWT
      final Map<String, dynamic> payload = {
        'iss': clientEmail,
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': 'https://oauth2.googleapis.com/token',
        'exp': exp,
        'iat': now,
      };

      // Sửa: Tạo RSAPrivateKey và chỉ định algorithm: JWTAlgorithm.RS256
      final RSAPrivateKey rsaPrivateKey = RSAPrivateKey(privateKeyPem);
      final jwt = JWT(payload);
      final String signedJwt = jwt.sign(rsaPrivateKey, algorithm: JWTAlgorithm.RS256);  // Thêm algorithm để sử dụng RS256

      // Gửi request lấy access token
      final Uri tokenUrl = Uri.parse('https://oauth2.googleapis.com/token');
      final Map<String, String> tokenHeaders = {'Content-Type': 'application/x-www-form-urlencoded'};
      final String tokenBody = 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$signedJwt';

      final http.Response tokenResponse = await http.post(tokenUrl, headers: tokenHeaders, body: tokenBody);
      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        print('Access token lấy thành công');
        return tokenData['access_token'];
      } else {
        print('Lỗi lấy access token: ${tokenResponse.statusCode} - ${tokenResponse.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi _getAccessToken: $e');
      return null;
    }
  }
}
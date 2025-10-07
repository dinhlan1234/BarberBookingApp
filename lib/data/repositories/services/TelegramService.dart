import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TelegramServices {
  final String token = dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';
  final String id = dotenv.env['TELEGRAM_CHAT_ID'] ?? '';

  Future<void> sendMessage(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final String url = 'https://api.telegram.org/bot$token/sendMessage?chat_id=$id&text=$encodedMessage';
    try{
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        print('✅ Đã gửi tin nhắn thành công!');
      }else{
        print('❌ Gửi tin nhắn thất bại: ${response.body}');
      }
    }catch (e) {
      print('❗Lỗi khi gửi tin nhắn: $e');
    }

  }
}

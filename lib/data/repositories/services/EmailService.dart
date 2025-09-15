import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService{
  Future<String> sendOtp(String recipientEmail) async{
    String otpCode = (Random().nextInt(9000) + 1000).toString();
    String username = 'dinhlan74qt@gmail.com';
    String password = 'fsib efsq jvhb gklw';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username,'Bom')
      ..recipients.add(recipientEmail)
      ..subject = 'Mã OTP xác thực của bạn'
      ..text = 'Mã xác thực của bạn là: $otpCode';
    try{
      final sendReport = await send(message, smtpServer);
      print('Gửi email thành công');
      return otpCode;
    } on MailerException catch(e){
      print('Có lỗi trong lúc gửi email - $e');
      return '';
    }
  }
}
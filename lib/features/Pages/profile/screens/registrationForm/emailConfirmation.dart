import 'package:flutter/material.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/data/repositories/services/EmailService.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/otpEmail.dart';

class EmailConfirmation extends StatefulWidget {
  final Map<String, dynamic> tempData;

  const EmailConfirmation({super.key, required this.tempData});

  @override
  State<EmailConfirmation> createState() => _EmailConfirmationState();
}

class _EmailConfirmationState extends State<EmailConfirmation> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực Email'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Xác thực Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Để xác thực email, chúng tôi sẽ gửi mã về email "${widget.tempData['email']}" của bạn để xác thực. Vui lòng nhấn nút gửi để chúng tôi gửi mã đến email của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      final emailService = EmailService();
                      final String otp = await emailService.sendOtp(widget.tempData['email'],);
                      if(otp.isNotEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mã OTP đã được gửi thành công!')),
                        );

                        Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
                        => OtpEmail(
                          otp: otp,
                          tempData: {
                            ...widget.tempData
                          },
                        ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child,) {
                            const begin = Offset(1.0, 0.0,);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end);
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.ease,
                            );
                            return SlideTransition(position: tween.animate(curvedAnimation), child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 1000,),
                        ),
                        );
                      }else{
                        displayMessageToUser(context, 'Có lỗi trong lúc gửi mã, vui lòng liên hệ 0832235031 để được hỗ trợ',isSuccess: false,onOk: (){Navigator.pop(context);});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Gửi mã',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

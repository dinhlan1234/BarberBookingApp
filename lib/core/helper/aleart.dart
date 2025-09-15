import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void displayMessageToUser(BuildContext context, String message, {bool isSuccess = true, VoidCallback? onOk}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(isSuccess ? "Hoàn thành 😘" : "Có lỗi mất tiêu rồi 😱",style: TextStyle(fontSize: 16.sp),),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onOk != null) {
              onOk();
            }
          },
          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
    ),
  );
}

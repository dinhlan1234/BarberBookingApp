import 'package:flutter/services.dart';

class TwoDigitInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text;
    print('Old value: $oldValue, New value: $newValue, New text: $newText'); // Debug

    // Nếu chuỗi rỗng, trả về giá trị rỗng
    if (newText.isEmpty) return newValue;

    // Chuyển đổi sang số để kiểm tra hợp lệ
    final number = int.tryParse(newText);
    if (number == null) {
      return oldValue; // Nếu không phải số, giữ nguyên giá trị cũ
    }

    // Nếu nhập 1 ký tự, thêm '0' đằng trước và di chuyển con trỏ
    if (newText.length == 1) {
      final paddedText = newText.padLeft(2, '0');
      print('Padded text: $paddedText');
      return TextEditingValue(
        text: paddedText,
        selection: TextSelection.collapsed(offset: paddedText.length),
      );
    }

    // Giới hạn 2 ký tự và đảm bảo không vượt quá 23 (cho giờ)
    if (newText.length > 2 || number > 23) {
      print('Exceeding limit, returning old value: $oldValue');
      return oldValue;
    }

    // Nếu nhập 2 ký tự hợp lệ, giữ nguyên
    if (newText.length == 2) {
      return newValue;
    }

    return newValue;
  }
}
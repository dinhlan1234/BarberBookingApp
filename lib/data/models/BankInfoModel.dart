class BankInfoModel {
  final String bankName;
  final String accountNumber;
  final String ownerName;

  BankInfoModel({
    required this.bankName,
    required this.accountNumber,
    required this.ownerName,
  });

  // Từ JSON → Object
  factory BankInfoModel.fromJson(Map<String, dynamic> json) {
    return BankInfoModel(
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ownerName: json['ownerName'] ?? '',
    );
  }

  // Từ Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ownerName': ownerName,
    };
  }
}

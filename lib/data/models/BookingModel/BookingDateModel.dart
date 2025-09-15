class BookingDateModel {
  final String time;
  final String weekdayName;
  final String date;

  const BookingDateModel({
    required this.time,
    required this.weekdayName,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'weekdayName': weekdayName,
      'date': date,
    };
  }

  factory BookingDateModel.fromJson(Map<String, dynamic> json) {
    return BookingDateModel(
      time: json['time'] ?? '',
      weekdayName: json['weekdayName'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

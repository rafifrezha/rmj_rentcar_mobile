class Rental {
  final int rentalId;
  final int userId;
  final int carId;
  final DateTime rentalStartDate;
  final DateTime rentalEndDate;
  final int totalPrice;
  final String status;

  Rental({
    required this.rentalId,
    required this.userId,
    required this.carId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.totalPrice,
    required this.status,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      rentalId: json['rental_id'],
      userId: json['user_id'],
      carId: json['car_id'],
      rentalStartDate: DateTime.parse(json['rental_start_date']),
      rentalEndDate: DateTime.parse(json['rental_end_date']),
      totalPrice: json['total_price'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_id': rentalId,
      'user_id': userId,
      'car_id': carId,
      'rental_start_date': rentalStartDate.toIso8601String(),
      'rental_end_date': rentalEndDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
    };
  }
}

class Car {
  final int carId;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final bool availability;
  final int pricePerDay;
  final String urlPhoto;

  Car({
    required this.carId,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.availability,
    required this.pricePerDay,
    required this.urlPhoto,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: json['car_id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      availability: json['availability'] == 1 || json['availability'] == true,
      pricePerDay: json['price_per_day'],
      urlPhoto: json['url_photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'availability': availability ? 1 : 0,
      'price_per_day': pricePerDay,
      'url_photo': urlPhoto,
    };
  }

  // Helper for UI compatibility
  String get name => '$brand $model';
  String get imageUrl => urlPhoto;
  int get id => carId;
}

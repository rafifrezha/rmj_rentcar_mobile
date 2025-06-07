import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int pricePerDay;
  final String? licensePlate;
  final int? year;
  final VoidCallback onTap;
  final String currency; // Tambahkan parameter currency

  const CarCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.pricePerDay,
    this.licensePlate,
    this.year,
    required this.onTap,
    this.currency = 'IDR', // default IDR
  });

  String formatCurrency(int amount) {
    switch (currency) {
      case 'USD':
        return '\$${(amount / 15500).toStringAsFixed(2)}';
      case 'SGD':
        return 'S\$${(amount / 11500).toStringAsFixed(2)}';
      case 'EUR':
        return '€${(amount / 17000).toStringAsFixed(2)}';
      default:
        final String amountStr = amount.toString();
        String result = '';
        int counter = 0;
        for (int i = amountStr.length - 1; i >= 0; i--) {
          if (counter > 0 && counter % 3 == 0) {
            result = '.$result';
          }
          result = amountStr[i] + result;
          counter++;
        }
        return 'Rp$result';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232B3E),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with price badge (small, top right)
              Stack(
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: imageUrl.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.car_rental,
                              size: 48,
                              color: Colors.grey,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 110,
                                  color: Colors.transparent,
                                  child: const Icon(
                                    Icons.car_rental,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E09E),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.attach_money,
                            color: Color(0xFF232B3E),
                            size: 10,
                          ),
                          Text(
                            formatCurrency(pricePerDay),
                            style: const TextStyle(
                              color: Color(0xFF232B3E),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const Text(
                            '/hari',
                            style: TextStyle(
                              color: Color(0xFF232B3E),
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E09E),
                        letterSpacing: 0.2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 2),
                    // Tahun
                    if (year != null)
                      Row(
                        children: [
                          const Text(
                            'Tahun: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '$year',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    // Plat
                    if (licensePlate != null)
                      Row(
                        children: [
                          const Text(
                            'Plat: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              licensePlate!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

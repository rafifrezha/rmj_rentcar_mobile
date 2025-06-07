import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../models/rental.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../services/shared_prefs_service.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});
  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isDateRangeAvailable = true;
  List<DateTimeRange> _bookedRanges = [];

  String _currency = 'IDR';

  String formatCurrency(int amount) {
    switch (_currency) {
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
        return 'Rp $result';
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final car = ModalRoute.of(context)!.settings.arguments as Car;
    final totalDays = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;
    final totalPrice = totalDays * car.pricePerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Mobil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan currency
            Row(
              children: [
                const Text(
                  'Currency: ',
                  style: TextStyle(
                    color: Color(0xFF00E09E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _currency,
                  dropdownColor: const Color(0xFF232B3E),
                  style: const TextStyle(
                    color: Color(0xFF00E09E),
                    fontWeight: FontWeight.bold,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'SGD', child: Text('SGD (S\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _currency = val ?? 'IDR';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Card Mobil
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: const Color(0xFF232B3E),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        car.imageUrl,
                        height: 160, // diperbesar dari 110
                        width: 160, // diperbesar dari 110
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => Container(
                          width: 160,
                          height: 160,
                          color: Colors.grey[300],
                          child: const Icon(Icons.car_rental, size: 64),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E09E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tahun: ${car.year}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.confirmation_number,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Plat: ${car.licensePlate}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E09E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${formatCurrency(car.pricePerDay)} / hari',
                              style: const TextStyle(
                                color: Color(0xFF232B3E),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Pilih Tanggal Rental',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00E09E),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectStartDate(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF00E09E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      _startDate != null
                          ? 'Mulai: ${formatDate(_startDate!)}'
                          : 'Pilih Tanggal Mulai',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectEndDate(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF00E09E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label: Text(
                      _endDate != null
                          ? 'Selesai: ${formatDate(_endDate!)}'
                          : 'Pilih Tanggal Selesai',
                    ),
                  ),
                ),
              ],
            ),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 28),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: const Color(0xFF232B3E),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Durasi: $totalDays hari',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Harga per hari: ${formatCurrency(car.pricePerDay)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white24),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments,
                            color: Color(0xFF00E09E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total: ${formatCurrency(totalPrice)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E09E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!_isDateRangeAvailable)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Tanggal yang dipilih sudah dibooking, silakan pilih tanggal lain.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF00E09E),
                      ),
                label: const Text(
                  'Sewa Mobil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E09E),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF232B3E),
                  foregroundColor: const Color(0xFF00E09E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 6,
                ),
                onPressed:
                    _startDate != null &&
                        _endDate != null &&
                        !_isLoading &&
                        _isDateRangeAvailable
                    ? () => _submitRental(car, totalPrice)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final car = ModalRoute.of(context)!.settings.arguments as Car;
    _fetchBookedRanges(car.carId);
  }

  Future<void> _fetchBookedRanges(int carId) async {
    // Ambil rental yang sudah ada untuk mobil ini
    final allRentals = await ApiService.getRentalsForCar(carId);
    setState(() {
      _bookedRanges = allRentals
          .where((r) => r.status == 'reserved' || r.status == 'ongoing')
          .map(
            (r) =>
                DateTimeRange(start: r.rentalStartDate, end: r.rentalEndDate),
          )
          .toList();
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
        _checkDateRange();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
        _checkDateRange();
      });
    }
  }

  void _checkDateRange() {
    if (_startDate == null || _endDate == null) {
      _isDateRangeAvailable = true;
      return;
    }
    final selectedRange = DateTimeRange(start: _startDate!, end: _endDate!);
    _isDateRangeAvailable = !_bookedRanges.any(
      (booked) =>
          selectedRange.start.isBefore(
            booked.end.add(const Duration(days: 1)),
          ) &&
          selectedRange.end.isAfter(
            booked.start.subtract(const Duration(days: 1)),
          ),
    );
  }

  Future<void> _submitRental(Car car, int totalPrice) async {
    setState(() => _isLoading = true);

    final user = await SharedPrefsService.getUser();
    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rental = Rental(
      rentalId: 0,
      userId: user.userId,
      carId: car.carId,
      rentalStartDate: _startDate!,
      rentalEndDate: _endDate!,
      totalPrice: totalPrice,
      status: 'reserved',
    );

    try {
      final success = await ApiService.createRental(rental);
      setState(() => _isLoading = false);

      if (success) {
        // Tampilkan popup sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: const Color(0xFF232B3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00E09E).withOpacity(0.15),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00E09E),
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Berhasil!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E09E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pemesanan sewa mobil Anda berhasil.\nSilakan cek riwayat untuk detail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE0E6ED), fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E09E),
                        foregroundColor: const Color(0xFF232B3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx); // tutup dialog
                        Navigator.pop(context); // kembali ke screen sebelumnya
                      },
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat rental'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

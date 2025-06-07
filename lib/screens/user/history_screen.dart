import 'package:flutter/material.dart';
import '../../models/rental.dart';
import '../../models/car.dart';
import '../../services/api_service.dart';
import '../../services/shared_prefs_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Rental> rentals = [];
  Map<int, Car> carMap = {};
  bool _isLoading = true;
  int _selectedIndex = 1;

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

  String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '-';
    if (end.isBefore(start)) return '-';
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  void _onNavTapped(int idx) {
    if (idx == _selectedIndex) return;
    setState(() => _selectedIndex = idx);
    if (idx == 0) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (idx == 1) {
      // Already here
    } else if (idx == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Sewa')),
      body: Column(
        children: [
          // Pilihan currency
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : rentals.isEmpty
                ? const Center(child: Text('Belum ada riwayat sewa'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rentals.length,
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      final car = carMap[rental.carId];
                      final totalDays =
                          rental.rentalEndDate
                              .difference(rental.rentalStartDate)
                              .inDays +
                          1;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tambahkan gambar mobil besar di atas nama mobil
                              if (car != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      car.imageUrl,
                                      width: double.infinity,
                                      height: 140,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Container(
                                        width: double.infinity,
                                        height: 140,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.car_rental,
                                          size: 64,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  if (car != null)
                                    const SizedBox(width: 0)
                                  else
                                    Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.car_rental,
                                        size: 32,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      car != null
                                          ? car.name
                                          : 'Car ID: ${rental.carId}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(rental.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      rental.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatDateRange(
                                      rental.rentalStartDate,
                                      rental.rentalEndDate,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Durasi: $totalDays hari',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Total: ${formatCurrency(rental.totalPrice)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00E09E),
                                    ),
                                  ),
                                ],
                              ),
                              // Tombol Batalkan Sewa jika status reserved
                              if (rental.status.toLowerCase() == 'reserved')
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Batalkan Sewa',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(0, 32),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 0,
                                        ),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Konfirmasi'),
                                            content: const Text(
                                              'Yakin ingin membatalkan sewa ini? Data akan dihapus dari sistem.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Tidak'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Ya'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await _deleteRental(rental.rentalId);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF232B3E),
        selectedItemColor: const Color(0xFF00E09E),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Future<void> _loadRentals() async {
    try {
      final user = await SharedPrefsService.getUser();
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final userId = user.userId;
      // Ambil hanya rental milik user yang sedang login
      List<Rental> apiRentals = await ApiService.getRentals(userId);

      // Ambil semua mobil dan buat map carId -> Car
      final cars = await ApiService.getCars();
      final carMapLocal = <int, Car>{};
      for (final car in cars) {
        carMapLocal[car.carId] = car;
      }

      // Filter rentals agar hanya milik userId (jika backend belum filter)
      final filteredRentals = apiRentals
          .where((r) => r.userId == userId)
          .toList();

      setState(() {
        rentals = filteredRentals;
        carMap = carMapLocal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading rentals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'ongoing':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteRental(int rentalId) async {
    try {
      final response = await ApiService.deleteRental(rentalId);
      if (response) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: const Color(0xFF232B3E),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF00E09E), size: 32),
                SizedBox(width: 10),
                Text(
                  'Berhasil',
                  style: TextStyle(
                    color: Color(0xFF00E09E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Sewa berhasil dibatalkan dan dihapus.',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00E09E),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _loadRentals();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membatalkan sewa'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

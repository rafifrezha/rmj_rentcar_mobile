import 'package:flutter/material.dart';
import '../../models/rental.dart';
import '../../services/api_service.dart';
import '../../services/shared_prefs_service.dart';
import '../../widgets/rental_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Rental> rentals = [];
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Sewa')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : rentals.isEmpty
          ? const Center(child: Text('Belum ada riwayat sewa'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return RentalCard(
                  carName: 'Car ID: ${rental.carId}',
                  dateRange: formatDateRange(
                    rental.rentalStartDate,
                    rental.rentalEndDate,
                  ),
                  totalPrice: rental.totalPrice,
                  status: rental.status,
                );
              },
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
      // Gunakan user.userId jika model User sudah disesuaikan, jika tidak user.id
      final userId = (user.userId);
      List<Rental> apiRentals = await ApiService.getRentals(userId);
      setState(() {
        rentals = apiRentals;
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
}

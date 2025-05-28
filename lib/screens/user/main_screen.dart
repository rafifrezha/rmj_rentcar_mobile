import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../services/api_service.dart';
import '../../services/shared_prefs_service.dart';
import '../../widgets/car_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Car> cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mobil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
          ? const Center(child: Text('Tidak ada mobil tersedia'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return CarCard(
                  name: car.name,
                  imageUrl: car.imageUrl,
                  pricePerDay: car.pricePerDay,
                  onTap: () => _rentCar(car),
                );
              },
            ),
    );
  }

  Future<void> _loadCars() async {
    try {
      final apiCars = await ApiService.getCars();
      setState(() {
        cars = apiCars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar('Error loading cars: $e', isError: true);
    }
  }

  void _rentCar(Car car) {
    Navigator.pushNamed(context, '/rental', arguments: car);
  }

  Future<void> _logout() async {
    await SharedPrefsService.clearUserData();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

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
  String search = '';
  int _selectedIndex = 0;

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

  List<Car> get filteredCars {
    if (search.isEmpty) return cars;
    final lower = search.toLowerCase();
    return cars
        .where(
          (car) =>
              car.brand.toLowerCase().contains(lower) ||
              car.model.toLowerCase().contains(lower) ||
              car.year.toString().contains(lower),
        )
        .toList();
  }

  void _onNavTapped(int idx) {
    if (idx == _selectedIndex) return;
    setState(() => _selectedIndex = idx);
    if (idx == 0) {
      // Main screen, do nothing (already here)
    } else if (idx == 1) {
      Navigator.pushReplacementNamed(context, '/history');
    } else if (idx == 2) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2236),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Image.asset(
                      'assets/logo-rmj.png',
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const SizedBox(width: 60, height: 60),
                    ),
                  ),
                  const Text(
                    'Rumah Mobil Jogja',
                    style: TextStyle(
                      color: Color(0xFF00E09E),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 1,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
          ? const Center(child: Text('Tidak ada mobil tersedia'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 0),
              children: [
                // Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/Banner.png',
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 48)),
                      ),
                    ),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF232B3E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Color(0xFF00E09E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '  Cari Mobil',
                              hintStyle: TextStyle(color: Color(0xFFE0E6ED)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onChanged: (val) => setState(() => search = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                // Mobil per brand
                ..._buildBrandSections(filteredCars),
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

  List<Widget> _buildBrandSections(List<Car> carList) {
    final brands = carList.map((c) => c.brand).toSet().toList()..sort();
    return brands.map((brand) {
      final carsOfBrand = carList.where((c) => c.brand == brand).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand,
              style: const TextStyle(
                color: Color.fromARGB(255, 246, 246, 246),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemCount: carsOfBrand.length,
              itemBuilder: (context, index) {
                final car = carsOfBrand[index];
                return CarCard(
                  name: car.name,
                  imageUrl: car.imageUrl,
                  pricePerDay: car.pricePerDay,
                  licensePlate: car.licensePlate,
                  year: car.year,
                  onTap: () => _rentCar(car),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }).toList();
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

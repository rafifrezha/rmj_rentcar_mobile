import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../services/local_db_service.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  List<Car> cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  String formatCurrency(int amount) {
    final String amountStr = amount.toString();
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        result = '.' + result;
      }
      result = amountStr[i] + result;
      counter++;
    }
    return 'Rp $result';
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
        title: const Text('Kelola Mobil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCarDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
          ? const Center(child: Text('Belum ada mobil'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      car.urlPhoto,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text('${car.brand} ${car.model}'),
                    subtitle: Text(formatCurrency(car.pricePerDay)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCarDialog(car: car),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCar(car),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _loadCars() async {
    try {
      final loadedCars = await LocalDbService.getCars();
      setState(() {
        cars = loadedCars.map((e) => Car.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar('Error loading cars: $e', isError: true);
    }
  }

  void _showCarDialog({Car? car}) {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearController = TextEditingController(
      text: car?.year.toString() ?? '',
    );
    final licensePlateController = TextEditingController(
      text: car?.licensePlate ?? '',
    );
    final priceController = TextEditingController(
      text: car?.pricePerDay.toString() ?? '',
    );
    final urlPhotoController = TextEditingController(text: car?.urlPhoto ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(car == null ? 'Tambah Mobil' : 'Edit Mobil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'Plat Nomor'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga per Hari'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: urlPhotoController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => _saveCar(
              car,
              brandController,
              modelController,
              yearController,
              licensePlateController,
              priceController,
              urlPhotoController,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCar(
    Car? existingCar,
    TextEditingController brandController,
    TextEditingController modelController,
    TextEditingController yearController,
    TextEditingController licensePlateController,
    TextEditingController priceController,
    TextEditingController urlPhotoController,
  ) async {
    if (brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        yearController.text.isEmpty ||
        licensePlateController.text.isEmpty ||
        priceController.text.isEmpty ||
        urlPhotoController.text.isEmpty) {
      showSnackBar('Semua field harus diisi', isError: true);
      return;
    }

    final car = Car(
      carId: existingCar?.carId ?? 0,
      brand: brandController.text,
      model: modelController.text,
      year: int.tryParse(yearController.text) ?? 0,
      licensePlate: licensePlateController.text,
      availability: true,
      pricePerDay: int.tryParse(priceController.text) ?? 0,
      urlPhoto: urlPhotoController.text,
    );

    try {
      if (existingCar == null) {
        await LocalDbService.insertCar(car.toJson());
      } else {
        await LocalDbService.updateCar(car.toJson());
      }

      Navigator.pop(context);
      _loadCars();
      showSnackBar('Mobil berhasil disimpan');
    } catch (e) {
      showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mobil'),
        content: Text('Yakin ingin menghapus ${car.brand} ${car.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await LocalDbService.deleteCar(car.carId);
        _loadCars();
        showSnackBar('Mobil berhasil dihapus');
      } catch (e) {
        showSnackBar('Error: $e', isError: true);
      }
    }
  }
}

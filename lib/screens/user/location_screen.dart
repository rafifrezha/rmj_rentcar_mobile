import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const LatLng destination = LatLng(-7.79725, 110.400861);
  static const String mapsAddress =
      'Jl. Babadan Jl. Gedongkuning No.607, Jomblangan, Banguntapan, Kec. Banguntapan, Kabupaten Bantul, Daerah Istimewa Yogyakarta 55198';

  static const Color themeGreen = Color(0xFF00E09E);

  LatLng? _userLocation;
  bool _loading = true;
  String? _error;

  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = "Location services are disabled.";
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = "Location permissions are denied";
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              "Location permissions are permanently denied. Silakan aktifkan di pengaturan HP.";
          _loading = false;
        });
        return;
      }
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _userLocation = userLatLng;
        });
        await _fetchTomTomRoute(userLatLng, destination);
        setState(() {
          _loading = false;
        });
      } on Exception catch (e) {
        setState(() {
          _error = "Gagal mendapatkan lokasi: $e";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Terjadi error: $e";
        _loading = false;
      });
    }
  }

  Future<void> _fetchTomTomRoute(LatLng start, LatLng end) async {
    const apiKey = 'CAutCdXlTIj2fP9oIuaDbn0X3tCHa4lG';
    final url =
        'https://api.tomtom.com/routing/1/calculateRoute/${start.latitude},${start.longitude}:${end.latitude},${end.longitude}/json?key=$apiKey&travelMode=car';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> routePoints = [];
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final points = legs[0]['points'] as List?;
            if (points != null && points.isNotEmpty) {
              for (final p in points) {
                routePoints.add(
                  LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ),
                );
              }
            }
          }
        }
        setState(() {
          _routePoints = routePoints;
        });
      } else {
        setState(() {
          _routePoints = [];
        });
      }
    } catch (e) {
      setState(() {
        _routePoints = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2F),
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _userLocation ?? destination,
                  zoom: 15.5,
                  interactiveFlags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=CAutCdXlTIj2fP9oIuaDbn0X3tCHa4lG',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: themeGreen,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_userLocation != null)
                        Marker(
                          width: 44,
                          height: 44,
                          point: _userLocation!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.circle,
                              color: themeGreen,
                              size: 22,
                            ),
                          ),
                        ),
                      Marker(
                        width: 54,
                        height: 54,
                        point: destination,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeGreen.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: themeGreen,
                            size: 38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back,
                          color: themeGreen,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (_userLocation != null) {
                          _mapController.move(_userLocation!, 16);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.my_location,
                          color: themeGreen,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Title
          Positioned(
            top: 38,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Rumah Mobil Jogja",
                style: TextStyle(
                  color: themeGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Info Card
          if (!_loading && _error == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 18, left: 10, right: 10),
                child: _infoCard(context),
              ),
            ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Card(
      color: const Color(0xFF232B3E),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/logo-rmj.png",
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Rumah Mobil Jogja",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF00E09E),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Rental Mobil Jogja",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF00E09E),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Jl. Babadan Jl. Gedongkuning No.607, Jomblangan, Banguntapan, Kec. Banguntapan, Kabupaten Bantul, Daerah Istimewa Yogyakarta 55198",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.route_rounded, color: Color(0xFF232B3E)),
                label: const Text(
                  "Directions",
                  style: TextStyle(
                    color: Color(0xFF232B3E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeGreen,
                  foregroundColor: const Color(0xFF232B3E),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  _mapController.move(destination, 16);
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

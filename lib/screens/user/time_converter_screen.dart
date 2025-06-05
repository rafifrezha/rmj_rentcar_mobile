import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/shared_prefs_service.dart';

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});
  @override
  State<TimeConverterScreen> createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  DateTime now = DateTime.now();
  String username = 'User';

  @override
  void initState() {
    super.initState();
    // Update time every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        now = DateTime.now();
      });
      return true;
    });
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = await SharedPrefsService.getUser();
    if (user != null && mounted) {
      setState(() {
        username = user.username;
      });
    }
  }

  String _formatTime(DateTime now, Duration offset) {
    final dt = now.toUtc().add(offset);
    return DateFormat('HH:mm:ss').format(dt);
  }

  String _format24Time(DateTime now, Duration offset) {
    final dt = now.toUtc().add(offset);
    return DateFormat('HH:mm:ss').format(dt);
  }

  Widget _buildTimeCard({
    required String city,
    required String country,
    required String tz,
    required String offsetText,
    required Duration offset,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(now, offset),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E6ED),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$city, $country',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00E09E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$tz ($offsetText)',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data waktu
    final List<Map<String, dynamic>> timeZones = [
      {
        'city': 'Jakarta',
        'country': 'Indonesia',
        'tz': 'WIB',
        'offsetText': 'UTC+7',
        'offset': const Duration(hours: 7),
        'color': const Color(0xFF232B3E),
      },
      {
        'city': 'Makassar',
        'country': 'Indonesia',
        'tz': 'WITA',
        'offsetText': 'UTC+8',
        'offset': const Duration(hours: 8),
        'color': const Color(0xFF232B3E),
      },
      {
        'city': 'Jayapura',
        'country': 'Indonesia',
        'tz': 'WIT',
        'offsetText': 'UTC+9',
        'offset': const Duration(hours: 9),
        'color': const Color(0xFF232B3E),
      },
      {
        'city': 'London',
        'country': 'UK',
        'tz': 'GMT',
        'offsetText': 'UTC+0',
        'offset': const Duration(hours: 0),
        'color': const Color(0xFF232B3E),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF181F2F),
      appBar: AppBar(
        title: const Text('Konversi Waktu'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A2236),
        elevation: 0,
        foregroundColor: const Color(0xFFE0E6ED),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 18, left: 2, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $username 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E09E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your actual timezone:',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Color(0xFF00E09E),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _format24Time(
                        now,
                        Duration(hours: DateTime.now().timeZoneOffset.inHours),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFE0E6ED),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateTime.now().timeZoneName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Card waktu per zona
          ...timeZones.map(
            (tz) => _buildTimeCard(
              city: tz['city'],
              country: tz['country'],
              tz: tz['tz'],
              offsetText: tz['offsetText'],
              offset: tz['offset'],
              color: tz['color'],
            ),
          ),
        ],
      ),
    );
  }
}

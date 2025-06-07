import 'package:flutter/material.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  int totalOrders = 0;
  int totalSpent = 0;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserAndStats();
  }

  Future<void> _loadUserAndStats() async {
    final u = await SharedPrefsService.getUser();
    if (u != null) {
      final rentals = await ApiService.getRentals(u.userId);
      setState(() {
        user = u;
        totalOrders = rentals.where((r) => r.userId == u.userId).length;
        totalSpent = rentals
            .where((r) => r.userId == u.userId)
            .fold(0, (sum, r) => sum + r.totalPrice);
      });
    } else {
      setState(() {
        user = null;
        totalOrders = 0;
        totalSpent = 0;
      });
    }
  }

  void _onNavTapped(int idx) {
    if (idx == _selectedIndex) return;
    setState(() => _selectedIndex = idx);
    if (idx == 0) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (idx == 1) {
      Navigator.pushReplacementNamed(context, '/history');
    } else if (idx == 2) {
      // Already here
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil User'),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF00E09E),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    user!.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF00E09E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user!.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  // Stats Card
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E09E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF232B3E),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Balance',
                                style: TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp 0',
                                style: const TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E09E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF232B3E),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Orders',
                                style: TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$totalOrders',
                                style: const TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E09E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Color(0xFF232B3E),
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Total Spent',
                                style: TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp ${totalSpent.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                style: const TextStyle(
                                  color: Color(0xFF232B3E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Menu List
                  Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.receipt_long,
                            color: Color(0xFF00E09E),
                          ),
                          title: const Text(
                            'Order History',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => Navigator.pushNamed(context, '/history'),
                        ),
                        const Divider(height: 1, color: Colors.white12),
                        ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFF00E09E),
                          ),
                          title: const Text(
                            'Lokasi Kami',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () =>
                              Navigator.pushNamed(context, '/location'),
                        ),
                        const Divider(height: 1, color: Colors.white12),
                        ListTile(
                          leading: const Icon(
                            Icons.access_time,
                            color: Color(0xFF00E09E),
                          ),
                          title: const Text(
                            'Konversi Waktu',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () =>
                              Navigator.pushNamed(context, '/time-converter'),
                        ),
                        const Divider(height: 1, color: Colors.white12),
                        ListTile(
                          leading: const Icon(
                            Icons.feedback,
                            color: Color(0xFF00E09E),
                          ),
                          title: const Text(
                            'Saran & Kesan Matakuliah',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () =>
                              Navigator.pushNamed(context, '/feedback'),
                        ),
                        const Divider(height: 1, color: Colors.white12),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Color(0xFF00E09E),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () async {
                            await SharedPrefsService.clearUserData();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
}

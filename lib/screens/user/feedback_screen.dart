import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F2F),
      appBar: AppBar(
        title: const Text('Saran & Kesan Matakuliah'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A2236),
        foregroundColor: const Color(0xFFE0E6ED),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Card(
            color: const Color(0xFF232B3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 14),
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E09E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Saran & Kesan\nMata Kuliah Teknologi dan Pemrograman Mobile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF00E09E),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dosen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person, color: Color(0xFF00E09E), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Dosen: Bagus Muhammad Akbar & Aslab',
                        style: TextStyle(
                          color: Color(0xFFE0E6ED),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        5,
                        (i) => const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '5/5',
                        style: TextStyle(
                          color: Color(0xFF00E09E),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Isi Saran & Kesan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2236),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Saya ingin mengucapkan terima kasih untuk kesempatan mengikuti mata kuliah Teknologi dan Pemrograman Mobile bersama Dosen Bagus Muhammad Akbar. Materinya menarik dan langsung aplikatif, bikin saya lebih paham tentang dunia pemrograman mobile.\n\n'
                      'Tugas akhirnya sih, cukup menantang dan kadang bikin pusing karena rumit banget. Tapi, saya juga merasa itu jadi tantangan yang mengasah kemampuan. Meskipun agak susah, tetap seru karena jadi belajar banyak hal baru.\n\n'
                      'Overall, seru banget! Pak Bagus dan Aslab ngajarnya enak dan bikin semangat buat belajar lebih jauh. Terima kasih!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E09E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Terima kasih untuk bimbingannya selama perkuliahan ini Pak Bagus dan Mas Aslab! BISMILLAH A!!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF00E09E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

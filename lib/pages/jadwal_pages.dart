import 'package:flutter/material.dart';

class JadwalPages extends StatefulWidget {
  const JadwalPages({super.key});

  @override
  State<JadwalPages> createState() => _JadwalPagesState();
}

class _JadwalPagesState extends State<JadwalPages> {
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> jadwal = [
    {"kode": "#001", "nama": "Algoritma dan Pemrograman", "jam": "08:00 - 09:40"},
    {"kode": "#002", "nama": "Struktur Data", "jam": "10:00 - 11:40"},
    {"kode": "#003", "nama": "Basis Data", "jam": "09:00 - 10:40"},
    {"kode": "#004", "nama": "Jaringan Komputer", "jam": "13:00 - 14:40"},
    {"kode": "#005", "nama": "Analisis Sistem", "jam": "08:00 - 09:40"},
    {"kode": "#006", "nama": "Perancangan Sistem Produksi", "jam": "09:00 - 10:40"},
    {"kode": "#007", "nama": "Akuntansi Dasar", "jam": "13:00 - 14:40"},
    {"kode": "#008", "nama": "Pengantar Manajemen", "jam": "15:00 - 16:40"},
    {"kode": "#009", "nama": "Pengantar Hukum Indonesia", "jam": "08:00 - 09:40"},
    {"kode": "#010", "nama": "Pengantar Agribisnis", "jam": "10:00 - 11:40"},
  ];

  List<Map<String, dynamic>> filteredJadwal = [];

  @override
  void initState() {
    super.initState();
    filteredJadwal = jadwal;
  }

  void filterSearch(String query) {
    final hasil = jadwal.where((item) {
      final nama = item["nama"].toString().toLowerCase();
      final kode = item["kode"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input) || kode.contains(input);
    }).toList();

    setState(() {
      filteredJadwal = hasil;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 101, 114, 114),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "JADWAL KULIAH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: const InputDecoration(
                          hintText: "Cari Kode / Mata Kuliah",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: filteredJadwal.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada hasil",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredJadwal.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xff284169),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text("📌", style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredJadwal[index]["kode"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // ⬇ NAMA + JAM DALAM 1 BARIS
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              filteredJadwal[index]["nama"],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            filteredJadwal[index]["jam"],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

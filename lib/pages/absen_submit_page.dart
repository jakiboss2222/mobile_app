import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

// Map import
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import './webcam_helper.dart';
import '../api/api_service.dart';

class AbsenSubmitPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const AbsenSubmitPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<AbsenSubmitPage> createState() => _AbsenSubmitPageState();
}

class _AbsenSubmitPageState extends State<AbsenSubmitPage> {
  final WebCamera cam = WebCamera();

  Uint8List? imageBytes;
  Position? position;

  bool isCameraReady = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCameraAfterRender();
    });

    _getLocation();
  }

  Future<void> _initializeCameraAfterRender() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await cam.initialize();
      setState(() => isCameraReady = true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal akses kamera: $e")));
    }
  }

  @override
  void dispose() {
    cam.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final data = await cam.capture();
      setState(() => imageBytes = data);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => position = pos);
  }

  Future<void> _submitAbsen() async {
    if (imageBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Foto belum diambil")));
      return;
    }
    if (position == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lokasi belum diambil")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      Dio dio = Dio();

      final form = FormData.fromMap({
        "id_krs_detail": widget.idKrsDetail,
        "pertemuan": widget.pertemuan,
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "foto": MultipartFile.fromBytes(
          imageBytes!,
          filename: "absen_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      });

      final res =
          await dio.post("${ApiService.baseUrl}absensi/submit", data: form);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.data["message"] ?? "Absen berhasil")));

      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal submit absen")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 Header dark blue + text putih
      appBar: AppBar(
        backgroundColor:  const Color(0xFF1C2A4D),
        elevation: 0,
        title: const Text(
          "Presensi",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======================= MAP ATAS =======================
            Stack(
              children: [
                Container(
                  height: 330,
                  child: position == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(position!.latitude, position!.longitude),
                            initialZoom: 17,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(position!.latitude, position!.longitude),
                                  width: 50,
                                  height: 50,
                                  child: const Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                )
                              ],
                            ),
                          ],
                        ),
                ),

                // 🔥 Nama mata kuliah diperkecil & rapi
                Positioned(
                  top: 18,
                  left: 25,
                  right: 25,
                  child: Center(
                    child: Text(
                      widget.namaMatkul,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // diperkecil
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // 🔥 Lokasi pojok kanan bawah kecil transparan
                if (position != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),

            // ======================= CAMERA & SUBMIT =======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text("Foto Presensi",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const HtmlElementView(viewType: 'webcam-view'),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: isCameraReady ? _capturePhoto : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Ambil Foto"),
                  ),

                  if (imageBytes != null) ...[
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        imageBytes!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E67),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isSubmitting ? null : _submitAbsen,
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Hadir",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

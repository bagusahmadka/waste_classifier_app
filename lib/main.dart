import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Classifier',
      theme: ThemeData(primarySwatch: Colors.green),
      home: WasteClassifierScreen(),
    );
  }
}

class WasteClassifierScreen extends StatefulWidget {
  const WasteClassifierScreen({super.key});

  @override
  _WasteClassifierScreenState createState() => _WasteClassifierScreenState();
}

class _WasteClassifierScreenState extends State<WasteClassifierScreen> {
  File? _image;
  String? _result;
  bool _isLoading = false;
  bool _modelReady = false;


  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulasi pengecekan model
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _modelReady = true;
        _result = 'Aplikasi siap digunakan!';
      });
    } catch (e) {
      setState(() {
        _result = 'Error inisialisasi: $e';
      });
    }
  }

  Future<List<double>> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Gagal memproses gambar');
    }

    // Resize ke 224x224
    final resized = img.copyResize(image, width: 224, height: 224);

    // Konversi ke array float yang dinormalisasi
    final input = <double>[];

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input.add(pixel.r / 255.0);
        input.add(pixel.g / 255.0);
        input.add(pixel.b / 255.0);
      }
    }

    return input;
  }

  // Simulasi klasifikasi menggunakan analisis warna sederhana
  Future<Map<String, dynamic>> _simulateClassification(List<double> input) async {
    await Future.delayed(Duration(seconds: 2)); // Simulasi processing time

    // Analisis sederhana berdasarkan rata-rata warna
    double avgRed = 0, avgGreen = 0, avgBlue = 0;
    int pixelCount = input.length ~/ 3;

    for (int i = 0; i < input.length; i += 3) {
      avgRed += input[i];
      avgGreen += input[i + 1];
      avgBlue += input[i + 2];
    }

    avgRed /= pixelCount;
    avgGreen /= pixelCount;
    avgBlue /= pixelCount;

    // Logika sederhana: jika lebih hijau dan coklat -> organik
    double organicScore = (avgGreen * 0.6 + (1 - avgBlue) * 0.4);

    // Tambahkan randomness untuk variasi
    final random = math.Random();
    organicScore += (random.nextDouble() - 0.5) * 0.2;
    organicScore = organicScore.clamp(0.0, 1.0);

    bool isOrganic = organicScore > 0.5;
    double confidence = isOrganic ? organicScore : (1 - organicScore);

    return {
      'label': isOrganic ? 'Organik' : 'Non-Organik',
      'confidence': confidence,
      'details': {
        'avgRed': avgRed,
        'avgGreen': avgGreen,
        'avgBlue': avgBlue,
      }
    };
  }

  Future<void> _classifyImage(File image) async {
    if (!_modelReady) return;

    setState(() {
      _isLoading = true;
      _result = 'Memproses gambar...';
    });

    try {
      // Preprocessing
      final preprocessed = await _preprocessImage(image);

      // Klasifikasi
      final result = await _simulateClassification(preprocessed);

      String label = result['label'];
      double confidence = result['confidence'];

      setState(() {
        _result = '$label\nTingkat kepercayaan: ${(confidence * 100).toStringAsFixed(1)}%';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _classifyImage(_image!);
      }
    } catch (e) {
      setState(() {
        _result = 'Error memilih gambar: $e';
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Waste Classifier'),
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade100, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image Display Area
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                  ),
                  child: _image == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera_back_outlined, size: 60, color: Colors.grey.shade400),
                              SizedBox(height: 12),
                              Text(
                                'Unggah gambar sampah',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                        ),
                ),
              ),

              SizedBox(height: 20),

              // Result Display
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Column(
                        children: [
                          CircularProgressIndicator(color: Colors.green),
                          SizedBox(height: 12),
                          Text('Menganalisis gambar...', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      )
                    : Text(
                        _result ?? 'Silakan unggah gambar untuk klasifikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _modelReady ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                      ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _modelReady ? () => _pickImageFromSource(ImageSource.camera) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          SizedBox(width: 8),
                          Text('Kamera'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _modelReady ? () => _pickImageFromSource(ImageSource.gallery) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined),
                          SizedBox(width: 8),
                          Text('Galeri'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Info Text
              Text(
                'Aplikasi ini mengklasifikasi gambar menjadi Organik atau Non-Organik.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}}
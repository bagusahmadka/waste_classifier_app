import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Image Display Area
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      color: Colors.white,
                    ),
                    child: _image == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pilih gambar sampah\nuntuk diklasifikasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Result Display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Column(
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 12),
                      Text(
                        'Menganalisis gambar...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    _result ?? 'Silakan pilih gambar untuk memulai klasifikasi',
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
                      child: ElevatedButton.icon(
                        onPressed: _modelReady ? () => _pickImageFromSource(ImageSource.camera) : null,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Kamera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _modelReady ? () => _pickImageFromSource(ImageSource.gallery) : null,
                        icon: Icon(Icons.photo_library),
                        label: Text('Galeri'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Info Text
                Text(
                  'Aplikasi ini mengklasifikasi sampah menjadi organik dan non-organik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
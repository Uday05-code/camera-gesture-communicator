import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  File? _image;
  String? _result;
  double? _confidence;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _result = null;
      _confidence = null;
    });
  }

  /// Send image to Flask backend for prediction
  Future<void> _predict() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse("http://127.0.0.1:5000/predict"); // Flask endpoint
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        setState(() {
          _result = jsonResponse['predicted_label'];
          _confidence = (jsonResponse['confidence'] ?? 0).toDouble();
        });
      } else {
        setState(() {
          _result = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Connection Error: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Detection"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "No Image Selected",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.indigo)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predict,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Predict Sign"),
            ),
            const SizedBox(height: 30),
            if (_result != null)
              Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Predicted Sign: $_result",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      if (_confidence != null)
                        Text(
                          "Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%",
                          style: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
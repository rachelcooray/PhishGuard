import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScreenshotScannerScreen extends StatefulWidget {
  const ScreenshotScannerScreen({super.key});

  @override
  State<ScreenshotScannerScreen> createState() => _ScreenshotScannerScreenState();
}

class _ScreenshotScannerScreenState extends State<ScreenshotScannerScreen> {
  final ApiService _apiService = ApiService();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
        _error = null;
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.scanScreenshot(_image!.path);

    setState(() {
      _isLoading = false;
      if (result.containsKey('error')) {
        _error = result['error'];
      } else {
        _result = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screenshot Analyzer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_image!, fit: BoxFit.contain),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Upload a screenshot of an email or SMS', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.upload),
              label: const Text('Select Screenshot'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_result != null) ...[
              const Divider(),
              Text('Results Found: ${_result!['urls_found']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
               if ((_result!['results'] as List).isNotEmpty)
                ...(_result!['results'] as List).map<Widget>((r) => Card(
                  color: r['analysis']['status'] == 'Safe' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: ListTile(
                    title: Text(r['url'], overflow: TextOverflow.ellipsis),
                    subtitle: Text('Status: ${r['analysis']['status']}'),
                    trailing: Icon(
                      r['analysis']['status'] == 'Safe' ? Icons.check_circle : Icons.warning,
                      color: r['analysis']['status'] == 'Safe' ? Colors.green : Colors.red,
                    ),
                  ),
                )).toList()
              else
                const Text('No URLs detected in the image.'),
              
              if (_result!['text_detected'] != null) ...[
                  const SizedBox(height: 20),
                  const Text('OCR Text Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black26,
                    child: Text(_result!['text_detected'], style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  )
              ]
            ]
          ],
        ),
      ),
    );
  }
}

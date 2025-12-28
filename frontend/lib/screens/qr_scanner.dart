import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ApiService _apiService = ApiService();
  bool _isScanning = true;
  bool _isLoading = false;
  
  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isLoading) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleResult(barcode.rawValue!);
        break; // Only handle the first one
      }
    }
  }

  Future<void> _handleResult(String url) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    // Check if it's a URL
    if (!url.startsWith('http')) {
       _showDialog("Not a URL", "The scanned content does not look like a URL:\n$url", isSafe: false);
       return;
    }

    final result = await _apiService.scanUrl(url);
    _showDialog(
      "Scan Result: ${result['status']}",
      "URL: $url\n\nRisk Score: ${result['risk_score']}\n\nFlags: ${(result['flags'] as List).join(', ')}",
      isSafe: result['status'] == 'Safe'
    );
  }

  void _showDialog(String title, String content, {required bool isSafe}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: isSafe ? Colors.green : Colors.red)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isLoading = false;
                _isScanning = true; // Resume scanning
              });
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe QR Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Point camera at a QR code'),
                  const SizedBox(height: 20),
                  if (_isLoading) const CircularProgressIndicator(),
                  // Simulator button for testing without camera
                  TextButton(
                    onPressed: () => _handleResult("http://malicious-example.com/login"),
                    child: const Text("Simulate Scan (Debug)"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

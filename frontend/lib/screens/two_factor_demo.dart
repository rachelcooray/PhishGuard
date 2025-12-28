import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TwoFactorDemoScreen extends StatefulWidget {
  const TwoFactorDemoScreen({super.key});

  @override
  State<TwoFactorDemoScreen> createState() => _TwoFactorDemoScreenState();
}

class _TwoFactorDemoScreenState extends State<TwoFactorDemoScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _codeController = TextEditingController();
  
  Map<String, dynamic>? _setupData;
  String? _verifyMessage;
  bool _isVerifySuccess = false;

  Future<void> _generate() async {
    try {
      final res = await _apiService.generate2FA('demo_user_123'); // Demo ID
      setState(() { _setupData = res; _verifyMessage = null; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verify() async {
    if (_codeController.text.isEmpty) return;
    try {
      final res = await _apiService.verify2FA('demo_user_123', _codeController.text);
      setState(() { 
        _isVerifySuccess = res['valid'];
        _verifyMessage = res['message'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _generate(); // Auto generate on load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2FA Simulation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Two-Factor Authentication', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Scan this QR code with Google Authenticator (or similar) and enter the code below.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
            if (_setupData != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Image.memory(
                  base64Decode(_setupData!['qr_code'].split(',').last),
                  errorBuilder: (c,e,s) => const Icon(Icons.error, color: Colors.black),
                ), 
              ),
              const SizedBox(height: 10),
              SelectableText('Secret: ${_setupData!['secret']}', style: const TextStyle(fontFamily: 'Courier')),
            ],
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter 6-digit Code', prefixIcon: Icon(Icons.timer)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _verify, child: const Text('VERIFY CODE')),
            const SizedBox(height: 30),
            if (_verifyMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isVerifySuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _isVerifySuccess ? Colors.green : Colors.red)
                ),
                child: Row(
                  children: [
                    Icon(_isVerifySuccess ? Icons.check_circle : Icons.error, color: _isVerifySuccess ? Colors.green : Colors.red),
                    const SizedBox(width: 10),
                    Text(_verifyMessage!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

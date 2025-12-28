import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class UrlScannerScreen extends StatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanUrl() async {
    if (_urlController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await _apiService.scanUrl(_urlController.text);

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'Dangerous') return AppTheme.errorColor;
    if (status == 'Suspicious') return AppTheme.warningColor;
    return AppTheme.primaryColor;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'Dangerous') return Icons.gpp_bad;
    if (status == 'Suspicious') return Icons.gpp_maybe;
    return Icons.gpp_good;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('URL Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             Text(
              'Analyze links for phishing threats',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL to Scan',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanUrl,
                icon: _isLoading ? Container() : const Icon(Icons.radar),
                label: _isLoading 
                  ? const Text('SCANNING...') 
                  : const Text('INITIATE SCAN'),
              ),
            ),
            const SizedBox(height: 40),
            
            if (_isLoading)
               RotationTransition(
                 turns: _controller,
                 child: Icon(Icons.radar, size: 100, color: AppTheme.primaryColor.withOpacity(0.5)),
               ),

            if (_result != null) ...[
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, double val, child) {
                  return Transform.scale(scale: val, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(_result!['status']).withOpacity(0.1),
                    border: Border.all(color: _getStatusColor(_result!['status']), width: 2),
                    boxShadow: [
                      BoxShadow(color: _getStatusColor(_result!['status']).withOpacity(0.2), blurRadius: 30)
                    ]
                  ),
                  child: Icon(
                    _getStatusIcon(_result!['status']),
                    size: 80,
                    color: _getStatusColor(_result!['status']),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _result!['status'].toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_result!['status']),
                ),
              ),
              const SizedBox(height: 10),
               Text(
                'Risk Score: ${_result!['risk_score']}/100',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              
              if ((_result!['flags'] as List).isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 10),
                      Text('No verification flags raised.', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),

              if ((_result!['flags'] as List).isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('DETECTION LOG:', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white54)),
                ),
                const SizedBox(height: 10),
                ...(_result!['flags'] as List).map<Widget>((f) => 
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: AppTheme.surfaceColor,
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                      title: Text(f, style: const TextStyle(color: Colors.white)),
                    ),
                  )
                ).toList(),
              ]
            ]
          ],
        ),
      ),
    );
  }
}

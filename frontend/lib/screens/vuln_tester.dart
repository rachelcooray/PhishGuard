import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class VulnTesterScreen extends StatefulWidget {
  const VulnTesterScreen({super.key});

  @override
  State<VulnTesterScreen> createState() => _VulnTesterScreenState();
}

class _VulnTesterScreenState extends State<VulnTesterScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _scan() async {
    if (_urlController.text.isEmpty) return;
    setState(() { _isLoading = true; _result = null; });
    try {
      final res = await _apiService.scanVulnerability(_urlController.text);
      setState(() { _result = res; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vuln Tester')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.bug_report, size: 60, color: Colors.white54),
            Text('Web Vulnerability Scan', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Target URL', prefixIcon: Icon(Icons.http)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _scan, child: _isLoading ? const CircularProgressIndicator() : const Text('SCAN TARGET')),
            const SizedBox(height: 30),
            if (_result != null) ...[
               Text('${_result!['vuln_count']} Issues Found', style: GoogleFonts.orbitron(fontSize: 24, color: _result!['vuln_count'] > 0 ? AppTheme.errorColor : Colors.green)),
               const SizedBox(height: 10),
               ...(_result!['findings'] as List).map<Widget>((f) => Card(
                 color: AppTheme.surfaceColor,
                 child: ListTile(
                   leading: Icon(Icons.warning, color: f['severity'] == 'Medium' ? Colors.orange : Colors.yellow),
                   title: Text(f['type'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                   subtitle: Text(f['description'], style: const TextStyle(color: Colors.white70)),
                   trailing: Text(f['severity'], style: TextStyle(color: f['severity'] == 'Medium' ? Colors.orange : Colors.yellow)),
                 ),
               )).toList()
            ]
          ],
        ),
      ),
    );
  }
}

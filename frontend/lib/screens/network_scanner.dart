import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({super.key});

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen> {
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _scan() async {
    setState(() { _isLoading = true; _result = null; });
    try {
      final res = await ApiService().scanNetwork();
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
      appBar: AppBar(title: const Text('Network Patrol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.router, size: 60, color: Colors.white54),
            Text('Local Network Scanner', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _scan, child: _isLoading ? const Text('SCANNING...') : const Text('START SCAN')),
            const SizedBox(height: 30),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result != null) ...[
              Text('Target: ${_result!['target']}', style: const TextStyle(color: Colors.white54)),
              const Divider(),
              Text('Open Ports Found', style: GoogleFonts.orbitron(fontSize: 18, color: AppTheme.primaryColor)),
              ...(_result!['open_ports'] as List).map<Widget>((p) => Card(
                color: Colors.green.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Port ${p['port']} (${p['service']})'),
                  subtitle: Text(p['status'], style: const TextStyle(color: Colors.green)),
                ),
              )).toList(),
              const SizedBox(height: 20),
              Text('Detected Devices (Simulated)', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.amber)),
              ...(_result!['devices'] as List).map<Widget>((d) => ListTile(
                leading: const Icon(Icons.computer, color: Colors.white),
                title: Text(d['name']),
                subtitle: Text('${d['ip']} - ${d['type']}'),
              )).toList(),
            ]
          ],
        ),
      ),
    );
  }
}

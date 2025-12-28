import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LogAnalyzerScreen extends StatefulWidget {
  const LogAnalyzerScreen({super.key});

  @override
  State<LogAnalyzerScreen> createState() => _LogAnalyzerScreenState();
}

class _LogAnalyzerScreenState extends State<LogAnalyzerScreen> {
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _pickAndAnalyze() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() { _isLoading = true; _result = null; });
      try {
        final res = await ApiService().analyzeLogs(result.files.single.path!);
        setState(() { _result = res; });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.analytics, size: 60, color: Colors.white54),
            Text('Server Log Auditor', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Upload Apache/Nginx access logs to detect brute force attempts.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _pickAndAnalyze, child: _isLoading ? const CircularProgressIndicator() : const Text('UPLOAD LOG FILE')),
            const SizedBox(height: 30),
            if (_result != null) ...[
               Text('Analyzed ${_result!['total_lines']} lines', style: const TextStyle(fontWeight: FontWeight.bold)),
               const SizedBox(height: 20),
               if ((_result!['suspicious_activity'] as List).isNotEmpty) ...[
                 Card(
                   color: AppTheme.errorColor.withOpacity(0.1),
                   child: Padding(
                     padding: const EdgeInsets.all(16),
                     child: Column(
                       children: [
                         const Row(children: [Icon(Icons.warning, color: AppTheme.errorColor), SizedBox(width: 10), Text('THREATS DETECTED', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold))]),
                         const SizedBox(height: 10),
                         ...(_result!['suspicious_activity'] as List).map<Widget>((ip) => ListTile(
                           title: Text('IP: ${ip['ip']}', style: const TextStyle(color: Colors.white)),
                           trailing: Text('${ip['failed_attempts']} Failures', style: const TextStyle(color: AppTheme.errorColor)),
                         )).toList()
                       ]
                     ),
                   ),
                 )
               ] else 
                 const Text('No suspicious patterns found.', style: TextStyle(color: Colors.green))
            ]
          ],
        ),
      ),
    );
  }
}

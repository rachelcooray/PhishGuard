import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EmailAnalyzerScreen extends StatefulWidget {
  const EmailAnalyzerScreen({super.key});

  @override
  State<EmailAnalyzerScreen> createState() => _EmailAnalyzerScreenState();
}

class _EmailAnalyzerScreenState extends State<EmailAnalyzerScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _analyze() async {
    if (_textController.text.isEmpty) return;
    setState(() { _isLoading = true; _result = null; });
    try {
      final res = await ApiService().analyzeEmail(_textController.text, _senderController.text);
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
      appBar: AppBar(title: const Text('Email Forensics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Phishing Email Analyzer', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            TextField(controller: _senderController, decoration: const InputDecoration(labelText: 'Sender Email (Optional)', prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 10),
            TextField(controller: _textController, maxLines: 5, decoration: const InputDecoration(labelText: 'Paste Email Body Content', alignLabelWithHint: true)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _analyze, child: _isLoading ? const CircularProgressIndicator() : const Text('ANALYZE CONTENT')),
            const SizedBox(height: 30),
            if (_result != null) ...[
              Text(_result!['risk_level'].toUpperCase(), style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: _result!['risk_level'] == 'Safe' ? Colors.green : AppTheme.errorColor)),
              Text('Risk Score: ${_result!['score']}/100'),
              const SizedBox(height: 20),
              ...(_result!['flags'] as List).map<Widget>((f) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(f, style: const TextStyle(color: Colors.white70)),
              )).toList()
            ]
          ],
        ),
      ),
    );
  }
}

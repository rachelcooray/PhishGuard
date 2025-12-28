import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PasswordCheckerScreen extends StatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  State<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends State<PasswordCheckerScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _checkPassword() async {
    if (_passwordController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.checkPasswordStrength(_passwordController.text);

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  Color _getScoreColor(int score) {
    if (score <= 1) return AppTheme.errorColor;
    if (score == 2) return AppTheme.warningColor;
    if (score == 3) return Colors.yellowAccent;
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Strength')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test your password complexity',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Enter Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkPassword,
              child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppTheme.backgroundColor))
                  : const Text('ANALYZE STRENGTH'),
            ),
            const SizedBox(height: 30),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getScoreColor(_result!['score']).withOpacity(0.5)),
                  boxShadow: [
                     BoxShadow(color: _getScoreColor(_result!['score']).withOpacity(0.1), blurRadius: 20),
                  ]
                ),
                child: Column(
                  children: [
                    Text(
                      'Security Score',
                      style: GoogleFonts.orbitron(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_result!['score']}/4',
                      style: GoogleFonts.orbitron(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(_result!['score']),
                      ),
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _result!['score'] / 4,
                      backgroundColor: Colors.black,
                      color: _getScoreColor(_result!['score']),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 20),
                    if (_result!['crack_time_display'] != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.white54),
                          const SizedBox(width: 8),
                          Text(
                            'Crack Time: ${_result!['crack_time_display']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_result!['warning'] != null && _result!['warning'].isNotEmpty)
                Card(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
                    title: const Text('Vulnerability Detected', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorColor)),
                    subtitle: Text(_result!['warning'], style: const TextStyle(color: Colors.white70)),
                  ),
                ),
              if (_result!['suggestions'] != null && (_result!['suggestions'] as List).isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                ...(_result!['suggestions'] as List).map<Widget>((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                )).toList(),
              ]
            ]
          ],
        ),
      ),
    );
  }
}

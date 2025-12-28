import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BreachCheckerScreen extends StatefulWidget {
  const BreachCheckerScreen({super.key});

  @override
  State<BreachCheckerScreen> createState() => _BreachCheckerScreenState();
}

class _BreachCheckerScreenState extends State<BreachCheckerScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _checkBreach() async {
    if (_passwordController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await _apiService.checkBreach(_passwordController.text);
      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breach Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              'Have I Been Pwned?',
              style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Check if your password has appeared in known data breaches.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter Password to Check',
                prefixIcon: Icon(Icons.vpn_key),
                helperText: 'We only send a partial hash (k-anonymity) for your privacy.',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkBreach,
                icon: _isLoading ? Container() : const Icon(Icons.search),
                label: _isLoading ? const Text('SEARCHING DB...') : const Text('CHECK BREACHES'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _result!['breached'] ? AppTheme.errorColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _result!['breached'] ? AppTheme.errorColor : Colors.green,
                    width: 2
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _result!['breached'] ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 60,
                      color: _result!['breached'] ? AppTheme.errorColor : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result!['breached'] ? 'COMPROMISED' : 'SAFE',
                      style: GoogleFonts.orbitron(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold,
                        color: _result!['breached'] ? AppTheme.errorColor : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result!['message'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_result!['breached']) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      const Text(
                        'Recommendation: Change this password immediately if you use it on any account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

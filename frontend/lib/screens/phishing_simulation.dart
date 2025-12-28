import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PhishingCampaignScreen extends StatefulWidget {
  const PhishingCampaignScreen({super.key});

  @override
  State<PhishingCampaignScreen> createState() => _PhishingCampaignScreenState();
}

class _PhishingCampaignScreenState extends State<PhishingCampaignScreen> {
  final TextEditingController _emailController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _create() async {
    if (_emailController.text.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final res = await ApiService().createPhishingCampaign(_emailController.text);
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
      appBar: AppBar(title: const Text('Phish Sim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.mark_email_unread, size: 60, color: Colors.white54),
            Text('Simulated Campaign', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Target Email Address', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _isLoading ? null : _create, child: const Text('LAUNCH SIMULATION')),
            const SizedBox(height: 30),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green)),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 50, color: Colors.green),
                    const SizedBox(height: 10),
                    Text('CAMPAIGN ACTIVE', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    Text(_result!['message'], textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Chip(label: Text('ID: ${_result!['campaign_id']}'))
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

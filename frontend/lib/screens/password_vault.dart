import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PasswordVaultScreen extends StatefulWidget {
  const PasswordVaultScreen({super.key});

  @override
  State<PasswordVaultScreen> createState() => _PasswordVaultScreenState();
}

class _PasswordVaultScreenState extends State<PasswordVaultScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _apiService.getVaultEntries();
      setState(() { _entries = entries; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; }); // Handle error silently or show snackbar
    }
  }

  Future<void> _addEntry() async {
    final serviceController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Add Safe Entry', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: serviceController, decoration: const InputDecoration(labelText: 'Service (e.g. Netflix)')),
            const SizedBox(height: 10),
            TextField(controller: userController, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 10),
            TextField(controller: passController, obscureText: false, decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _apiService.addToVault(serviceController.text, userController.text, passController.text);
              _loadEntries();
            }, 
            child: const Text('Save Encrypted')
          ),
        ],
      )
    );
  }

  Future<void> _reveal(int id) async {
    try {
      final pass = await _apiService.revealVaultPassword(id);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Decrypted Password'),
          content: SelectableText(pass, style: GoogleFonts.orbitron(fontSize: 24, letterSpacing: 2)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Vault')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return Card(
                color: AppTheme.surfaceColor,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.lock, color: AppTheme.primaryColor)),
                  title: Text(entry['service'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(entry['username'], style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white54),
                    onPressed: () => _reveal(entry['id']),
                  ),
                ),
              );
            },
          ),
    );
  }
}

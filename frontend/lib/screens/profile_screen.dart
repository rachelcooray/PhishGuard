import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                   const CircleAvatar(
                     radius: 40, 
                     backgroundColor: Colors.white,
                     child: Icon(Icons.person, size: 50, color: Colors.deepPurple)
                   ),
                   const SizedBox(height: 16),
                   Text(user?['name'] ?? 'User', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                   Text(user?['email'] ?? 'No Email', style: const TextStyle(color: Colors.white70)),
                   const SizedBox(height: 20),
                   // Stats Mini-Fetch from here purely for display if we have them cached, or just generic Level badge
                   Chip(
                     backgroundColor: Colors.amber,
                     label: Text('SECURITY CLEARANCE: TOP SECRET', style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold)),
                   )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Settings Section
            const Text('APP SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: isDark ? Colors.purple.withOpacity(0.2) : Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? Colors.purple : Colors.orange),
                    ),
                    title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(isDark ? 'Cyberpunk Dark' : 'Bright Corporate'),
                    trailing: Switch(
                      value: isDark,
                      activeColor: Colors.purple,
                      onChanged: (val) => themeProvider.toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor, 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).popUntil((route) => route.isFirst); // pop to root
                },
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT SECURELY'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('PhishGuard v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))
          ],
        ),
      ),
    );
  }
}

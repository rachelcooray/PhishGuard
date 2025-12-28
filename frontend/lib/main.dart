import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/password_checker.dart';
import 'screens/url_scanner.dart';
import 'screens/qr_scanner.dart';
import 'screens/learning_hub.dart';
import 'screens/screenshot_scanner.dart';
import 'screens/breach_checker.dart';
import 'screens/malware_scanner.dart';
import 'screens/vuln_tester.dart';
import 'screens/two_factor_demo.dart';
import 'screens/password_vault.dart';

import 'screens/email_analyzer.dart';
import 'screens/network_scanner.dart';
import 'screens/log_analyzer.dart';
import 'screens/threat_dashboard.dart';
import 'screens/phishing_simulation.dart';

import 'providers/theme_provider.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PhishGuardApp(),
    ),
  );
}

class PhishGuardApp extends StatelessWidget {
  const PhishGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'PhishGuard',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    
    return const DashboardScreen();
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 1; // Default to Analysis

  final List<Widget> _pages = [
    // 0: Protection
    const _CategoryPage(
      title: 'Protection Tools',
      tiles: [
        _MenuTile(title: 'Password\nChecker', icon: Icons.password, color: Colors.green, route: PasswordCheckerScreen()),
        _MenuTile(title: 'Breach\nChecker', icon: Icons.cloud_off, color: Colors.redAccent, route: BreachCheckerScreen()),
        _MenuTile(title: 'Secure\nVault', icon: Icons.lock, color: Colors.orange, route: PasswordVaultScreen()),
        _MenuTile(title: '2FA\nDemo', icon: Icons.timer, color: Colors.teal, route: TwoFactorDemoScreen()),
        _MenuTile(title: 'QR\nScanner', icon: Icons.qr_code_scanner, color: Colors.orange, route: QrScannerScreen()),
        _MenuTile(title: 'Screenshot\nAnalyzer', icon: Icons.image, color: Colors.purpleAccent, route: ScreenshotScannerScreen()),
      ]
    ),
    // 1: Analysis (Main)
    const _CategoryPage(
      title: 'Analysis Lab',
      tiles: [
        _MenuTile(title: 'URL\nScanner', icon: Icons.link, color: Colors.blue, route: UrlScannerScreen()),
        _MenuTile(title: 'Malware\nScan', icon: Icons.bug_report, color: Colors.purple, route: MalwareScannerScreen()),
        _MenuTile(title: 'Email\nForensics', icon: Icons.search_off, color: Colors.blueGrey, route: EmailAnalyzerScreen()),
        _MenuTile(title: 'Network\nScan', icon: Icons.router, color: Colors.cyan, route: NetworkScannerScreen()),
        _MenuTile(title: 'Log\nAuditor', icon: Icons.text_snippet, color: Colors.brown, route: LogAnalyzerScreen()),
        _MenuTile(title: 'Vuln\nTester', icon: Icons.security, color: Colors.pink, route: VulnTesterScreen()),
      ]
    ),
    // 2: Education & Intel
    const _CategoryPage(
      title: 'Intel & Learning',
      tiles: [
        _MenuTile(title: 'Learning\nHub', icon: Icons.school, color: AppTheme.primaryColor, route: LearningHubScreen()),
        _MenuTile(title: 'Threat\nMap', icon: Icons.public, color: Colors.red, route: ThreatDashboardScreen()),
        _MenuTile(title: 'Phishing\nSim', icon: Icons.send_to_mobile, color: Colors.deepPurple, route: PhishingCampaignScreen()),
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PhishGuard', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
               child: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person)) // Simple avatar button
            ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Settings icon instead of logout
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // Global Gamification Bar
          FutureBuilder<Map<String, dynamic>>(
              future: ApiService().getUserStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator(minHeight: 2);
                final stats = snapshot.data!;
                return Container(
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text('Lvl ${stats['level']} Cyber Sentinel', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
                      const SizedBox(width: 15),
                      Expanded(child: LinearProgressIndicator(value: stats['xp'] / stats['next_level_xp'], color: Colors.amber, backgroundColor: Colors.grey[800])),
                      const SizedBox(width: 8),
                      Text('${stats['xp']} XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                );
              },
          ),
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Protection'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Education'),
        ],
      ),
    );
  }
}

class _CategoryPage extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _CategoryPage({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: tiles,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget route; // Changed onTap to direct Route widget for finding ease

  const _MenuTile({required this.title, required this.icon, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24), // Softer corners
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6)
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle
              ),
              child: Icon(icon, size: 32, color: Colors.white)
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}

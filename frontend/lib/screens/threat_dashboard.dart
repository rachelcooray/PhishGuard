import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ThreatDashboardScreen extends StatefulWidget {
  const ThreatDashboardScreen({super.key});

  @override
  State<ThreatDashboardScreen> createState() => _ThreatDashboardScreenState();
}

class _ThreatDashboardScreenState extends State<ThreatDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiService().getThreatDashboard().then((d) => setState(() { _data = d; _isLoading = false; }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Threats')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppTheme.surfaceColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Global Attack Volume (7 Days)', style: GoogleFonts.orbitron(color: Colors.white70)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: (_data!['global_attacks_last_7_days'] as List).asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                              isCurved: true,
                              color: AppTheme.primaryColor,
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.2)),
                            )
                          ]
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Recent Major Breaches', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white)),
            ...(_data!['recent_breaches'] as List).map<Widget>((b) => Card(
              color: Colors.white10,
              child: ListTile(
                leading: const Icon(Icons.public_off, color: Colors.redAccent),
                title: Text(b['entity']),
                subtitle: Text('${b['date']} • ${b['records']} records leaked'),
              ),
            )).toList(),
            const SizedBox(height: 20),
             Text('Active Malware Campaigns', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.orange)),
             Wrap(
               spacing: 10,
               children: (_data!['active_malware_campaigns'] as List).map<Widget>((c) => Chip(
                 label: Text(c, style: const TextStyle(color: Colors.black)),
                 backgroundColor: Colors.orange,
               )).toList(),
             )
          ],
        ),
      ),
    );
  }
}

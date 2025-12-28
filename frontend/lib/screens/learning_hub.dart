import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'module_detail_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _modules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final modules = await _apiService.fetchModules();
    setState(() {
      _modules = modules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Hub')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _modules.length,
              itemBuilder: (context, index) {
                final module = _modules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.grey[900],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.school, color: Colors.tealAccent, size: 40),
                    title: Text(
                      module['title'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(module['description'], style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${module['estimated_time']} min read', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModuleDetailScreen(moduleId: module['id'], title: module['title']),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

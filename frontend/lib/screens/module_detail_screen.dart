import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class ModuleDetailScreen extends StatefulWidget {
  final int moduleId;
  final String title;

  const ModuleDetailScreen({super.key, required this.moduleId, required this.title});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _module;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModuleDetail();
  }

  Future<void> _loadModuleDetail() async {
    final module = await _apiService.fetchModuleDetail(widget.moduleId);
    setState(() {
      _module = module;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _module == null
              ? const Center(child: Text('Failed to load content'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // Changed to Column to accommodate the button
                    children: [
                      Expanded( // Wrapped Markdown in Expanded to allow it to take available space
                        child: Markdown(
                          data: _module!['content'] ?? '',
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white70),
                            h1: GoogleFonts.orbitron(color: AppTheme.primaryColor, fontSize: 24),
                            h2: GoogleFonts.orbitron(color: Colors.white, fontSize: 20),
                            strong: const TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(moduleId: widget.moduleId))),
                        icon: const Icon(Icons.quiz),
                        label: const Text('TAKE QUIZ & EARN XP'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}

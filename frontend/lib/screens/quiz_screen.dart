import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final int moduleId;
  const QuizScreen({super.key, required this.moduleId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _finished = false;
  Map<String, dynamic>? _results;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final q = await ApiService().getQuiz(widget.moduleId);
      setState(() { _questions = q; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _submit(int selectedOption) async {
    bool correct = selectedOption == _questions[_currentIndex]['correct_index'];
    if (correct) _score++;
    
    if (_currentIndex < _questions.length - 1) {
      setState(() { _currentIndex++; });
    } else {
      // Finish
      setState(() { _isLoading = true; });
      try {
        final res = await ApiService().submitQuiz(widget.moduleId, _score);
        setState(() { _results = res; _finished = true; _isLoading = false; });
      } catch (e) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No quiz available for this module.', style: TextStyle(color: Colors.white))),
      );
    }

    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_results!['level_up'] ? 'LEVEL UP!' : 'Quiz Complete!', style: GoogleFonts.orbitron(fontSize: 32, color: AppTheme.primaryColor)),
              const SizedBox(height: 20),
              Text('+${_results!['earned_xp']} XP Earned', style: const TextStyle(fontSize: 24, color: Colors.green)),
              const SizedBox(height: 40),
              Text('Total XP: ${_results!['new_total_xp']}', style: const TextStyle(color: Colors.white70)),
              Text('Level: ${_results!['new_level']}', style: GoogleFonts.orbitron(fontSize: 24, color: Colors.amber)),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('RETURN TO HUB'))
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_currentIndex + 1}/${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length, backgroundColor: Colors.white12, color: AppTheme.primaryColor),
            const SizedBox(height: 40),
            Text(q['question'], style: GoogleFonts.orbitron(fontSize: 22, color: Colors.white), textAlign: TextAlign.center),
            const Spacer(),
            ...(q['options'] as List).asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    side: const BorderSide(color: AppTheme.primaryColor),
                    foregroundColor: Colors.white
                  ),
                  onPressed: () => _submit(entry.key),
                  child: Text(entry.value, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )).toList(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

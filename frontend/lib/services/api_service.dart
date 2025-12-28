import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator/web
  // For this environment (running locally), localhost should work for web/tests
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'error', 'message': 'Failed to connect: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> checkPasswordStrength(String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/password/check-strength'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'score': 0, 'warning': 'Error: ${response.statusCode}', 'suggestions': []};
      }
    } catch (e) {
      return {'score': 0, 'warning': 'Connection Error', 'suggestions': []};
    }
  }

  Future<Map<String, dynamic>> scanUrl(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/url/scan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'Error', 'risk_score': 0, 'flags': ['API Error: ${response.statusCode}']};
      }
    } catch (e) {
      return {'status': 'Error', 'risk_score': 0, 'flags': ['Connection Error']};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      return _processAuthResponse(response);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      return _processAuthResponse(response);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }

  Map<String, dynamic> _processAuthResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data; // Should contain 'token' and 'user'
      } else {
        return {'error': data['error'] ?? 'Unknown error', 'statusCode': response.statusCode};
      }
    } catch (e) {
      return {'error': 'Failed to parse response'};
    }
  }

  Future<Map<String, dynamic>> scanScreenshot(String filepath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/screenshot/scan'));
      request.files.add(await http.MultipartFile.fromPath('image', filepath));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Analysis failed: ${response.statusCode}'};
      }
    } catch (e) {
      throw Exception('Failed to scan screenshot: $e');
    }
  }

  // Feature 2: Password Breach Checker
  Future<Map<String, dynamic>> checkBreach(String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/breach/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check breach status');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Feature 6: Malware Scanner
  Future<Map<String, dynamic>> scanMalware(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/malware/scan'));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to scan file');
      }
    } catch (e) {
      throw Exception('Scan error: $e');
    }
  }

  // Feature 8: Website Vulnerability Tester
  Future<Map<String, dynamic>> scanVulnerability(String url) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vuln/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to test vulnerability');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Feature 11: 2FA Demo
  Future<Map<String, dynamic>> generate2FA(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/twofa/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to generate 2FA');
    } catch (e) { throw Exception('Error: $e'); }
  }

  Future<Map<String, dynamic>> verify2FA(String userId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/twofa/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'code': code}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to verify code');
    } catch (e) { throw Exception('Error: $e'); }
  }

  // Feature 12: Password Vault
  Future<void> addToVault(String service, String username, String password) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/vault/add'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'service': service, 'username': username, 'password': password}),
    );
    if (response.statusCode != 201) throw Exception('Failed to save to vault');
  }

  Future<List<dynamic>> getVaultEntries() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/vault/list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load vault');
  }

  Future<String> revealVaultPassword(int id) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/vault/reveal/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['password'];
    throw Exception('Failed to decrypt password');
  }

  Future<List<dynamic>> fetchModules() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/learning/modules'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchModuleDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/learning/modules/$id'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'jwt'); 
  }

  // Feature 5: Email Analyzer
  Future<Map<String, dynamic>> analyzeEmail(String text, String sender) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/email/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'sender': sender}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Analysis failed');
  }

  // Feature 7: Network Scanner
  Future<Map<String, dynamic>> scanNetwork() async {
    final response = await http.post(Uri.parse('$baseUrl/api/network/scan'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Scan failed');
  }

  // Feature 9: Log Analyzer
  Future<Map<String, dynamic>> analyzeLogs(String filePath) async {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/logs/analyze'));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      var res = await http.Response.fromStream(await request.send());
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw Exception('Analysis failed: ${res.body}');
  }

  // Feature 10: Threat Dashboard
  Future<Map<String, dynamic>> getThreatDashboard() async {
    final response = await http.get(Uri.parse('$baseUrl/api/threats/dashboard'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load dashboard');
  }

  // Feature 16: Phishing Simulation
  Future<Map<String, dynamic>> createPhishingCampaign(String target) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/phish_sim/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'target_email': target}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Creation failed');
  }

  // Feature 13 & 15: Gamification
  Future<Map<String, dynamic>> getUserStats() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/gamification/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stats');
  }

  Future<List<dynamic>> getQuiz(int moduleId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/gamification/quiz/$moduleId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load quiz');
  }

  Future<Map<String, dynamic>> submitQuiz(int moduleId, int score) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/gamification/submit'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'module_id': moduleId, 'score': score}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to submit quiz');
  }
}
